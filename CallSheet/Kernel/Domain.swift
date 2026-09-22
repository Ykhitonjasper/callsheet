import Foundation

enum Trade: String, CaseIterable, Identifiable, Codable, Hashable {
    case paint
    case roof
    case hvac
    case fence
    case gutters
    case deck

    var id: String { rawValue }

    var title: String {
        switch self {
        case .paint: return "Paint"
        case .roof: return "Roof"
        case .hvac: return "HVAC"
        case .fence: return "Fence"
        case .gutters: return "Gutters"
        case .deck: return "Deck"
        }
    }
}

enum CallOutcome: String, CaseIterable, Identifiable, Codable, Hashable {
    case connected
    case voicemail
    case noAnswer
    case booked
    case later

    var id: String { rawValue }

    var title: String {
        switch self {
        case .connected: return "Connected"
        case .voicemail: return "Voicemail"
        case .noAnswer: return "No answer"
        case .booked: return "Booked"
        case .later: return "Later"
        }
    }
}

enum DeskFilter: String, CaseIterable, Identifiable, Hashable {
    case bidCold
    case crewOpen
    case voicemail
    case callLater

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bidCold: return "Bid cold"
        case .crewOpen: return "Crew open"
        case .voicemail: return "Voicemail"
        case .callLater: return "Call later"
        }
    }
}

enum PadKind: String, CaseIterable, Identifiable, Hashable {
    case quoteClock
    case crewFit
    case bidAge
    case outcome
    case nextCall
    case talkCards
    case streak
    case saturdayFit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .quoteClock: return "Quote Clock"
        case .crewFit: return "Crew Fit"
        case .bidAge: return "Bid Age"
        case .outcome: return "Outcome Pad"
        case .nextCall: return "Next Call"
        case .talkCards: return "Talk Cards"
        case .streak: return "No-Answer Streak"
        case .saturdayFit: return "Saturday Fit"
        }
    }
}

enum QuoteHeat: String, Identifiable, Hashable {
    case fresh
    case warm
    case cold
    case decay

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fresh: return "Fresh"
        case .warm: return "Warm"
        case .cold: return "Cold"
        case .decay: return "Decay"
        }
    }
}

struct PersonSlip: Identifiable, Hashable, Codable {
    let id: String
    var siteName: String
    var trade: Trade
    var phoneDigits: String
    var lastOutcome: CallOutcome
    var lastQuoteDays: Int
    var nextCallDayOffset: Int
    var voicemailStreak: Int
    var booked: Bool
    var crewHoursNeeded: Double
    var note: String
}

struct CallingBlock: Identifiable, Hashable, Codable {
    let id: String
    var name: String
    var dayLabel: String
    var dayOffset: Int
    var isOpen: Bool
    var calledSlipIds: [String]
    var leftoverNote: String
}

struct ModuleEvent: Identifiable, Hashable, Codable {
    let id: String
    var blockId: String
    var padName: String
    var summary: String
    var dayOffset: Int
}

struct TalkCard: Identifiable, Hashable {
    let id: String
    let title: String
    let body: String
}

struct PadModule: Identifiable, Hashable {
    let id: String
    let kind: PadKind
    let name: String
    let blurb: String
    let hint: String
}

struct BoardTileSeed: Identifiable, Hashable {
    let id: String
    let station: String
    let seedReading: String
    let stamp: String
}

struct MorningCheck: Identifiable, Hashable, Codable {
    let id: String
    var title: String
    var isDone: Bool
}

struct QuoteClockResult: Hashable {
    let days: Int
    let window: Int
    let heat: QuoteHeat
    let line: String
}

struct CrewFitResult: Hashable {
    let hours: Double
    let openQuotes: Int
    let willClear: Bool
    let line: String
}

struct BidAgeResult: Hashable {
    let days: Int
    let decay: Bool
    let line: String
}

struct SaturdayFitResult: Hashable {
    let saturdayHours: Double
    let halfDaysWanted: Int
    let willHold: Bool
    let line: String
}

struct ReprintCostResult: Hashable {
    let days: Int
    let reprint: Bool
    let line: String
}

struct BoardReading: Identifiable, Hashable {
    let id: String
    let station: String
    let reading: String
    let stamp: String
    let state: StatusKind
}

enum StatusKind: Hashable {
    case ok
    case watch
    case fault
}

enum AppTab: String, CaseIterable, Identifiable, Hashable {
    case desk
    case pads
    case blocks
    case settings

    var id: String { rawValue }

    var label: String {
        switch self {
        case .desk: return "Desk"
        case .pads: return "Pads"
        case .blocks: return "Blocks"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .desk: return "list.clipboard"
        case .pads: return "square.grid.2x2"
        case .blocks: return "calendar"
        case .settings: return "gearshape"
        }
    }
}

enum AppRoute: Hashable {
    case slip(String)
    case pad(PadKind)
    case block(String)
    case handoff
    case newSlip
}
