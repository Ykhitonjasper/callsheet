import SwiftUI

struct SettingsScreen: View {
    @Bindable var store: CallSheetStore
    @Environment(\.openURL) private var openURL
    @State private var confirmDelete = false

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: AppTheme.displayName,
                subtitle: "Bid callbacks · v\(bundleVersion)"
            )

            SectionCard(title: "On this phone") {
                DetailRow(label: "App", value: AppTheme.displayName, isProminent: true)
                DetailRow(label: "Slips", value: "\(store.slips.count) job sites")
                DetailRow(label: "Blocks", value: "\(store.blocks.count) sessions")
                DetailRow(label: "Storage", value: "The call sheet stays on this iPhone")
                DetailRow(label: "Calls", value: "Phone.app places them. This desk only stores the list.")
                DetailRow(label: "Reminders", value: "Dated rows on Desk, not a banner")
                DetailRow(label: "Book", value: "Paint, roof, HVAC porch quotes")
            }

            SectionCard {
                Button {
                    if let url = Legal.privacy { openURL(url) }
                } label: {
                    DetailRow(label: "Privacy", value: "Policy")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Privacy")

                Button {
                    if let url = Legal.terms { openURL(url) }
                } label: {
                    DetailRow(label: "Terms", value: "Use")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Terms")
            }

            SectionCard(
                title: "Delete All Data",
                footnote: "Clears slips, blocks, and pad notes, then brings the introduction back."
            ) {
                DetailRow(
                    label: "Stored",
                    value: "\(store.slips.count) slips · \(store.blocks.count) blocks",
                    isProminent: true
                )
                CTAButton(
                    title: "Delete All Data",
                    systemImage: "trash",
                    emphasis: .secondary,
                    hint: "Asks before clearing this phone copy"
                ) {
                    confirmDelete = true
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete All Data",
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button("Delete All Data", role: .destructive) {
                store.deleteAll()
            }
            Button("Keep sheet", role: .cancel) {}
        } message: {
            Text("This removes the local call sheet, then returns to the introduction.")
        }
        .sensoryFeedback(.warning, trigger: confirmDelete)
    }

    private var bundleVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let trimmed = (version ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "1.0" : trimmed
    }
}

#Preview {
    NavigationStack {
        SettingsScreen(store: AppDependencies.preview().store)
    }
}
