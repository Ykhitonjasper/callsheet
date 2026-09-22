import SwiftUI

struct PadsHubScreen: View {
    @Bindable var store: CallSheetStore

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Pads",
                subtitle: store.pendingSlip.map { "Armed: \($0.siteName)" } ?? "Pick a pad, then a slip"
            )

            ForEach(CallSheetSeed.seedModules) { module in
                NavigationRow(
                    title: module.name,
                    subtitle: module.blurb,
                    trailingText: module.hint,
                    hint: "Opens \(module.name)"
                ) {
                    store.push(.pad(module.kind), on: .pads)
                }
            }

            SectionCard(title: "Armed slip") {
                if let slip = store.pendingSlip {
                    DetailRow(label: "Site", value: slip.siteName, isProminent: true)
                    DetailRow(label: "Heat", value: BoardEngine.heatCaption(slip))
                    DetailRow(label: "Last", value: slip.lastOutcome.title)
                } else {
                    DetailRow(label: "Site", value: "Top of the ranked desk")
                }
            }
        }
        .navigationTitle("Pads")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PadsHubScreen(store: AppDependencies.preview().store)
    }
}
