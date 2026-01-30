import SwiftUI

struct FileTreeItemView: View {
    @Environment(AppState.self) private var appState
    @Bindable var item: FileItem
    let model: FileTreeModel
    let depth: Int

    @State private var isHovering = false
    @State private var isRenaming = false
    @State private var editingName = ""
    @State private var errorMessage: String?
    @State private var showError = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if isRenaming {
                inlineTextField(isNew: false)
            } else {
                itemRow
            }

            if item.isDirectory && item.isExpanded {
                if let pending = model.pendingItem, pending.parentURL == item.url {
                    PendingItemRow(model: model, depth: depth + 1)
                }

                if let children = item.children {
                    ForEach(children) { child in
                        FileTreeItemView(item: child, model: model, depth: depth + 1)
                    }
                }
            }
        }
    }

    private var itemRow: some View {
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
                    Spacer().frame(width: 10)
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
        .contextMenu { contextMenuContent }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }

    @ViewBuilder
    private var contextMenuContent: some View {
        if item.isDirectory {
            Button("New File") {
                Task {
                    if !item.isExpanded {
                        await model.toggleExpansion(item)
                    }
                    model.startCreatingFile(in: item.url)
                }
            }
            Button("New Folder") {
                Task {
                    if !item.isExpanded {
                        await model.toggleExpansion(item)
                    }
                    model.startCreatingFolder(in: item.url)
                }
            }
            Divider()
        }
        Button("Rename") {
            startRenaming()
        }
        Button("Delete", role: .destructive) {
            deleteItem()
        }
        Divider()
        Button("Reveal in Finder") {
            NSWorkspace.shared.selectFile(item.url.path, inFileViewerRootedAtPath: "")
        }
    }

    private func inlineTextField(isNew: Bool) -> some View {
        HStack(spacing: Spacing.sm) {
            Spacer().frame(width: 10)

            Image(systemName: item.icon)
                .font(.system(size: 13))
                .foregroundStyle(item.isDirectory ? ThemeColors.textSecondary : ThemeColors.textMuted)
                .frame(width: 16)

            TextField("", text: $editingName)
                .textFieldStyle(.plain)
                .font(Typography.sidebarItem)
                .focused($isTextFieldFocused)
                .onSubmit { commitRename() }
                .onExitCommand { cancelRename() }

            Spacer()
        }
        .padding(.leading, CGFloat(depth) * Dimensions.sidebarIndent + Spacing.sm)
        .padding(.trailing, Spacing.sm)
        .frame(height: Dimensions.sidebarItemHeight)
        .background(ThemeColors.backgroundHover.opacity(0.8))
        .onAppear {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(100))
                isTextFieldFocused = true
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

    private func startRenaming() {
        editingName = item.name
        isRenaming = true
    }

    private func commitRename() {
        let trimmedName = editingName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty, trimmedName != item.name else {
            cancelRename()
            return
        }

        Task {
            do {
                _ = try await model.rename(item, to: trimmedName)
            } catch {
                errorMessage = "Failed to rename: \(error.localizedDescription)"
                showError = true
            }
            isRenaming = false
            isTextFieldFocused = false
        }
    }

    private func cancelRename() {
        isRenaming = false
        isTextFieldFocused = false
        editingName = ""
    }

    private func deleteItem() {
        let alert = NSAlert()
        alert.messageText = "Delete \"\(item.name)\"?"
        alert.informativeText = item.isDirectory
            ? "This folder and all its contents will be moved to Trash."
            : "This file will be moved to Trash."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            Task {
                if let tab = appState.openTabs.first(where: { $0.url == item.url }) {
                    appState.closeTab(tab.id)
                }
                do {
                    try await model.delete(item)
                } catch {
                    errorMessage = "Failed to delete: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

struct PendingItemRow: View {
    let model: FileTreeModel
    let depth: Int

    @State private var name = ""
    @FocusState private var isFocused: Bool
    @Environment(AppState.self) private var appState

    private var icon: String {
        guard let pending = model.pendingItem else { return Icons.file }
        return pending.type == .folder ? Icons.folder : Icons.file
    }

    private var placeholder: String {
        guard let pending = model.pendingItem else { return "" }
        return pending.type == .folder ? "folder name" : "file name"
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Spacer().frame(width: 10)

            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(ThemeColors.textMuted)
                .frame(width: 16)

            TextField(placeholder, text: $name)
                .textFieldStyle(.plain)
                .font(Typography.sidebarItem)
                .focused($isFocused)
                .onSubmit { commit() }
                .onExitCommand { cancel() }

            Spacer()
        }
        .padding(.leading, CGFloat(depth) * Dimensions.sidebarIndent + Spacing.sm)
        .padding(.trailing, Spacing.sm)
        .frame(height: Dimensions.sidebarItemHeight)
        .background(ThemeColors.backgroundHover.opacity(0.8))
        .onAppear {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(100))
                isFocused = true
            }
        }
    }

    private func commit() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            cancel()
            return
        }

        let isFile = model.pendingItem?.type == .file

        Task {
            if let url = try? await model.commitPendingItem(name: name) {
                if isFile {
                    await appState.openFile(at: url)
                }
            }
        }
    }

    private func cancel() {
        model.cancelPendingItem()
    }
}
