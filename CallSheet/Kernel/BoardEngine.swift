import Foundation

enum BoardEngine {
    static func ranked(
        _ slips: [PersonSlip],
        crewHoursLeft: Double,
        filter: DeskFilter
    ) -> [PersonSlip] {
        let crewShort = crewHoursLeft < 8
        return slips
            .filter { matches($0, filter: filter, crewHoursLeft: crewHoursLeft) }
            .sorted { lhs, rhs in
                let left = score(lhs, crewShort: crewShort)
                let right = score(rhs, crewShort: crewShort)
                if left != right { return left > right }
                return lhs.siteName < rhs.siteName
            }
    }

    static func matches(_ slip: PersonSlip, filter: DeskFilter, crewHoursLeft: Double) -> Bool {
        if slip.booked { return filter == .callLater }
        switch filter {
        case .bidCold:
            return slip.lastQuoteDays >= 7
        case .crewOpen:
            return crewHoursLeft >= slip.crewHoursNeeded && slip.crewHoursNeeded > 0
        case .voicemail:
            return slip.lastOutcome == .voicemail || slip.voicemailStreak >= 1
        case .callLater:
            return slip.nextCallDayOffset > 0 || slip.lastOutcome == .later
        }
    }

    static func score(_ slip: PersonSlip, crewShort: Bool) -> Int {
        var value = slip.lastQuoteDays * 2
        if slip.nextCallDayOffset <= 0 {
            value += 18
        } else {
            value -= slip.nextCallDayOffset
        }
        if slip.booked {
            value -= 40
        }
        if slip.voicemailStreak >= 3, !crewShort {
            value -= 24
        } else {
            value += slip.voicemailStreak
        }
        return value
    }

    static func heat(days: Int, window: Int) -> QuoteHeat {
        if days >= 14 { return .decay }
        if days >= window { return .cold }
        if days >= max(3, window / 2) { return .warm }
        return .fresh
    }

    static func quoteClock(days: Int, window: Int) -> QuoteClockResult {
        let clampedDays = max(0, days)
        let clampedWindow = window == 3 || window == 14 ? window : 7
        let heat = heat(days: clampedDays, window: clampedWindow)
        let line: String
        switch heat {
        case .fresh:
            line = "Still inside the \(clampedWindow)-day window. Call if the crew has a hole."
        case .warm:
            line = "\(clampedDays) days on the porch. Warm — they still remember the number."
        case .cold:
            line = "\(clampedDays) days sitting. The bid is going cold against the \(clampedWindow)-day clock."
        case .decay:
            line = "\(clampedDays) days with no yes or no. Flag decay and call before you reprint."
        }
        return QuoteClockResult(days: clampedDays, window: clampedWindow, heat: heat, line: line)
    }

    static func crewFit(hours: Double, openQuotes: Int) -> CrewFitResult {
        let safeHours = max(0, hours)
        let quotes = max(0, openQuotes)
        let hoursNeeded = Double(quotes) * 4.5
        let willClear = hoursNeeded <= safeHours && quotes > 0
        let line: String
        if quotes == 0 {
            line = "No open yes/no quotes. Put leftover hours on a later callback."
        } else if willClear {
            line = String(format: "%.0f h left covers %d open quotes. Keep calling this stack.", safeHours, quotes)
        } else {
            line = String(
                format: "%.0f h left cannot clear %d quotes (need ~%.0f h). Rank the coldest first.",
                safeHours,
                quotes,
                hoursNeeded
            )
        }
        return CrewFitResult(hours: safeHours, openQuotes: quotes, willClear: willClear, line: line)
    }

    static func bidAge(days: Int) -> BidAgeResult {
        let safe = max(0, days)
        let decay = safe >= 14
        let line = decay
            ? "\(safe) days without a yes or no. Decay flag — call or pull the bid."
            : "\(safe) days sitting. Still a live quote, not a reprint yet."
        return BidAgeResult(days: safe, decay: decay, line: line)
    }

    static func streakLine(streak: Int, crewShort: Bool) -> String {
        if streak >= 3, !crewShort {
            return "Three voicemails. Demote this slip unless leftover hours are short."
        }
        if streak >= 3, crewShort {
            return "Three voicemails, but the week is short — keep them on the desk."
        }
        if streak == 0 {
            return "No voicemail streak. Stay in the ranked order."
        }
        return "\(streak) voicemail\(streak == 1 ? "" : "s") in a row. Log the next outcome before you dial again."
    }

    static func callbackCaption(_ slip: PersonSlip) -> String {
        if slip.booked { return "Booked" }
        if slip.nextCallDayOffset < 0 { return "\(-slip.nextCallDayOffset)d overdue" }
        if slip.nextCallDayOffset == 0 { return "Call today" }
        return "In \(slip.nextCallDayOffset)d"
    }

    static func heatCaption(_ slip: PersonSlip) -> String {
        "\(slip.lastQuoteDays)d on bid · \(slip.trade.title)"
    }

    static func readings(
        slips: [PersonSlip],
        openBlock: CallingBlock?,
        events: [ModuleEvent],
        crewHoursLeft: Double
    ) -> [BoardReading] {
        let cold = slips.filter { $0.lastQuoteDays >= 7 && !$0.booked }.count
        let due = slips.filter { $0.nextCallDayOffset <= 0 && !$0.booked }.count
        let connected = events.filter { event in
            event.blockId == openBlock?.id && event.summary.lowercased().contains("connected")
        }.count
        let hoursText = String(format: "%.0f h", crewHoursLeft)
        return [
            BoardReading(
                id: "tile-cold",
                station: "Bids going cold",
                reading: "\(cold)",
                stamp: "≥7 days on the porch",
                state: cold >= 4 ? .fault : (cold >= 2 ? .watch : .ok)
            ),
            BoardReading(
                id: "tile-due",
                station: "Callbacks due",
                reading: "\(due)",
                stamp: "dated today or overdue",
                state: due >= 5 ? .fault : (due >= 2 ? .watch : .ok)
            ),
            BoardReading(
                id: "tile-connected",
                station: "Connected this block",
                reading: "\(connected)",
                stamp: openBlock?.name ?? "No block open",
                state: connected == 0 ? .watch : .ok
            ),
            BoardReading(
                id: "tile-crew",
                station: "Crew hours open",
                reading: hoursText,
                stamp: "leftover this week",
                state: crewHoursLeft < 8 ? .watch : .ok
            ),
        ]
    }

    static func openQuotes(in slips: [PersonSlip]) -> Int {
        slips.filter { !$0.booked && $0.lastOutcome != .booked }.count
    }

    static func phoneURL(_ digits: String, scheme: String) -> URL? {
        let filtered = digits.filter(\.isNumber)
        guard filtered.count >= 7 else { return nil }
        return URL(string: "\(scheme):\(filtered)")
    }

    static func handoffText(
        block: CallingBlock,
        slips: [PersonSlip],
        events: [ModuleEvent]
    ) -> String {
        let called = slips.filter { block.calledSlipIds.contains($0.id) }
        let leftover = slips.filter { $0.lastQuoteDays >= 7 && !$0.booked }
        let dated = slips.filter { $0.nextCallDayOffset > 0 }
        var lines: [String] = [
            "Evening handoff — \(block.name)",
            block.dayLabel,
            "",
            "Called (\(called.count))",
        ]
        if called.isEmpty {
            lines.append("None yet.")
        } else {
            for slip in called {
                lines.append("• \(slip.siteName) — \(slip.lastOutcome.title)")
            }
        }
        lines.append("")
        lines.append("Cold bids still open (\(leftover.count))")
        for slip in leftover.prefix(8) {
            lines.append("• \(slip.siteName) — \(slip.lastQuoteDays)d")
        }
        lines.append("")
        lines.append("Dated next calls (\(dated.count))")
        for slip in dated.prefix(8) {
            lines.append("• \(slip.siteName) — in \(slip.nextCallDayOffset)d")
        }
        lines.append("")
        lines.append("Pad notes")
        let blockEvents = events.filter { $0.blockId == block.id }
        if blockEvents.isEmpty {
            lines.append("None.")
        } else {
            for event in blockEvents.suffix(8) {
                lines.append("• \(event.padName): \(event.summary)")
            }
        }
        if !block.leftoverNote.isEmpty {
            lines.append("")
            lines.append(block.leftoverNote)
        }
        return lines.joined(separator: "\n")
    }
}
