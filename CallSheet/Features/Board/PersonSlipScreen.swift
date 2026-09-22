import SwiftUI

struct PersonSlipScreen: View {
    @Bindable var store: CallSheetStore
    let slipId: String
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScreenScaffold {
            if let slip = CallSheetSeed.slip(id: slipId, in: store.slips) {
                ScreenHeader(
                    title: slip.siteName,
                    subtitle: "\(slip.trade.title) · \(BoardEngine.heatCaption(slip))"
                )

                SectionCard {
                    DetailRow(label: "Last outcome", value: slip.lastOutcome.title, isProminent: true)
                    DetailRow(label: "Callback", value: BoardEngine.callbackCaption(slip))
                    DetailRow(label: "Voicemail streak", value: "\(slip.voicemailStreak)")
                    DetailRow(label: "Crew hours", value: String(format: "%.0f h", slip.crewHoursNeeded))
                    DetailRow(label: "Phone", value: displayPhone(slip.phoneDigits))
                }

                SectionCard(title: "Why this rank") {
                    ForEach(Array(BidMath.rankReasons(slip, crewHoursLeft: store.crewHoursLeft).enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    DetailRow(
                        label: "Hole",
                        value: BidMath.leftoverHole(hours: store.crewHoursLeft, slip: slip)
                    )
                    DetailRow(
                        label: "Storm",
                        value: BidMath.stormPriority(slip) ? "Roof/deck before rain" : "Not a storm job"
                    )
                    DetailRow(label: "Note", value: BidMath.shortNote(slip))
                    DetailRow(label: "Overdue", value: "\(BidMath.overdueDays(slip))d")
                    DetailRow(label: "Trade", value: BidMath.tradeTitle(slip.trade))
                    DetailRow(label: "Porch", value: BidMath.porchWindow(days: slip.lastQuoteDays, window: 7))
                }

                SectionCard(title: "Note") {
                    Text(slip.note)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                CTAButton(
                    title: "Call",
                    systemImage: "phone.fill",
                    hint: "Places a call to this job site"
                ) {
                    store.pendingSlipId = slip.id
                    store.markCalled(slip.id)
                    if let url = BoardEngine.phoneURL(slip.phoneDigits, scheme: "tel") {
                        openURL(url)
                    }
                    store.push(.pad(.outcome), on: store.selectedTab)
                }

                CTAButton(
                    title: "Text",
                    systemImage: "message",
                    emphasis: .secondary,
                    hint: "Opens a text to this job site"
                ) {
                    if let url = BoardEngine.phoneURL(slip.phoneDigits, scheme: "sms") {
                        openURL(url)
                    }
                }

                CTAButton(
                    title: "Log outcome",
                    emphasis: .secondary,
                    hint: "Opens the outcome pad for this slip"
                ) {
                    store.pendingSlipId = slip.id
                    store.push(.pad(.outcome), on: store.selectedTab)
                }
                .accessibilityIdentifier("smoke.slip.logOutcome")

                CTAButton(
                    title: "Pin next call",
                    emphasis: .secondary,
                    hint: "Dates a callback on the desk"
                ) {
                    store.pendingSlipId = slip.id
                    store.push(.pad(.nextCall), on: store.selectedTab)
                }
            } else {
                EmptyStateCard(
                    title: "Slip missing",
                    message: "That job site is no longer on the sheet.",
                    systemImage: "list.clipboard"
                )
            }
        }
        .navigationTitle("Slip")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func displayPhone(_ digits: String) -> String {
        let numbers = digits.filter(\.isNumber)
        guard numbers.count == 10 else { return digits }
        let area = numbers.prefix(3)
        let mid = numbers.dropFirst(3).prefix(3)
        let last = numbers.suffix(4)
        return "(\(area)) \(mid)-\(last)"
    }
}

#Preview {
    NavigationStack {
        PersonSlipScreen(store: AppDependencies.preview().store, slipId: "slip-river")
    }
}
