import SwiftUI

struct QuoteClockScreen: View {
    @Bindable var store: CallSheetStore
    @State private var days = "7"
    @State private var window = "7"
    @State private var result: QuoteClockResult?
    @State private var error: String?

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Quote Clock",
                subtitle: store.pendingSlip.map { "\($0.siteName) sitting on the porch" } ?? "Days vs a 3 / 7 / 14 window"
            )

            NumberField(
                title: "Days sitting",
                value: $days,
                unit: "d",
                prompt: "7",
                help: "Days since the bid was left",
                error: error
            )

            SegmentedPicker(
                title: "Cold window",
                options: [
                    SegmentOption("3 day", id: "3"),
                    SegmentOption("7 day", id: "7"),
                    SegmentOption("14 day", id: "14"),
                ],
                selection: $window,
                help: "When this trade treats a quote as cold"
            )

            CTAButton(
                title: "Compute",
                hint: "Reads heat against the window"
            ) {
                compute()
            }

            if let result {
                ResultCard(
                    title: "Heat",
                    value: result.heat.title,
                    unit: "\(result.days)d",
                    lines: [
                        ResultLine(label: "Window", value: "\(result.window) days"),
                        ResultLine(label: "Site", value: store.pendingSlip?.siteName ?? "Open quote"),
                    ],
                    note: result.line
                )

                CTAButton(
                    title: "Save into block",
                    emphasis: .secondary,
                    hint: "Writes this clock onto the open block"
                ) {
                    store.saveQuoteClock(result)
                }
                .sensoryFeedback(.success, trigger: store.didSave)
            }
        }
        .navigationTitle("Quote Clock")
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
        let win = Int(window) ?? 7
        result = BoardEngine.quoteClock(days: parsed, window: win)
    }
}

#Preview {
    NavigationStack {
        QuoteClockScreen(store: AppDependencies.preview().store)
    }
}
