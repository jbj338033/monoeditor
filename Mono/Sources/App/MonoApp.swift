import SwiftUI

@main
struct MonoApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .navigationTitle(appState.currentProject?.lastPathComponent ?? "")
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(
            width: Dimensions.windowDefaultWidth,
            height: Dimensions.windowDefaultHeight
        )
        .windowResizability(.contentMinSize)
        .commands {
            MonoCommands(appState: appState)
        }
    }
}
