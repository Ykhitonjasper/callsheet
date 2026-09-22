import SwiftUI

struct DeskScreen: View {
    @Bindable var store: CallSheetStore
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Who do I call before this bid goes cold?",
                subtitle: store.openBlock.map { "Open: \($0.name)" } ?? "No block open yet"
            )

            ChipRow {
                ForEach(DeskFilter.allCases) { filter in
                    FilterChip(title: filter.title, isSelected: store.filter == filter) {
                        store.selectFilter(filter)
                    }
                }
            }

            CTAButton(
                title: "Call next",
                systemImage: "phone.fill",
                hint: "Places a call to the top ranked job site"
            ) {
                callNext()
            }
            .accessibilityIdentifier("call-next")
            .sensoryFeedback(.impact, trigger: store.didSave)

            if store.openBlock == nil {
                CTAButton(
                    title: "Start block",
                    emphasis: .secondary,
                    hint: "Opens today's calling block"
                ) {
                    store.startBlock()
                }
                .accessibilityIdentifier("smoke.desk.startBlock")
            } else {
                Text("Open: \(store.openBlock?.name ?? "")")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .accessibilityIdentifier("smoke.desk.blockOpen")
            }

            TileGrid {
                ForEach(store.readings) { reading in
                    StatusTile(
                        station: reading.station,
                        reading: reading.reading,
                        stamp: reading.stamp,
                        state: tileState(reading.state)
                    )
                }
            }

            if store.rankedSlips.isEmpty {
                EmptyStateCard(
                    title: "Nobody in this stack",
                    message: "Try another chip. Bid cold is the morning default.",
                    systemImage: "list.clipboard"
                )
            } else {
                ForEach(Array(store.rankedSlips.enumerated()), id: \.element.id) { index, slip in
                    slipRow(slip, tagged: index == 0)
                }
            }

            SectionCard(title: "Chips") {
                DetailRow(label: "Bid cold", value: "Seven days or more on the porch")
                DetailRow(label: "Crew open", value: "Hours left cover this job")
                DetailRow(label: "Voicemail", value: "Last outcome or a streak")
                DetailRow(label: "Call later", value: "Dated callback still in the future", isProminent: true)
            }

            SectionCard(title: "Morning checks") {
                ForEach(store.checks) { check in
                    NavigationRow(
                        title: check.title,
                        trailingText: check.isDone ? "Done" : "Open",
                        hint: "Marks this check"
                    ) {
                        store.toggleCheck(check.id)
                    }
                }
            }

            CTAButton(
                title: "Add slip",
                emphasis: .secondary,
                hint: "Types a new job site onto the desk"
            ) {
                store.push(.newSlip, on: .desk)
            }
        }
        .navigationTitle("Desk")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func slipRow(_ slip: PersonSlip, tagged: Bool) -> some View {
        HStack(alignment: .top, spacing: AppMetrics.contentSpacing) {
            NavigationRow(
                title: slip.siteName,
                subtitle: BoardEngine.heatCaption(slip),
                trailingText: BoardEngine.callbackCaption(slip),
                hint: "Opens this job site slip"
            ) {
                store.openSlip(slip.id, on: .desk)
            }
            .accessibilityIdentifier(tagged ? "smoke.desk.openSlip" : "slip-\(slip.id)")

            Button {
                store.pendingSlipId = slip.id
                store.markCalled(slip.id)
                if let url = BoardEngine.phoneURL(slip.phoneDigits, scheme: "tel") {
                    openURL(url)
                }
            } label: {
                Image(systemName: "phone.fill")
                    .font(.headline)
                    .foregroundStyle(AppTheme.bgBase)
                    .padding(AppMetrics.contentSpacing)
                    .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Call \(slip.siteName)")
        }
    }

    private func callNext() {
        store.ensureBlock()
        guard let slip = store.nextSlip else { return }
        store.pendingSlipId = slip.id
        store.markCalled(slip.id)
        if let url = BoardEngine.phoneURL(slip.phoneDigits, scheme: "tel") {
            openURL(url)
        }
        store.push(.pad(.outcome), on: .desk)
    }

    private func tileState(_ kind: StatusKind) -> StatusTile.State {
        switch kind {
        case .ok: return .ok
        case .watch: return .watch
        case .fault: return .fault
        }
    }
}

#Preview {
    NavigationStack {
        DeskScreen(store: AppDependencies.preview().store)
    }
}
