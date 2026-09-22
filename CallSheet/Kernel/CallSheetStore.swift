import Foundation
import SwiftUI

@MainActor
@Observable
final class CallSheetStore {
    var selectedTab: AppTab = .desk
    var hasCompletedOnboarding: Bool
    var slips: [PersonSlip]
    var blocks: [CallingBlock]
    var events: [ModuleEvent]
    var checks: [MorningCheck]
    var filter: DeskFilter = .bidCold
    var pendingSlipId: String?
    var crewHoursLeft: Double
    var lastHandoff: String = ""
    var lastLoggedSummary: String = ""
    var didSave = false
    var deskPath: [AppRoute] = []
    var padsPath: [AppRoute] = []
    var blocksPath: [AppRoute] = []

    private let onboardKey = "hasCompletedOnboarding"
    private let slipsKey = "callsheet.slips"
    private let blocksKey = "callsheet.blocks"
    private let eventsKey = "callsheet.events"
    private let checksKey = "callsheet.checks"
    private let hoursKey = "callsheet.crewHours"
    private let persist: Bool

    init(preview: Bool = false) {
        persist = !preview
        if ProcessInfo.processInfo.arguments.contains("-UITests") {
            UserDefaults.standard.removeObject(forKey: onboardKey)
            UserDefaults.standard.removeObject(forKey: slipsKey)
            UserDefaults.standard.removeObject(forKey: blocksKey)
            UserDefaults.standard.removeObject(forKey: eventsKey)
            UserDefaults.standard.removeObject(forKey: checksKey)
            UserDefaults.standard.removeObject(forKey: hoursKey)
        }
        hasCompletedOnboarding = preview ? true : UserDefaults.standard.bool(forKey: onboardKey)
        if preview {
            slips = CallSheetSeed.seedSlips
            blocks = CallSheetSeed.seedBlocks
            events = CallSheetSeed.seedEvents
            checks = CallSheetSeed.seedChecks
            crewHoursLeft = CallSheetSeed.crewHoursLeft
            return
        }
        slips = Self.load(slipsKey, fallback: CallSheetSeed.seedSlips)
        blocks = Self.load(blocksKey, fallback: CallSheetSeed.seedBlocks)
        events = Self.load(eventsKey, fallback: CallSheetSeed.seedEvents)
        checks = Self.load(checksKey, fallback: CallSheetSeed.seedChecks)
        let storedHours = UserDefaults.standard.object(forKey: hoursKey) as? Double
        crewHoursLeft = storedHours ?? CallSheetSeed.crewHoursLeft
    }

    var openBlock: CallingBlock? {
        blocks.first(where: \.isOpen)
    }

    var rankedSlips: [PersonSlip] {
        BoardEngine.ranked(slips, crewHoursLeft: crewHoursLeft, filter: filter)
    }

    var nextSlip: PersonSlip? {
        rankedSlips.first
    }

    var pendingSlip: PersonSlip? {
        if let pendingSlipId {
            return slips.first { $0.id == pendingSlipId }
        }
        return nextSlip
    }

    var readings: [BoardReading] {
        BoardEngine.readings(
            slips: slips,
            openBlock: openBlock,
            events: events,
            crewHoursLeft: crewHoursLeft
        )
    }

    var openQuoteCount: Int {
        BoardEngine.openQuotes(in: slips)
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        guard persist else { return }
        UserDefaults.standard.set(true, forKey: onboardKey)
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
        guard persist else { return }
        UserDefaults.standard.set(false, forKey: onboardKey)
    }

    func startBlock() {
        if let index = blocks.firstIndex(where: \.isOpen) {
            _ = index
            didSave.toggle()
            return
        }
        if let today = blocks.firstIndex(where: { $0.dayOffset == 0 && $0.id == "block-mon-am" }) {
            blocks[today].isOpen = true
        } else {
            let created = CallingBlock(
                id: "block-\(blocks.count + 21)",
                name: "Today block",
                dayLabel: "Today",
                dayOffset: 0,
                isOpen: true,
                calledSlipIds: [],
                leftoverNote: ""
            )
            blocks.insert(created, at: 0)
        }
        persistAll()
        didSave.toggle()
    }

    func ensureBlock() {
        if openBlock == nil {
            startBlock()
        }
    }

    func selectFilter(_ filter: DeskFilter) {
        self.filter = filter
    }

    func openSlip(_ id: String, on tab: AppTab) {
        pendingSlipId = id
        push(.slip(id), on: tab)
    }

    func push(_ route: AppRoute, on tab: AppTab) {
        switch tab {
        case .desk: deskPath.append(route)
        case .pads: padsPath.append(route)
        case .blocks: blocksPath.append(route)
        case .settings: break
        }
    }

    func markCalled(_ slipId: String) {
        ensureBlock()
        guard let blockIndex = blocks.firstIndex(where: \.isOpen) else { return }
        if !blocks[blockIndex].calledSlipIds.contains(slipId) {
            blocks[blockIndex].calledSlipIds.append(slipId)
        }
        persistAll()
    }

    func logOutcome(_ outcome: CallOutcome, note: String) {
        guard let slipId = pendingSlip?.id,
              let index = slips.firstIndex(where: { $0.id == slipId }) else { return }
        ensureBlock()
        slips[index].lastOutcome = outcome
        slips[index].note = note.isEmpty ? slips[index].note : note
        switch outcome {
        case .voicemail, .noAnswer:
            slips[index].voicemailStreak += 1
            slips[index].booked = false
        case .booked:
            slips[index].booked = true
            slips[index].voicemailStreak = 0
        case .connected, .later:
            slips[index].voicemailStreak = 0
            slips[index].booked = false
        }
        markCalled(slipId)
        appendEvent(pad: "Outcome Pad", summary: "\(slips[index].siteName) — \(outcome.title)")
        lastLoggedSummary = "\(slips[index].siteName) — \(outcome.title)"
        persistAll()
        didSave.toggle()
    }

    func pinNextCall(days: Int) {
        guard let slipId = pendingSlip?.id,
              let index = slips.firstIndex(where: { $0.id == slipId }) else { return }
        let clamped = max(0, min(days, 30))
        slips[index].nextCallDayOffset = clamped
        slips[index].lastOutcome = .later
        ensureBlock()
        appendEvent(pad: "Next Call", summary: "\(slips[index].siteName) in \(clamped)d")
        persistAll()
        didSave.toggle()
    }

    func saveQuoteClock(_ result: QuoteClockResult) {
        ensureBlock()
        let name = pendingSlip?.siteName ?? "Open quote"
        appendEvent(
            pad: "Quote Clock",
            summary: "\(name) \(result.days)d vs \(result.window)-day — \(result.heat.title)"
        )
        persistAll()
        didSave.toggle()
    }

    func saveCrewFit(_ result: CrewFitResult) {
        crewHoursLeft = result.hours
        ensureBlock()
        appendEvent(pad: "Crew Fit", summary: result.line)
        persistAll()
        didSave.toggle()
    }

    func saveBidAge(_ result: BidAgeResult) {
        if let slipId = pendingSlip?.id, let index = slips.firstIndex(where: { $0.id == slipId }) {
            slips[index].lastQuoteDays = result.days
        }
        ensureBlock()
        let name = pendingSlip?.siteName ?? "Open quote"
        appendEvent(pad: "Bid Age", summary: "\(name) \(result.line)")
        persistAll()
        didSave.toggle()
    }

    func saveStreakNote() {
        guard let slip = pendingSlip else { return }
        ensureBlock()
        appendEvent(
            pad: "No-Answer Streak",
            summary: BoardEngine.streakLine(streak: slip.voicemailStreak, crewShort: crewHoursLeft < 8)
        )
        persistAll()
        didSave.toggle()
    }

    func saveSaturdayFit(_ result: SaturdayFitResult) {
        ensureBlock()
        appendEvent(pad: "Saturday Fit", summary: result.line)
        persistAll()
        didSave.toggle()
    }

    func copyTalkCard(_ card: TalkCard) {
        let body = card.body.replacingOccurrences(of: "[site]", with: pendingSlip?.siteName ?? "the job")
        UIPasteboard.general.string = body
        ensureBlock()
        appendEvent(pad: "Talk Cards", summary: "Copied \(card.title)")
        persistAll()
        didSave.toggle()
    }

    func copyHandoff() {
        let block = openBlock ?? blocks.first
        guard let block else { return }
        lastHandoff = BoardEngine.handoffText(block: block, slips: slips, events: events)
        UIPasteboard.general.string = lastHandoff
        didSave.toggle()
    }

    func toggleCheck(_ id: String) {
        guard let index = checks.firstIndex(where: { $0.id == id }) else { return }
        checks[index].isDone.toggle()
        persistAll()
    }

    func focusBlock(_ id: String) {
        for index in blocks.indices {
            blocks[index].isOpen = blocks[index].id == id
        }
        persistAll()
    }

    func addSlip(siteName: String, trade: Trade, phone: String, days: Int, hours: Double) {
        let trimmed = siteName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let digits = phone.filter(\.isNumber)
        let serial = slips.count + 40
        let slip = PersonSlip(
            id: "slip-\(serial)",
            siteName: trimmed,
            trade: trade,
            phoneDigits: digits.count >= 7 ? digits : "5550101\(serial)",
            lastOutcome: .later,
            lastQuoteDays: max(0, days),
            nextCallDayOffset: 0,
            voicemailStreak: 0,
            booked: false,
            crewHoursNeeded: max(0, hours),
            note: "Added from the desk."
        )
        slips.insert(slip, at: 0)
        pendingSlipId = slip.id
        persistAll()
        didSave.toggle()
    }

    func deleteAll() {
        slips = CallSheetSeed.seedSlips
        blocks = CallSheetSeed.seedBlocks
        events = CallSheetSeed.seedEvents
        checks = CallSheetSeed.seedChecks
        crewHoursLeft = CallSheetSeed.crewHoursLeft
        pendingSlipId = nil
        lastHandoff = ""
        lastLoggedSummary = ""
        filter = .bidCold
        selectedTab = .desk
        deskPath = []
        padsPath = []
        blocksPath = []
        persistAll()
        resetOnboarding()
    }

    private func appendEvent(pad: String, summary: String) {
        let event = ModuleEvent(
            id: "ev-\(events.count + 21)",
            blockId: openBlock?.id ?? "block-mon-am",
            padName: pad,
            summary: summary,
            dayOffset: 0
        )
        events.insert(event, at: 0)
    }

    private func persistAll() {
        guard persist else { return }
        Self.save(slipsKey, slips)
        Self.save(blocksKey, blocks)
        Self.save(eventsKey, events)
        Self.save(checksKey, checks)
        UserDefaults.standard.set(crewHoursLeft, forKey: hoursKey)
    }

    private static func load<T: Decodable>(_ key: String, fallback: T) -> T {
        guard let data = UserDefaults.standard.data(forKey: key) else { return fallback }
        if let decoded = try? JSONDecoder().decode(T.self, from: data) {
            return decoded
        }
        return fallback
    }

    private static func save<T: Encodable>(_ key: String, _ value: T) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

@MainActor
struct AppDependencies {
    let store: CallSheetStore

    static func live() -> AppDependencies {
        AppDependencies(store: CallSheetStore())
    }

    static func preview() -> AppDependencies {
        AppDependencies(store: CallSheetStore(preview: true))
    }
}
