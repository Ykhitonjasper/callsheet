import SwiftUI

struct CrewFitScreen: View {
    @Bindable var store: CallSheetStore
    @State private var hours = "14"
    @State private var quotes = "8"
    @State private var result: CrewFitResult?
    @State private var error: String?

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Crew Fit",
                subtitle: "Leftover hours this week versus open yes/no quotes."
            )

            NumberField(
                title: "Hours left",
                value: $hours,
                unit: "h",
                prompt: "14",
                help: "Crew hours still open this week",
                error: error
            )

            NumberField(
                title: "Open quotes",
                value: $quotes,
                unit: "jobs",
                prompt: "8",
                help: "Quotes still waiting on a yes or no"
            )

            CTAButton(
                title: "Compute",
                hint: "Checks whether leftover hours clear the stack"
            ) {
                compute()
            }

            if let result {
                ResultCard(
                    title: "Fit",
                    value: result.willClear ? "Clears" : "Short",
                    unit: String(format: "%.0f h", result.hours),
                    lines: [
                        ResultLine(label: "Open quotes", value: "\(result.openQuotes)"),
                        ResultLine(label: "Need ~", value: String(format: "%.0f h", Double(result.openQuotes) * 4.5)),
                    ],
                    note: result.line
                )

                CTAButton(
                    title: "Save into block",
                    emphasis: .secondary,
                    hint: "Stores leftover hours on the desk"
                ) {
                    store.saveCrewFit(result)
                }
                .sensoryFeedback(.success, trigger: store.didSave)
            }
        }
        .navigationTitle("Crew Fit")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            hours = String(format: "%.0f", store.crewHoursLeft)
            quotes = "\(store.openQuoteCount)"
        }
    }

    private func compute() {
        guard let parsedHours = Double(hours), parsedHours >= 0 else {
            error = "Hours must be a number."
            result = nil
            return
        }
        guard let parsedQuotes = Int(quotes), parsedQuotes >= 0 else {
            error = "Open quotes must be a whole number."
            result = nil
            return
        }
        error = nil
        result = BoardEngine.crewFit(hours: parsedHours, openQuotes: parsedQuotes)
    }
}

#Preview {
    NavigationStack {
        CrewFitScreen(store: AppDependencies.preview().store)
    }
}
