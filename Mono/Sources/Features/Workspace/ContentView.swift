import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

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
        .alert(
            isPresented: $appState.showErrorAlert,
            error: appState.currentError
        ) { _ in
            Button("OK", role: .cancel) {
                appState.currentError = nil
            }
        } message: { error in
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
            }
        }
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
                    TerminalContainerView()
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
        ZStack(alignment: .top) {
            if let tab = appState.activeTab {
                if tab.hasLoadError {
                    FileLoadErrorView(tab: tab)
                } else {
                    EditorView(tab: tab)
                }
            } else {
                EmptyEditorView()
            }

            if appState.isGoToLineVisible {
                GoToLineView()
                    .padding(.top, Spacing.md)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: AnimationDuration.fast), value: appState.isGoToLineVisible)
    }
}

struct FileLoadErrorView: View {
    let tab: EditorTab

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(ThemeColors.error)

            Text("Failed to load file")
                .font(Typography.ui)
                .foregroundStyle(ThemeColors.textPrimary)

            Text(tab.loadError ?? "Unknown error")
                .font(Typography.uiSmall)
                .foregroundStyle(ThemeColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            Text(tab.url.path)
                .font(Typography.uiSmall)
                .foregroundStyle(ThemeColors.textMuted)
                .lineLimit(2)
                .truncationMode(.middle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemeColors.backgroundPrimary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error loading \(tab.name): \(tab.loadError ?? "Unknown error")")
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
