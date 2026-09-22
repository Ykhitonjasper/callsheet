import Foundation

enum CallSheetSeed {
    static let crewHoursLeft = 14.0

    static let seedModules: [PadModule] = [
        PadModule(
            id: "pad-quote",
            kind: .quoteClock,
            name: "Quote Clock",
            blurb: "Days since the bid was left versus a 3 / 7 / 14 day cold window.",
            hint: "Heat for one porch quote"
        ),
        PadModule(
            id: "pad-crew",
            kind: .crewFit,
            name: "Crew Fit",
            blurb: "Leftover crew hours this week against open yes/no quotes.",
            hint: "Will this stack clear"
        ),
        PadModule(
            id: "pad-age",
            kind: .bidAge,
            name: "Bid Age",
            blurb: "Days sitting without a yes or no. Fourteen days raises a decay flag.",
            hint: "Decay check"
        ),
        PadModule(
            id: "pad-outcome",
            kind: .outcome,
            name: "Outcome Pad",
            blurb: "Connected, voicemail, no answer, booked, or later — writes the open block.",
            hint: "Log the last call"
        ),
        PadModule(
            id: "pad-next",
            kind: .nextCall,
            name: "Next Call",
            blurb: "Pin a dated callback row back on the desk. No banner, just a date.",
            hint: "Park a follow-up"
        ),
        PadModule(
            id: "pad-talk",
            kind: .talkCards,
            name: "Talk Cards",
            blurb: "Short bid-follow scripts for a porch quote, a storm window, or a leftover Saturday.",
            hint: "Copy a line"
        ),
        PadModule(
            id: "pad-streak",
            kind: .streak,
            name: "No-Answer Streak",
            blurb: "Three voicemails demote a slip unless Crew Fit says the week is short.",
            hint: "Keep or demote"
        ),
        PadModule(
            id: "pad-saturday",
            kind: .saturdayFit,
            name: "Saturday Fit",
            blurb: "Half-day Saturday hours versus jobs that only go if the weekend is held.",
            hint: "Hold a half-day"
        ),
    ]

    static let seedBoardTiles: [BoardTileSeed] = [
        BoardTileSeed(id: "tile-cold", station: "Bids going cold", seedReading: "6", stamp: "≥7 days on the porch"),
        BoardTileSeed(id: "tile-due", station: "Callbacks due", seedReading: "5", stamp: "dated today or overdue"),
        BoardTileSeed(id: "tile-connected", station: "Connected this block", seedReading: "2", stamp: "Mon Bid AM"),
        BoardTileSeed(id: "tile-crew", station: "Crew hours open", seedReading: "14 h", stamp: "leftover this week"),
    ]

    static let seedSlips: [PersonSlip] = [
        PersonSlip(
            id: "slip-river",
            siteName: "River porch paint",
            trade: .paint,
            phoneDigits: "5550101001",
            lastOutcome: .later,
            lastQuoteDays: 7,
            nextCallDayOffset: 0,
            voicemailStreak: 0,
            booked: false,
            crewHoursNeeded: 6,
            note: "Left a two-coat exterior quote on the porch rail. They asked about Saturday."
        ),
        PersonSlip(
            id: "slip-oak",
            siteName: "Oak roof leak",
            trade: .roof,
            phoneDigits: "5550101002",
            lastOutcome: .connected,
            lastQuoteDays: 3,
            nextCallDayOffset: 0,
            voicemailStreak: 0,
            booked: false,
            crewHoursNeeded: 8,
            note: "Flashing at the chimney. Weather window this week."
        ),
        PersonSlip(
            id: "slip-hill",
            siteName: "Hill fence",
            trade: .fence,
            phoneDigits: "5550101003",
            lastOutcome: .noAnswer,
            lastQuoteDays: 14,
            nextCallDayOffset: -1,
            voicemailStreak: 1,
            booked: false,
            crewHoursNeeded: 5,
            note: "Fourteen days, no yes or no. Decay flag."
        ),
        PersonSlip(
            id: "slip-mill",
            siteName: "Mill HVAC",
            trade: .hvac,
            phoneDigits: "5550101004",
            lastOutcome: .voicemail,
            lastQuoteDays: 9,
            nextCallDayOffset: 0,
            voicemailStreak: 3,
            booked: false,
            crewHoursNeeded: 4,
            note: "Three voicemails. Condenser pad quote still on the bench."
        ),
        PersonSlip(
            id: "slip-quarry",
            siteName: "Quarry gutters",
            trade: .gutters,
            phoneDigits: "5550101005",
            lastOutcome: .later,
            lastQuoteDays: 5,
            nextCallDayOffset: 4,
            voicemailStreak: 0,
            booked: false,
            crewHoursNeeded: 3,
            note: "Asked to call after Thursday. Leaf guards vs replacement."
        ),
        PersonSlip(
            id: "slip-dock",
            siteName: "Dock deck stain",
            trade: .deck,
            phoneDigits: "5550101006",
            lastOutcome: .connected,
            lastQuoteDays: 8,
            nextCallDayOffset: 0,
            voicemailStreak: 0,
            booked: false,
            crewHoursNeeded: 5,
            note: "Oil stain, south side gray. Crew can take Friday afternoon."
        ),
        PersonSlip(
            id: "slip-barn",
            siteName: "Barn siding",
            trade: .paint,
            phoneDigits: "5550101007",
            lastOutcome: .noAnswer,
            lastQuoteDays: 11,
            nextCallDayOffset: -2,
            voicemailStreak: 2,
            booked: false,
            crewHoursNeeded: 10,
            note: "Board and batten, north wall. Big hours if they say yes."
        ),
        PersonSlip(
            id: "slip-alley",
            siteName: "Alley boiler",
            trade: .hvac,
            phoneDigits: "5550101008",
            lastOutcome: .later,
            lastQuoteDays: 6,
            nextCallDayOffset: 1,
            voicemailStreak: 0,
            booked: false,
            crewHoursNeeded: 7,
            note: "Swap vs repair. They wanted to talk to a sibling first."
        ),
        PersonSlip(
            id: "slip-pier",
            siteName: "Pier fascia",
            trade: .paint,
            phoneDigits: "5550101009",
            lastOutcome: .voicemail,
            lastQuoteDays: 4,
            nextCallDayOffset: 0,
            voicemailStreak: 1,
            booked: false,
            crewHoursNeeded: 3,
            note: "Fascia and soffit, street side. Short crew job."
        ),
        PersonSlip(
            id: "slip-shed",
            siteName: "Shed door",
            trade: .fence,
            phoneDigits: "5550101010",
            lastOutcome: .connected,
            lastQuoteDays: 2,
            nextCallDayOffset: 2,
            voicemailStreak: 0,
            booked: false,
            crewHoursNeeded: 2,
            note: "New door and trim. Small, can fill a leftover hour."
        ),
        PersonSlip(
            id: "slip-loft",
            siteName: "Loft bath fan",
            trade: .hvac,
            phoneDigits: "5550101011",
            lastOutcome: .booked,
            lastQuoteDays: 1,
            nextCallDayOffset: 3,
            voicemailStreak: 0,
            booked: true,
            crewHoursNeeded: 2,
            note: "Booked Wednesday. Keep off the cold stack."
        ),
        PersonSlip(
            id: "slip-yard",
            siteName: "Yard trellis",
            trade: .paint,
            phoneDigits: "5550101012",
            lastOutcome: .noAnswer,
            lastQuoteDays: 10,
            nextCallDayOffset: 0,
            voicemailStreak: 1,
            booked: false,
            crewHoursNeeded: 4,
            note: "Lattice and post, garden side. Color already picked."
        ),
        PersonSlip(
            id: "slip-creek",
            siteName: "Creek fascia wrap",
            trade: .paint,
            phoneDigits: "5550101013",
            lastOutcome: .later,
            lastQuoteDays: 12,
            nextCallDayOffset: 0,
            voicemailStreak: 0,
            booked: false,
            crewHoursNeeded: 4,
            note: "Aluminum wrap vs paint. They asked about a Saturday start."
        ),
        PersonSlip(
            id: "slip-ridge",
            siteName: "Ridge shingles",
            trade: .roof,
            phoneDigits: "5550101014",
            lastOutcome: .voicemail,
            lastQuoteDays: 6,
            nextCallDayOffset: -1,
            voicemailStreak: 2,
            booked: false,
            crewHoursNeeded: 9,
            note: "Ridge cap and two pipes. Storm window this week."
        ),
        PersonSlip(
            id: "slip-lane",
            siteName: "Lane heat pump",
            trade: .hvac,
            phoneDigits: "5550101015",
            lastOutcome: .connected,
            lastQuoteDays: 4,
            nextCallDayOffset: 1,
            voicemailStreak: 0,
            booked: false,
            crewHoursNeeded: 6,
            note: "Swap the pad unit. Sibling has the other quote."
        ),
        PersonSlip(
            id: "slip-orchard",
            siteName: "Orchard rail fence",
            trade: .fence,
            phoneDigits: "5550101016",
            lastOutcome: .noAnswer,
            lastQuoteDays: 8,
            nextCallDayOffset: 0,
            voicemailStreak: 1,
            booked: false,
            crewHoursNeeded: 7,
            note: "Split rail along the drive. Stain included."
        ),
    ]

    static let seedBlocks: [CallingBlock] = [
        CallingBlock(
            id: "block-mon-am",
            name: "Mon Bid AM",
            dayLabel: "Monday morning",
            dayOffset: 0,
            isOpen: false,
            calledSlipIds: ["slip-oak"],
            leftoverNote: "River porch still cold. Mill HVAC on voicemail three."
        ),
        CallingBlock(
            id: "block-mon-pm",
            name: "Mon Leftovers PM",
            dayLabel: "Monday afternoon",
            dayOffset: 0,
            isOpen: false,
            calledSlipIds: ["slip-pier"],
            leftoverNote: "Fascia picked up. Hill fence still silent."
        ),
        CallingBlock(
            id: "block-tue-roof",
            name: "Tue Roof round",
            dayLabel: "Tuesday",
            dayOffset: -1,
            isOpen: false,
            calledSlipIds: ["slip-oak", "slip-barn"],
            leftoverNote: "Oak still deciding. Barn siding no answer twice."
        ),
        CallingBlock(
            id: "block-wed-paint",
            name: "Wed Paint ghost",
            dayLabel: "Wednesday",
            dayOffset: -2,
            isOpen: false,
            calledSlipIds: ["slip-river", "slip-yard"],
            leftoverNote: "River asked about Saturday. Yard trellis still open."
        ),
        CallingBlock(
            id: "block-thu-hvac",
            name: "Thu HVAC fill",
            dayLabel: "Thursday",
            dayOffset: -3,
            isOpen: false,
            calledSlipIds: ["slip-mill", "slip-alley"],
            leftoverNote: "Mill ghosting. Alley boiler waiting on a sibling."
        ),
        CallingBlock(
            id: "block-fri-crew",
            name: "Fri Crew rescue",
            dayLabel: "Friday",
            dayOffset: -4,
            isOpen: false,
            calledSlipIds: ["slip-dock", "slip-shed"],
            leftoverNote: "Dock stain can take leftover Friday hours."
        ),
        CallingBlock(
            id: "block-sat",
            name: "Sat Overflow",
            dayLabel: "Saturday",
            dayOffset: -5,
            isOpen: false,
            calledSlipIds: ["slip-quarry"],
            leftoverNote: "Gutters parked until after Thursday."
        ),
        CallingBlock(
            id: "block-month",
            name: "Month-start sweep",
            dayLabel: "First Monday",
            dayOffset: -10,
            isOpen: false,
            calledSlipIds: ["slip-hill", "slip-river"],
            leftoverNote: "Opened the month on the oldest porch quotes."
        ),
        CallingBlock(
            id: "block-storm",
            name: "Pre-storm catch-up",
            dayLabel: "Before rain",
            dayOffset: -6,
            isOpen: false,
            calledSlipIds: ["slip-oak", "slip-dock"],
            leftoverNote: "Roof and deck before the front."
        ),
        CallingBlock(
            id: "block-decay",
            name: "Two-week decay",
            dayLabel: "Aging round",
            dayOffset: -8,
            isOpen: false,
            calledSlipIds: ["slip-hill"],
            leftoverNote: "Hill fence hit fourteen days."
        ),
        CallingBlock(
            id: "block-summer",
            name: "Summer exterior",
            dayLabel: "July stack",
            dayOffset: -20,
            isOpen: false,
            calledSlipIds: ["slip-barn", "slip-yard"],
            leftoverNote: "Exterior hours while the light holds."
        ),
        CallingBlock(
            id: "block-winter",
            name: "Indoor winter",
            dayLabel: "January stack",
            dayOffset: -40,
            isOpen: false,
            calledSlipIds: ["slip-loft", "slip-alley"],
            leftoverNote: "Fans and boilers when the paint work sleeps."
        ),
        CallingBlock(
            id: "block-ridge",
            name: "Ridge after rain",
            dayLabel: "Post-front",
            dayOffset: -7,
            isOpen: false,
            calledSlipIds: ["slip-ridge", "slip-oak"],
            leftoverNote: "Ridge cap still open. Oak deciding after the leak dried."
        ),
        CallingBlock(
            id: "block-creek",
            name: "Creek Saturday ask",
            dayLabel: "Weekend hold",
            dayOffset: -9,
            isOpen: false,
            calledSlipIds: ["slip-creek"],
            leftoverNote: "Fascia wrap asked for a Saturday start. Hold or pass at Friday noon."
        ),
    ]

    static let seedEvents: [ModuleEvent] = [
        ModuleEvent(id: "ev-1", blockId: "block-mon-am", padName: "Outcome Pad", summary: "Oak roof leak — Connected", dayOffset: 0),
        ModuleEvent(id: "ev-2", blockId: "block-mon-am", padName: "Quote Clock", summary: "River porch 7d vs 7-day window — Cold", dayOffset: 0),
        ModuleEvent(id: "ev-3", blockId: "block-tue-roof", padName: "Outcome Pad", summary: "Barn siding — No answer", dayOffset: -1),
        ModuleEvent(id: "ev-4", blockId: "block-wed-paint", padName: "Next Call", summary: "River porch pinned Saturday", dayOffset: -2),
        ModuleEvent(id: "ev-5", blockId: "block-thu-hvac", padName: "No-Answer Streak", summary: "Mill HVAC at 3 voicemails", dayOffset: -3),
        ModuleEvent(id: "ev-6", blockId: "block-fri-crew", padName: "Crew Fit", summary: "14 h vs 4 open quotes — will not clear", dayOffset: -4),
        ModuleEvent(id: "ev-7", blockId: "block-sat", padName: "Outcome Pad", summary: "Quarry gutters — Later", dayOffset: -5),
        ModuleEvent(id: "ev-8", blockId: "block-storm", padName: "Bid Age", summary: "Oak roof 3d, no decay", dayOffset: -6),
        ModuleEvent(id: "ev-9", blockId: "block-decay", padName: "Bid Age", summary: "Hill fence 14d — decay", dayOffset: -8),
        ModuleEvent(id: "ev-10", blockId: "block-month", padName: "Talk Cards", summary: "Copied porch-sitting line", dayOffset: -10),
        ModuleEvent(id: "ev-11", blockId: "block-summer", padName: "Outcome Pad", summary: "Yard trellis — No answer", dayOffset: -20),
        ModuleEvent(id: "ev-12", blockId: "block-winter", padName: "Outcome Pad", summary: "Loft bath fan — Booked", dayOffset: -40),
    ]

    static let seedTalkCards: [TalkCard] = [
        TalkCard(
            id: "talk-sitting",
            title: "Bid sitting",
            body: "It's [name] from the crew that left the quote on the porch. I still have that number if you want to lock a day before we reprint."
        ),
        TalkCard(
            id: "talk-storm",
            title: "Storm window",
            body: "Rain is in the forecast. If we start the roof / stain before it hits, we keep the same number. Want me to hold a morning?"
        ),
        TalkCard(
            id: "talk-voicemail",
            title: "Voicemail",
            body: "Calling about the quote at [site]. I'll try once more tomorrow, or text me a day that works."
        ),
        TalkCard(
            id: "talk-crew",
            title: "Crew this week",
            body: "We have leftover hours this week. Your job fits that hole if you want it on the calendar."
        ),
        TalkCard(
            id: "talk-decay",
            title: "Decay",
            body: "It's been two weeks on that quote. I can keep it as written through Friday, then I have to pull it."
        ),
        TalkCard(
            id: "talk-hours",
            title: "Leftover hours",
            body: "The crew finishes early Thursday. We can take a short one — fascia, door, fan — if you still want it."
        ),
        TalkCard(
            id: "talk-later",
            title: "Later this week",
            body: "You asked me to wait. Checking in as promised. Same number, same scope."
        ),
        TalkCard(
            id: "talk-saturday",
            title: "Saturday stop",
            body: "We can do a Saturday start if that's the only way this gets a yes. I can hold a half-day."
        ),
        TalkCard(
            id: "talk-reprint",
            title: "Reprint",
            body: "The number I left is two weeks old. I can reprint, or we lock the original if you still want the work."
        ),
        TalkCard(
            id: "talk-neighbor",
            title: "Same street",
            body: "We'll already be on your street for another job. If you want the fascia done that day, I can add it to the same trip."
        ),
        TalkCard(
            id: "talk-material",
            title: "Material hold",
            body: "Color and material are still quoted as written. I can hold that through Friday if you want the same number."
        ),
        TalkCard(
            id: "talk-short",
            title: "Short hole",
            body: "We have a two-hour hole Thursday. Your door / fan / fascia fits if you still want it."
        ),
    ]

    static let seedChecks: [MorningCheck] = [
        MorningCheck(id: "chk-start", title: "Start the calling block", isDone: false),
        MorningCheck(id: "chk-next", title: "Call the next cold bid", isDone: false),
        MorningCheck(id: "chk-log", title: "Log the outcome before the next dial", isDone: false),
        MorningCheck(id: "chk-pin", title: "Pin any later callback on the desk", isDone: false),
        MorningCheck(id: "chk-hand", title: "Copy the evening handoff", isDone: false),
    ]

    static func slip(id: String, in slips: [PersonSlip]) -> PersonSlip? {
        slips.first { $0.id == id }
    }

    static func block(id: String, in blocks: [CallingBlock]) -> CallingBlock? {
        blocks.first { $0.id == id }
    }
}
