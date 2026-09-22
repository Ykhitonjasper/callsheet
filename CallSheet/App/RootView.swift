import SwiftUI

struct RootView: View {
    private let dependencies: AppDependencies
    @Bindable private var store: CallSheetStore

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        store = dependencies.store
    }

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
                tabShell
            } else {
                OnboardingScreen(store: store)
            }
        }
        .tint(AppTheme.accent)
    }

    private var tabShell: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack(path: $store.deskPath) {
                DeskScreen(store: store)
                    .navigationDestination(for: AppRoute.self) { route in
                        routed(route)
                    }
            }
            .tabItem { Label(AppTab.desk.label, systemImage: AppTab.desk.systemImage) }
            .tag(AppTab.desk)

            NavigationStack(path: $store.padsPath) {
                PadsHubScreen(store: store)
                    .navigationDestination(for: AppRoute.self) { route in
                        routed(route)
                    }
            }
            .tabItem { Label(AppTab.pads.label, systemImage: AppTab.pads.systemImage) }
            .tag(AppTab.pads)

            NavigationStack(path: $store.blocksPath) {
                BlocksScreen(store: store)
                    .navigationDestination(for: AppRoute.self) { route in
                        routed(route)
                    }
            }
            .tabItem { Label(AppTab.blocks.label, systemImage: AppTab.blocks.systemImage) }
            .tag(AppTab.blocks)

            NavigationStack {
                SettingsScreen(store: store)
            }
            .tabItem { Label(AppTab.settings.label, systemImage: AppTab.settings.systemImage) }
            .tag(AppTab.settings)
        }
    }

    @ViewBuilder
    private func routed(_ route: AppRoute) -> some View {
        switch route {
        case .slip(let id):
            PersonSlipScreen(store: store, slipId: id)
        case .pad(let kind):
            padScreen(kind)
        case .block(let id):
            BlockDetailScreen(store: store, blockId: id)
        case .handoff:
            HandoffScreen(store: store)
        case .newSlip:
            NewSlipScreen(store: store)
        }
    }

    @ViewBuilder
    private func padScreen(_ kind: PadKind) -> some View {
        switch kind {
        case .quoteClock: QuoteClockScreen(store: store)
        case .crewFit: CrewFitScreen(store: store)
        case .bidAge: BidAgeScreen(store: store)
        case .outcome: OutcomePadScreen(store: store)
        case .nextCall: NextCallScreen(store: store)
        case .talkCards: TalkCardsScreen(store: store)
        case .streak: StreakScreen(store: store)
        case .saturdayFit: SaturdayFitScreen(store: store)
        }
    }
}

#Preview("Onboarding") {
    RootView(dependencies: AppDependencies(store: CallSheetStore()))
}

#Preview("Tabs") {
    RootView(dependencies: .preview())
}
