import SwiftUI

@main
struct MonoApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: Icons.folder)
                                .foregroundStyle(ThemeColors.textSecondary)
                            if let project = appState.currentProject {
                                Text(project.lastPathComponent)
                                    .font(Typography.uiBold)
                                    .foregroundStyle(ThemeColors.textPrimary)
                            }
                        }
                    }
                }
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
