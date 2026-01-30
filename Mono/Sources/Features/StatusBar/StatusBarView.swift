import SwiftUI

struct StatusBarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack(spacing: Spacing.md) {
            if let tab = appState.activeTab {
                Text(languageLabel(for: tab.fileExtension))
                    .font(Typography.statusBar)
                    .foregroundStyle(ThemeColors.textSecondary)

                StatusDivider()

                Text("Line \(appState.cursorLine), Column \(appState.cursorColumn)")
                    .font(Typography.statusBar)
                    .foregroundStyle(ThemeColors.textSecondary)

                StatusDivider()

                Text("UTF-8")
                    .font(Typography.statusBar)
                    .foregroundStyle(ThemeColors.textSecondary)
            }

            Spacer()

            if appState.activeTab?.isModified == true {
                HStack(spacing: Spacing.xs) {
                    Circle()
                        .fill(ThemeColors.modified)
                        .frame(width: 6, height: 6)
                    Text("Modified")
                        .font(Typography.statusBar)
                        .foregroundStyle(ThemeColors.modified)
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(ThemeColors.backgroundSecondary)
    }

    private func languageLabel(for ext: String) -> String {
        Language.from(extension: ext)?.displayName ?? (ext.isEmpty ? "Plain Text" : ext.uppercased())
    }
}

struct StatusDivider: View {
    var body: some View {
        Rectangle()
            .fill(ThemeColors.textMuted.opacity(0.5))
            .frame(width: 1, height: 12)
    }
}
