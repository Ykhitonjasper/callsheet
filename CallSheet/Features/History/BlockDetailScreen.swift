import SwiftUI

struct BlockDetailScreen: View {
    @Bindable var store: CallSheetStore
    let blockId: String

    var body: some View {
        ScreenScaffold {
            if let block = CallSheetSeed.block(id: blockId, in: store.blocks) {
                ScreenHeader(
                    title: block.name,
                    subtitle: block.dayLabel + (block.isOpen ? " · Open" : "")
                )

                SectionCard {
                    DetailRow(label: "Called", value: "\(block.calledSlipIds.count) slips", isProminent: true)
                    DetailRow(label: "Day", value: block.dayOffset == 0 ? "Today" : "\(abs(block.dayOffset))d ago")
                }

                SectionCard(title: "Names called") {
                    ForEach(calledSlips(block)) { slip in
                        DetailRow(label: slip.siteName, value: slip.lastOutcome.title)
                    }
                    if calledSlips(block).isEmpty {
                        DetailRow(label: "List", value: "None yet")
                    }
                }

                SectionCard(title: "Pad notes") {
                    ForEach(notes(for: block)) { event in
                        DetailRow(label: event.padName, value: event.summary)
                    }
                    if notes(for: block).isEmpty {
                        DetailRow(label: "Notes", value: "None")
                    }
                }

                if !block.leftoverNote.isEmpty {
                    SectionCard(title: "Leftover") {
                        Text(block.leftoverNote)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                CTAButton(
                    title: "Handoff",
                    hint: "Copies an evening sheet for this block"
                ) {
                    store.focusBlock(block.id)
                    store.push(.handoff, on: .blocks)
                }
            } else {
                EmptyStateCard(
                    title: "Block missing",
                    message: "That session is no longer on the sheet.",
                    systemImage: "calendar"
                )
            }
        }
        .navigationTitle("Block")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func calledSlips(_ block: CallingBlock) -> [PersonSlip] {
        store.slips.filter { block.calledSlipIds.contains($0.id) }
    }

    private func notes(for block: CallingBlock) -> [ModuleEvent] {
        store.events.filter { $0.blockId == block.id }
    }
}

#Preview {
    NavigationStack {
        BlockDetailScreen(store: AppDependencies.preview().store, blockId: "block-mon-am")
    }
}
