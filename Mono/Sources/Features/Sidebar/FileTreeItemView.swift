import SwiftUI

struct FileTreeItemView: View {
    @Environment(AppState.self) private var appState
    @Bindable var item: FileItem
    let model: FileTreeModel
    let depth: Int

    @State private var isHovering = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                handleClick()
            } label: {
                HStack(spacing: Spacing.sm) {
                    if item.isDirectory {
                        Image(systemName: item.isExpanded ? Icons.chevronDown : Icons.chevronRight)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(ThemeColors.textSecondary)
                            .frame(width: 10)
                    } else {
                        Spacer()
                            .frame(width: 10)
                    }

                    Image(systemName: item.icon)
                        .font(.system(size: 13))
                        .foregroundStyle(item.isDirectory ? ThemeColors.textSecondary : ThemeColors.textMuted)
                        .frame(width: 16)

                    Text(item.name)
                        .font(Typography.sidebarItem)
                        .foregroundStyle(isHovering ? ThemeColors.textPrimary : (item.isDirectory ? ThemeColors.textPrimary : ThemeColors.textSecondary))
                        .lineLimit(1)

                    Spacer()
                }
                .padding(.leading, CGFloat(depth) * Dimensions.sidebarIndent + Spacing.sm)
                .padding(.trailing, Spacing.sm)
                .frame(height: Dimensions.sidebarItemHeight)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isHovering ? ThemeColors.backgroundHover : Color.clear)
                    .padding(.horizontal, 4)
            )
            .onHover { hovering in
                withAnimation(.easeOut(duration: 0.1)) {
                    isHovering = hovering
                }
            }
            .contextMenu {
                if item.isDirectory {
                    Button("New File") {
                        // TODO: New file in folder
                    }
                    Button("New Folder") {
                        // TODO: New folder
                    }
                    Divider()
                }
                Button("Rename") {
                    // TODO: Rename
                }
                Button("Delete", role: .destructive) {
                    // TODO: Delete
                }
                Divider()
                Button("Reveal in Finder") {
                    NSWorkspace.shared.selectFile(item.url.path, inFileViewerRootedAtPath: "")
                }
            }

            if item.isDirectory && item.isExpanded, let children = item.children {
                ForEach(children) { child in
                    FileTreeItemView(item: child, model: model, depth: depth + 1)
                }
            }
        }
    }

    private func handleClick() {
        Task {
            if item.isDirectory {
                await model.toggleExpansion(item)
            } else {
                await appState.openFile(at: item.url)
            }
        }
    }
}
