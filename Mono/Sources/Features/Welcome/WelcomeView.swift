import SwiftUI

struct WelcomeView: View {
    @Environment(AppState.self) private var appState
    @State private var recentService = RecentFoldersService()

    var body: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()

            Text("Mono")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(ThemeColors.textPrimary)

            VStack(spacing: Spacing.sm) {
                WelcomeButton(
                    title: "Open Folder",
                    systemImage: "folder",
                    shortcut: "⌘O"
                ) {
                    openFolder()
                }

                if !recentService.folders.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Recent")
                            .font(Typography.uiSmall)
                            .foregroundStyle(ThemeColors.textMuted)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.top, Spacing.md)

                        ForEach(recentService.folders, id: \.self) { url in
                            RecentFolderButton(url: url) {
                                appState.setProject(url)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: 320)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemeColors.backgroundPrimary)
        .onAppear {
            recentService.load()
        }
    }

    private func openFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false

        if panel.runModal() == .OK, let url = panel.url {
            appState.setProject(url)
            recentService.add(url)
        }
    }
}

struct WelcomeButton: View {
    let title: String
    let systemImage: String
    let shortcut: String
    let action: () -> Void

    @State private var isHovered = false
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 14))
                    .foregroundStyle(ThemeColors.textPrimary)
                    .frame(width: 20)

                Text(title)
                    .font(Typography.ui)
                    .foregroundStyle(ThemeColors.textPrimary)

                Spacer()

                Text(shortcut)
                    .font(Typography.uiSmall)
                    .foregroundStyle(ThemeColors.textMuted)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isPressed ? ThemeColors.backgroundHover : (isHovered ? ThemeColors.backgroundTertiary : ThemeColors.backgroundSecondary))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(ThemeColors.textMuted.opacity(0.2), lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeOut(duration: 0.1), value: isPressed)
        .animation(.easeOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct RecentFolderButton: View {
    let url: URL
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: Icons.folder)
                    .font(.system(size: 13))
                    .foregroundStyle(ThemeColors.textSecondary)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: 1) {
                    Text(url.lastPathComponent)
                        .font(Typography.sidebarItem)
                        .foregroundStyle(ThemeColors.textPrimary)
                        .lineLimit(1)

                    Text(url.deletingLastPathComponent().path)
                        .font(Typography.uiSmall)
                        .foregroundStyle(ThemeColors.textMuted)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                Spacer()

                if isHovered {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(ThemeColors.textMuted)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? ThemeColors.backgroundTertiary : Color.clear)
        )
        .animation(.easeOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
