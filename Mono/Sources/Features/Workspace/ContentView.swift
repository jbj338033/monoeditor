import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.currentProject != nil {
                MainEditorLayout()
            } else {
                WelcomeView()
            }
        }
        .frame(
            minWidth: Dimensions.windowMinWidth,
            minHeight: Dimensions.windowMinHeight
        )
        .background(ThemeColors.backgroundPrimary)
    }
}

struct MainEditorLayout: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HSplitView {
            if appState.isSidebarVisible {
                SidebarView()
                    .frame(
                        minWidth: Dimensions.sidebarMinWidth,
                        idealWidth: appState.sidebarWidth,
                        maxWidth: Dimensions.sidebarMaxWidth
                    )
            }

            VStack(spacing: 0) {
                TabBarView()

                EditorContainer()
                    .clipped()

                if appState.isTerminalVisible {
                    Divider()
                    TerminalView()
                        .frame(
                            minHeight: Dimensions.terminalMinHeight,
                            idealHeight: appState.terminalHeight,
                            maxHeight: Dimensions.terminalMaxHeight
                        )
                }

                StatusBarView()
                    .frame(height: Dimensions.statusBarHeight)
            }
        }
    }
}

struct EditorContainer: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if let tab = appState.activeTab {
            EditorView(tab: tab)
        } else {
            EmptyEditorView()
        }
    }
}

struct EmptyEditorView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "doc.text")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(ThemeColors.textMuted)

            Text("No file open")
                .font(Typography.ui)
                .foregroundStyle(ThemeColors.textSecondary)

            Text("Open a file from the sidebar")
                .font(Typography.uiSmall)
                .foregroundStyle(ThemeColors.textMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemeColors.backgroundPrimary)
    }
}
