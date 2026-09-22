import SwiftUI

struct OutcomePadScreen: View {
    @Bindable var store: CallSheetStore
    @State private var outcome = CallOutcome.voicemail.rawValue
    @State private var note = ""
    @State private var error: String?

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Outcome Pad",
                subtitle: store.pendingSlip.map { "Last dial: \($0.siteName)" } ?? "Log before the next dial"
            )

            if let slip = store.pendingSlip {
                SectionCard {
                    DetailRow(label: "Site", value: slip.siteName, isProminent: true)
                    DetailRow(label: "Was", value: slip.lastOutcome.title)
                    DetailRow(label: "Streak", value: "\(slip.voicemailStreak)")
                }
            } else {
                EmptyStateCard(
                    title: "No slip armed",
                    message: "Call next on Desk or open a job site first.",
                    systemImage: "phone"
                )
            }

            SectionCard(title: "This call") {
                ChipRow {
                    ForEach(CallOutcome.allCases) { item in
                        FilterChip(title: item.title, isSelected: outcome == item.rawValue) {
                            outcome = item.rawValue
                        }
                    }
                }
            }

            SectionCard(title: "Note") {
                TextField("What they said", text: $note, axis: .vertical)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(3...6)
                    .accessibilityLabel("Outcome note")
                if let error {
                    InlineError(message: error)
                }
            }

            CTAButton(
                title: "Save outcome",
                hint: "Writes this outcome into the open block",
                isEnabled: store.pendingSlip != nil
            ) {
                save()
            }
            .accessibilityIdentifier("smoke.outcome.save")
            .sensoryFeedback(.success, trigger: store.didSave)

            if !store.lastLoggedSummary.isEmpty {
                Text(store.lastLoggedSummary)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .accessibilityIdentifier("smoke.outcome.logged")
            }
        }
        .navigationTitle("Outcome")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func save() {
        guard store.pendingSlip != nil else {
            error = "Arm a slip from Desk first."
            return
        }
        guard let picked = CallOutcome(rawValue: outcome) else {
            error = "Pick an outcome."
            return
        }
        error = nil
        store.logOutcome(picked, note: note)
    }
}

#Preview {
    NavigationStack {
        OutcomePadScreen(store: AppDependencies.preview().store)
    }
}
