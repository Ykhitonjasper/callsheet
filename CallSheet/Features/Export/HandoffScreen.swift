import SwiftUI

struct HandoffScreen: View {
    @Bindable var store: CallSheetStore

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Evening Handoff",
                subtitle: store.openBlock.map { "Sheet for \($0.name)" } ?? "Last block on the list"
            )

            SectionCard {
                Text(handoff)
                    .font(.footnote.monospaced())
                    .foregroundStyle(AppTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }

            CTAButton(
                title: "Copy",
                hint: "Copies the handoff sheet"
            ) {
                store.copyHandoff()
            }
            .sensoryFeedback(.success, trigger: store.didSave)

            if !store.lastHandoff.isEmpty {
                DetailRow(label: "Pasteboard", value: "Copied", isProminent: true)
            }
        }
        .navigationTitle("Handoff")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if store.lastHandoff.isEmpty {
                store.copyHandoff()
            }
        }
    }

    private var handoff: String {
        if !store.lastHandoff.isEmpty { return store.lastHandoff }
        let block = store.openBlock ?? store.blocks.first
        guard let block else { return "No block to copy." }
        return BoardEngine.handoffText(block: block, slips: store.slips, events: store.events)
    }
}

#Preview {
    NavigationStack {
        HandoffScreen(store: AppDependencies.preview().store)
    }
}
