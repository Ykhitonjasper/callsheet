import SwiftUI

struct BidAgeScreen: View {
    @Bindable var store: CallSheetStore
    @State private var days = "7"
    @State private var result: BidAgeResult?
    @State private var error: String?

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Bid Age",
                subtitle: store.pendingSlip.map { "\($0.siteName) without a yes or no" } ?? "Days sitting, decay at 14"
            )

            NumberField(
                title: "Days without yes/no",
                value: $days,
                unit: "d",
                prompt: "14",
                help: "Fourteen days raises a decay flag",
                error: error
            )

            CTAButton(
                title: "Compute",
                hint: "Reads decay against fourteen days"
            ) {
                compute()
            }

            if let result {
                ResultCard(
                    title: "Age",
                    value: result.decay ? "Decay" : "Live",
                    unit: "\(result.days)d",
                    lines: [
                        ResultLine(label: "Site", value: store.pendingSlip?.siteName ?? "Open quote"),
                        ResultLine(label: "Flag", value: result.decay ? "Pull or call" : "Still a live quote"),
                        ResultLine(label: "Reprint", value: BidMath.reprintCost(days: result.days).reprint ? "Stale" : "Stands"),
                    ],
                    note: result.line + " " + BidMath.reprintCost(days: result.days).line
                )

                CTAButton(
                    title: "Save into block",
                    emphasis: .secondary,
                    hint: "Writes bid age onto the open block"
                ) {
                    store.saveBidAge(result)
                }
                .sensoryFeedback(.success, trigger: store.didSave)
            }
        }
        .navigationTitle("Bid Age")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            days = "\(store.pendingSlip?.lastQuoteDays ?? 7)"
        }
    }

    private func compute() {
        guard let parsed = Int(days), parsed >= 0 else {
            error = "Enter days as a whole number."
            result = nil
            return
        }
        error = nil
        result = BoardEngine.bidAge(days: parsed)
    }
}

#Preview {
    NavigationStack {
        BidAgeScreen(store: AppDependencies.preview().store)
    }
}
