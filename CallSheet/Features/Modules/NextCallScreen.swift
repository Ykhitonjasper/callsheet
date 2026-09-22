import SwiftUI

struct NextCallScreen: View {
    @Bindable var store: CallSheetStore
    @State private var days = "1"
    @State private var error: String?

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Next Call",
                subtitle: store.pendingSlip.map { "Park \($0.siteName) back on the desk" } ?? "A dated row, not a banner"
            )

            if let slip = store.pendingSlip {
                SectionCard {
                    DetailRow(label: "Site", value: slip.siteName, isProminent: true)
                    DetailRow(label: "Now", value: BoardEngine.callbackCaption(slip))
                }
            } else {
                EmptyStateCard(
                    title: "No slip armed",
                    message: "Open a job site, then pin the callback.",
                    systemImage: "calendar"
                )
            }

            NumberField(
                title: "Days from today",
                value: $days,
                unit: "d",
                prompt: "1",
                help: "Zero means call today. Max 30.",
                error: error
            )

            CTAButton(
                title: "Pin callback",
                hint: "Dates this slip on the desk",
                isEnabled: store.pendingSlip != nil
            ) {
                save()
            }
            .sensoryFeedback(.success, trigger: store.didSave)
        }
        .navigationTitle("Next Call")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func save() {
        guard store.pendingSlip != nil else {
            error = "Arm a slip from Desk first."
            return
        }
        guard let parsed = Int(days), parsed >= 0, parsed <= 30 else {
            error = "Use 0 to 30 days."
            return
        }
        error = nil
        store.pinNextCall(days: parsed)
    }
}

#Preview {
    NavigationStack {
        NextCallScreen(store: AppDependencies.preview().store)
    }
}
