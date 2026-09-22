import SwiftUI

struct StreakScreen: View {
    @Bindable var store: CallSheetStore

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "No-Answer Streak",
                subtitle: "Three voicemails demote a slip unless leftover hours are short."
            )

            if let slip = store.pendingSlip {
                ResultCard(
                    title: "Streak",
                    value: "\(slip.voicemailStreak)",
                    unit: slip.voicemailStreak == 1 ? "voicemail" : "voicemails",
                    lines: [
                        ResultLine(label: "Site", value: slip.siteName),
                        ResultLine(label: "Crew week", value: store.crewHoursLeft < 8 ? "Short" : "Open"),
                        ResultLine(label: "Last", value: slip.lastOutcome.title),
                    ],
                    note: BoardEngine.streakLine(streak: slip.voicemailStreak, crewShort: store.crewHoursLeft < 8)
                )

                CTAButton(
                    title: "Save into block",
                    hint: "Writes the streak advice onto the open block"
                ) {
                    store.saveStreakNote()
                }
                .sensoryFeedback(.success, trigger: store.didSave)
            } else {
                EmptyStateCard(
                    title: "No slip armed",
                    message: "Open Mill HVAC or another voicemail row first.",
                    systemImage: "phone.down"
                )
            }

            SectionCard(title: "How it ranks") {
                DetailRow(label: "0–2", value: "Stay in order")
                DetailRow(label: "3+ and hours open", value: "Demote")
                DetailRow(label: "3+ and week short", value: "Keep calling", isProminent: true)
            }
        }
        .navigationTitle("Streak")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        StreakScreen(store: AppDependencies.preview().store)
    }
}
