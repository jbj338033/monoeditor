import SwiftUI

struct SidebarView: View {
    @Environment(AppState.self) private var appState
    @State private var fileTree: FileTreeModel?
    @State private var filterText: String = ""

    private var filteredItems: [FileItem] {
        guard let tree = fileTree, !filterText.isEmpty else {
            return fileTree?.rootItems ?? []
        }
        return tree.rootItems.flatMap { collectMatchingItems($0, query: filterText.lowercased()) }
    }

    private func collectMatchingItems(_ item: FileItem, query: String) -> [FileItem] {
        var result: [FileItem] = []
        if item.name.lowercased().contains(query) {
            result.append(item)
        }
        if let children = item.children {
            for child in children {
                result.append(contentsOf: collectMatchingItems(child, query: query))
            }
        }
        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            SidebarHeader(fileTree: fileTree)

            SidebarFilter(text: $filterText)

            if let tree = fileTree {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if filterText.isEmpty {
                            if let pending = tree.pendingItem, pending.parentURL == tree.rootURL {
                                PendingItemRow(model: tree, depth: 0)
                            }

                            ForEach(tree.rootItems) { item in
                                FileTreeItemView(item: item, model: tree, depth: 0)
                            }
                        } else {
                            ForEach(filteredItems) { item in
                                FilteredFileRow(item: item)
                            }
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
        .onChange(of: appState.shouldTriggerNewFile) { _, shouldTrigger in
            if shouldTrigger, let project = appState.currentProject {
                appState.shouldTriggerNewFile = false
                fileTree?.startCreatingFile(in: project)
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
    let fileTree: FileTreeModel?
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
                createNewFile()
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
            .disabled(appState.currentProject == nil)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(ThemeColors.backgroundSecondary.opacity(0.3))
    }

    private func createNewFile() {
        guard let project = appState.currentProject else { return }
        fileTree?.startCreatingFile(in: project)
    }
}

struct SidebarFilter: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 10))
                .foregroundStyle(ThemeColors.textMuted)

            TextField("Filter files...", text: $text)
                .textFieldStyle(.plain)
                .font(Typography.uiSmall)
                .focused($isFocused)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: Icons.close)
                        .font(.system(size: 8))
                        .foregroundStyle(ThemeColors.textMuted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(ThemeColors.backgroundTertiary.opacity(0.5))
    }
}

struct FilteredFileRow: View {
    @Environment(AppState.self) private var appState
    let item: FileItem
    @State private var isHovering = false

    var body: some View {
        Button {
            if !item.isDirectory {
                Task { await appState.openFile(at: item.url) }
            }
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: item.icon)
                    .font(.system(size: 12))
                    .foregroundStyle(ThemeColors.textSecondary)
                    .frame(width: 16)

                Text(item.name)
                    .font(Typography.sidebarItem)
                    .foregroundStyle(ThemeColors.textPrimary)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(isHovering ? ThemeColors.backgroundHover : Color.clear)
        .onHover { isHovering = $0 }
    }
}
