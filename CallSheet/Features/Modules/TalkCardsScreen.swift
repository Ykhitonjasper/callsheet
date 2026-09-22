import SwiftUI

struct TalkCardsScreen: View {
    @Bindable var store: CallSheetStore

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Talk Cards",
                subtitle: store.pendingSlip.map { "Lines for \($0.siteName)" } ?? "Bid-follow scripts, not a chatbot"
            )

            ForEach(CallSheetSeed.seedTalkCards) { card in
                SectionCard(title: card.title) {
                    Text(filled(card.body))
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    CTAButton(
                        title: "Copy",
                        emphasis: .secondary,
                        hint: "Copies this line"
                    ) {
                        store.copyTalkCard(card)
                    }
                }
            }
        }
        .navigationTitle("Talk Cards")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: store.didSave)
    }

    private func filled(_ body: String) -> String {
        body.replacingOccurrences(of: "[site]", with: store.pendingSlip?.siteName ?? "the job")
    }
}

#Preview {
    NavigationStack {
        TalkCardsScreen(store: AppDependencies.preview().store)
    }
}
