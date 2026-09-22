import SwiftUI

struct SaturdayFitScreen: View {
    @Bindable var store: CallSheetStore
    @State private var hours = "8"
    @State private var wanted = "2"
    @State private var result: SaturdayFitResult?
    @State private var error: String?

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Saturday Fit",
                subtitle: "Hold a half-day only if leftover Saturday hours cover the asks."
            )

            NumberField(
                title: "Saturday hours",
                value: $hours,
                unit: "h",
                prompt: "8",
                help: "Crew hours you are willing to work Saturday",
                error: error
            )

            NumberField(
                title: "Half-days wanted",
                value: $wanted,
                unit: "jobs",
                prompt: "2",
                help: "Slips that only go if Saturday is held"
            )

            CTAButton(
                title: "Compute",
                hint: "Checks whether Saturday hours cover the asks"
            ) {
                compute()
            }

            if let result {
                ResultCard(
                    title: "Saturday",
                    value: result.willHold ? "Hold" : "Pass",
                    unit: String(format: "%.0f h", result.saturdayHours),
                    lines: [
                        ResultLine(label: "Asks", value: "\(result.halfDaysWanted)"),
                        ResultLine(label: "Capacity", value: "\(Int(result.saturdayHours / 4)) half-days"),
                    ],
                    note: result.line
                )

                CTAButton(
                    title: "Save into block",
                    emphasis: .secondary,
                    hint: "Writes Saturday fit onto the open block"
                ) {
                    store.saveSaturdayFit(result)
                }
                .sensoryFeedback(.success, trigger: store.didSave)
            }

            SectionCard(title: "Who asked") {
                ForEach(saturdayAsks) { slip in
                    DetailRow(label: slip.siteName, value: BoardEngine.callbackCaption(slip))
                }
                if saturdayAsks.isEmpty {
                    DetailRow(label: "Asks", value: "None on this sheet")
                }
            }
        }
        .navigationTitle("Saturday Fit")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            wanted = "\(BidMath.saturdayWanted(in: store.slips))"
        }
    }

    private var saturdayAsks: [PersonSlip] {
        store.slips.filter { BidMath.weekendHold(slip: $0) && !$0.booked }
    }

    private func compute() {
        guard let parsedHours = Double(hours), parsedHours >= 0 else {
            error = "Hours must be a number."
            result = nil
            return
        }
        guard let parsedWanted = Int(wanted), parsedWanted >= 0 else {
            error = "Half-days must be a whole number."
            result = nil
            return
        }
        error = nil
        result = BidMath.saturdayFit(hours: parsedHours, halfDaysWanted: parsedWanted)
    }
}

#Preview {
    NavigationStack {
        SaturdayFitScreen(store: AppDependencies.preview().store)
    }
}
