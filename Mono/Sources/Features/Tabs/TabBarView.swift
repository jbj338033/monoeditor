import SwiftUI

struct TabBarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(appState.openTabs) { tab in
                    TabItemView(
                        tab: tab,
                        isActive: tab.id == appState.activeTabId
                    )
                }
            }
            .padding(.horizontal, Spacing.sm)
        }
        .frame(height: Dimensions.tabBarHeight)
        .frame(maxWidth: .infinity)
        .background(ThemeColors.backgroundSecondary)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(ThemeColors.textMuted.opacity(0.3))
                .frame(height: 1)
        }
    }
}

struct TabItemView: View {
    @Environment(AppState.self) private var appState
    let tab: EditorTab
    let isActive: Bool
    @State private var isHovering = false

    var body: some View {
        Button {
            appState.activeTabId = tab.id
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: Icons.forFileExtension(tab.fileExtension))
                    .font(.system(size: 12))
                    .foregroundStyle(isActive ? ThemeColors.textPrimary : ThemeColors.textSecondary)

                Text(tab.name)
                    .font(Typography.tabTitle)
                    .foregroundStyle(isActive ? ThemeColors.textPrimary : ThemeColors.textSecondary)
                    .lineLimit(1)

                if tab.isModified {
                    Circle()
                        .fill(ThemeColors.modified)
                        .frame(width: 6, height: 6)
                } else if isHovering {
                    closeButton
                } else {
                    Spacer()
                        .frame(width: Dimensions.tabCloseButtonSize)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .frame(minWidth: Dimensions.tabMinWidth, maxWidth: Dimensions.tabMaxWidth)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isActive ? ThemeColors.backgroundPrimary : (isHovering ? ThemeColors.backgroundTertiary : Color.clear))
        )
        .animation(.easeOut(duration: AnimationDuration.instant), value: isHovering)
        .animation(.easeOut(duration: AnimationDuration.instant), value: isActive)
        .onHover { isHovering = $0 }
        .contextMenu {
            Button("Close") { appState.closeTab(tab.id) }
            Button("Close Others") {
                appState.openTabs.filter { $0.id != tab.id }.forEach { appState.closeTab($0.id) }
            }
            Button("Close All") { appState.closeAllTabs() }
        }
    }

    private var closeButton: some View {
        Button {
            appState.closeTab(tab.id)
        } label: {
            Image(systemName: Icons.close)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(ThemeColors.textMuted)
                .frame(width: Dimensions.tabCloseButtonSize, height: Dimensions.tabCloseButtonSize)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
