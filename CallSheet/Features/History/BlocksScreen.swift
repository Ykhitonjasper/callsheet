import SwiftUI

struct BlocksScreen: View {
    @Bindable var store: CallSheetStore

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Blocks",
                subtitle: "Calling sessions. Open one, then work the desk."
            )

            CTAButton(
                title: store.openBlock == nil ? "Start today's block" : "Evening handoff",
                hint: store.openBlock == nil ? "Opens Monday Bid AM" : "Copies the open block"
            ) {
                if store.openBlock == nil {
                    store.startBlock()
                } else {
                    store.push(.handoff, on: .blocks)
                }
            }

            ForEach(store.blocks) { block in
                NavigationRow(
                    title: block.name,
                    subtitle: block.dayLabel,
                    trailingText: block.isOpen ? "Open" : "\(block.calledSlipIds.count) called",
                    hint: "Opens this calling session"
                ) {
                    store.push(.block(block.id), on: .blocks)
                }
            }
        }
        .navigationTitle("Blocks")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        BlocksScreen(store: AppDependencies.preview().store)
    }
}
