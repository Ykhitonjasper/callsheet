import SwiftUI

@main
@MainActor
struct CallSheetApp: App {
    @State private var dependencies = AppDependencies.live()

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
        }
    }
}
