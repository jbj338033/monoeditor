import SwiftUI

struct SidebarView: View {
    @Environment(AppState.self) private var appState
    @State private var fileTree: FileTreeModel?

    var body: some View {
        VStack(spacing: 0) {
            SidebarHeader()

            if let tree = fileTree {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(tree.rootItems) { item in
                            FileTreeItemView(item: item, model: tree, depth: 0)
                        }
                    }
                    .padding(.vertical, Spacing.xs)
                }
            } else {
                Spacer()
                Text("No folder open")
                    .font(Typography.uiSmall)
                    .foregroundStyle(ThemeColors.textMuted)
                Spacer()
            }
        }
        .frame(maxHeight: .infinity)
        .background(ThemeColors.backgroundSecondary.opacity(0.5))
        .onChange(of: appState.currentProject, initial: true) { _, newValue in
            if let url = newValue {
                loadFileTree(at: url)
            } else {
                fileTree = nil
            }
        }
    }

    private func loadFileTree(at url: URL) {
        Task {
            let model = FileTreeModel(rootURL: url)
            await model.loadRoot()
            fileTree = model
        }
    }
}

struct SidebarHeader: View {
    @Environment(AppState.self) private var appState
    @State private var isHovering = false

    var body: some View {
        HStack {
            if let project = appState.currentProject {
                Image(systemName: Icons.folder)
                    .foregroundStyle(ThemeColors.textSecondary)

                Text(project.lastPathComponent)
                    .font(Typography.uiBold)
                    .foregroundStyle(ThemeColors.textPrimary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                // TODO: New file
            } label: {
                Image(systemName: Icons.newFile)
                    .font(.system(size: 12))
                    .foregroundStyle(isHovering ? ThemeColors.textPrimary : ThemeColors.textSecondary)
            }
            .buttonStyle(.plain)
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isHovering ? ThemeColors.backgroundHover : Color.clear)
            )
            .onHover { hovering in
                withAnimation(.easeOut(duration: 0.1)) {
                    isHovering = hovering
                }
            }
            .help("New File")
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(ThemeColors.backgroundSecondary.opacity(0.3))
    }
}
