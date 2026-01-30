import SwiftUI

struct QuickOpenView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText: String = ""
    @State private var files: [URL] = []
    @State private var selectedIndex: Int = 0
    @FocusState private var isFocused: Bool

    private var filteredFiles: [URL] {
        guard !searchText.isEmpty else { return Array(files.prefix(20)) }
        let query = searchText.lowercased()
        return files.filter { $0.lastPathComponent.lowercased().contains(query) }
            .prefix(20)
            .sorted { lhs, rhs in
                let lhsName = lhs.lastPathComponent.lowercased()
                let rhsName = rhs.lastPathComponent.lowercased()
                let lhsStarts = lhsName.hasPrefix(query)
                let rhsStarts = rhsName.hasPrefix(query)
                if lhsStarts != rhsStarts { return lhsStarts }
                return lhsName < rhsName
            }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(ThemeColors.textSecondary)

                TextField("Search files...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(Typography.ui)
                    .focused($isFocused)
                    .onSubmit { openSelected() }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: Icons.close)
                            .font(.system(size: 10))
                            .foregroundStyle(ThemeColors.textMuted)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Spacing.md)
            .background(ThemeColors.backgroundSecondary)

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(filteredFiles.enumerated()), id: \.offset) { index, file in
                            QuickOpenRow(
                                file: file,
                                isSelected: index == selectedIndex
                            )
                            .id(index)
                            .onTapGesture {
                                selectedIndex = index
                                openSelected()
                            }
                        }
                    }
                }
                .onChange(of: selectedIndex) { _, newValue in
                    proxy.scrollTo(newValue)
                }
            }
            .frame(maxHeight: 300)
        }
        .frame(width: 500)
        .background(ThemeColors.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(ThemeColors.textMuted.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20)
        .onAppear {
            loadFiles()
            isFocused = true
        }
        .onKeyPress(.upArrow) {
            if selectedIndex > 0 { selectedIndex -= 1 }
            return .handled
        }
        .onKeyPress(.downArrow) {
            if selectedIndex < filteredFiles.count - 1 { selectedIndex += 1 }
            return .handled
        }
        .onKeyPress(.escape) {
            appState.toggleQuickOpen()
            return .handled
        }
    }

    private func loadFiles() {
        guard let project = appState.currentProject else { return }
        files = collectFiles(in: project)
    }

    private func collectFiles(in directory: URL) -> [URL] {
        var result: [URL] = []
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey, .isHiddenKey],
            options: [.skipsHiddenFiles]
        ) else { return result }

        while let fileURL = enumerator.nextObject() as? URL {
            guard let values = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]),
                  values.isRegularFile == true else { continue }
            let path = fileURL.path
            if path.contains("/.git/") || path.contains("/node_modules/") ||
               path.contains("/.build/") || path.contains("/DerivedData/") { continue }
            result.append(fileURL)
        }
        return result
    }

    private func openSelected() {
        guard selectedIndex < filteredFiles.count else { return }
        let file = filteredFiles[selectedIndex]
        Task {
            await appState.openFile(at: file)
            appState.toggleQuickOpen()
        }
    }
}

struct QuickOpenRow: View {
    let file: URL
    let isSelected: Bool

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: Icons.forFileExtension(file.pathExtension))
                .font(.system(size: 14))
                .foregroundStyle(ThemeColors.textSecondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(file.lastPathComponent)
                    .font(Typography.ui)
                    .foregroundStyle(ThemeColors.textPrimary)

                Text(file.deletingLastPathComponent().path)
                    .font(Typography.uiSmall)
                    .foregroundStyle(ThemeColors.textMuted)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(isSelected ? ThemeColors.accent.opacity(0.2) : Color.clear)
        .contentShape(Rectangle())
    }
}
