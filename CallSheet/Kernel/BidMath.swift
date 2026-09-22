import Foundation

enum BidMath {
    static func saturdayFit(hours: Double, halfDaysWanted: Int) -> SaturdayFitResult {
        let safeHours = max(0, hours)
        let wanted = max(0, halfDaysWanted)
        let capacity = Int(safeHours / 4.0)
        let willHold = wanted > 0 && wanted <= capacity
        let line: String
        if wanted == 0 {
            line = "Nobody asked for Saturday. Keep the crew on weekday leftover hours."
        } else if willHold {
            line = String(
                format: "%.0f Saturday hours hold %d half-day start%@. Call those slips before Friday noon.",
                safeHours,
                wanted,
                wanted == 1 ? "" : "s"
            )
        } else {
            line = String(
                format: "%.0f Saturday hours cannot hold %d half-days. Pick the coldest porch and let the rest wait.",
                safeHours,
                wanted
            )
        }
        return SaturdayFitResult(
            saturdayHours: safeHours,
            halfDaysWanted: wanted,
            willHold: willHold,
            line: line
        )
    }

    static func reprintCost(days: Int) -> ReprintCostResult {
        let safe = max(0, days)
        let reprint = safe >= 14
        let line = reprint
            ? "At \(safe) days the written number is stale. Call once more, then reprint or pull."
            : "At \(safe) days the written number still stands. Do not reprint yet."
        return ReprintCostResult(days: safe, reprint: reprint, line: line)
    }

    static func porchWindow(days: Int, window: Int) -> String {
        let heat = BoardEngine.heat(days: days, window: window)
        switch heat {
        case .fresh:
            return "Inside the window. Only call if Crew Fit shows a hole."
        case .warm:
            return "They still remember the quote. A short call keeps it alive."
        case .cold:
            return "Past the \(window)-day mark. This is the morning stack."
        case .decay:
            return "Past two weeks. Rank it first or pull it off the sheet."
        }
    }

    static func rankReasons(_ slip: PersonSlip, crewHoursLeft: Double) -> [String] {
        var reasons: [String] = []
        reasons.append("Quote age \(slip.lastQuoteDays)d adds \(slip.lastQuoteDays * 2) to the rank.")
        if slip.nextCallDayOffset <= 0 {
            reasons.append("Callback is due today or overdue. +18.")
        } else {
            reasons.append("Callback in \(slip.nextCallDayOffset)d. Rank drops by that many days.")
        }
        if slip.booked {
            reasons.append("Already booked. Rank is buried so it leaves the cold stack.")
        }
        if slip.voicemailStreak >= 3 {
            if crewHoursLeft < 8 {
                reasons.append("Three voicemails, but leftover hours are short, so it stays.")
            } else {
                reasons.append("Three voicemails with hours still open. Demoted.")
            }
        } else if slip.voicemailStreak > 0 {
            reasons.append("Voicemail streak \(slip.voicemailStreak) still sits in order.")
        }
        if slip.crewHoursNeeded > crewHoursLeft {
            reasons.append(
                String(format: "Needs %.0f h; crew has %.0f h left. It will not clear this week.", slip.crewHoursNeeded, crewHoursLeft)
            )
        }
        return reasons
    }

    static func leftoverHole(hours: Double, slip: PersonSlip) -> String {
        if slip.crewHoursNeeded <= hours {
            return String(format: "%@ fits a %.0f h leftover hole.", slip.siteName, hours)
        }
        return String(
            format: "%@ needs %.0f h. Skip it until a bigger hole opens.",
            slip.siteName,
            slip.crewHoursNeeded
        )
    }

    static func weekendHold(slip: PersonSlip) -> Bool {
        slip.note.lowercased().contains("saturday") || slip.nextCallDayOffset >= 5
    }

    static func saturdayWanted(in slips: [PersonSlip]) -> Int {
        slips.filter { weekendHold(slip: $0) && !$0.booked }.count
    }

    static func stormPriority(_ slip: PersonSlip) -> Bool {
        slip.trade == .roof || slip.trade == .deck
    }

    static func tradeTitle(_ trade: Trade) -> String {
        trade.title
    }

    static func shortNote(_ slip: PersonSlip) -> String {
        let trimmed = slip.note.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 80 { return trimmed }
        return String(trimmed.prefix(77)) + "…"
    }

    static func overdueDays(_ slip: PersonSlip) -> Int {
        max(0, -slip.nextCallDayOffset)
    }
}
