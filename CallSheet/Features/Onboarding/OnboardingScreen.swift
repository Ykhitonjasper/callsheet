import SwiftUI

struct OnboardingScreen: View {
    @Bindable var store: CallSheetStore
    @State private var page = 0

    var body: some View {
        ScreenScaffold(scrolls: false) {
            Group {
                switch page {
                case 0:
                    ScreenHeader(
                        title: "Who do I call before this bid goes cold.",
                        subtitle: "Porch quotes for paint, roof, and HVAC — ranked for the morning block."
                    )
                case 1:
                    ScreenHeader(
                        title: "Start the block. Call the next name.",
                        subtitle: "Log connected, voicemail, or later before you dial again. Phone places the call."
                    )
                default:
                    ScreenHeader(
                        title: "The call sheet stays on this phone.",
                        subtitle: "Delete All Data clears the slips and brings this introduction back."
                    )
                }
            }

            SectionCard {
                DetailRow(label: "Slips", value: "\(CallSheetSeed.seedSlips.count) job sites")
                DetailRow(label: "Blocks", value: "\(CallSheetSeed.seedBlocks.count) calling sessions")
                DetailRow(label: "Pads", value: "\(CallSheetSeed.seedModules.count) tools", isProminent: true)
            }

            if page == 1 {
                SectionCard(title: "This morning") {
                    DetailRow(label: "Next", value: CallSheetSeed.seedSlips[0].siteName)
                    DetailRow(label: "Heat", value: "7 days on the porch")
                    DetailRow(label: "Place", value: "Phone.app via Call next")
                }
            }

            Spacer(minLength: 0)

            CTAButton(
                title: page >= 2 ? "Get started" : "Continue",
                hint: page >= 2 ? "Opens the calling desk" : "Shows the next page"
            ) {
                if page >= 2 {
                    store.completeOnboarding()
                } else {
                    page += 1
                }
            }
            .accessibilityIdentifier(page >= 2 ? "onboarding-finish" : "onboarding-next")
        }
        .sensoryFeedback(.selection, trigger: page)
    }
}

#Preview {
    OnboardingScreen(store: CallSheetStore(preview: true))
}
