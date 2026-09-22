import SwiftUI

struct NewSlipScreen: View {
    @Bindable var store: CallSheetStore
    @State private var siteName = ""
    @State private var days = "7"
    @State private var hours = "4"
    @State private var phone = "5550101999"
    @State private var trade = Trade.paint.rawValue
    @State private var error: String?

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Add a slip",
                subtitle: "A job site nickname, not a contact card."
            )

            SectionCard {
                NumberField(
                    title: "Days on bid",
                    value: $days,
                    unit: "d",
                    prompt: "7",
                    help: "How long the quote has been sitting",
                    error: error
                )
                NumberField(
                    title: "Crew hours",
                    value: $hours,
                    unit: "h",
                    prompt: "4"
                )
            }

            SectionCard(title: "Trade") {
                ChipRow {
                    ForEach(Trade.allCases) { item in
                        FilterChip(title: item.title, isSelected: trade == item.rawValue) {
                            trade = item.rawValue
                        }
                    }
                }
            }

            SectionCard(title: "Site") {
                TextField("River porch paint", text: $siteName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(.vertical, AppMetrics.inputVerticalPadding)
                    .accessibilityLabel("Site name")
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textPrimary)
                    .accessibilityLabel("Phone digits")
            }

            CTAButton(
                title: "Save slip",
                hint: "Adds this job site to the desk"
            ) {
                save()
            }
            .sensoryFeedback(.success, trigger: store.didSave)
        }
        .navigationTitle("New slip")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func save() {
        let parsedDays = Int(days) ?? -1
        let parsedHours = Double(hours) ?? -1
        if siteName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            error = "Name the job site."
            return
        }
        if parsedDays < 0 {
            error = "Days must be a number."
            return
        }
        error = nil
        let picked = Trade(rawValue: trade) ?? .paint
        store.addSlip(siteName: siteName, trade: picked, phone: phone, days: parsedDays, hours: max(0, parsedHours))
        store.deskPath = []
    }
}

#Preview {
    NavigationStack {
        NewSlipScreen(store: AppDependencies.preview().store)
    }
}
