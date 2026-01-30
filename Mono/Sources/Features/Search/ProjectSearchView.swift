import SwiftUI

struct ProjectSearchView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText: String = ""
    @State private var results: [SearchResult] = []
    @State private var isSearching: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(ThemeColors.textSecondary)

                TextField("Search in project...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(Typography.ui)
                    .focused($isFocused)
                    .onSubmit { performSearch() }

                if isSearching {
                    ProgressView()
                        .scaleEffect(0.5)
                }

                Button {
                    appState.toggleProjectSearch()
                } label: {
                    Image(systemName: Icons.close)
                        .font(.system(size: 10))
                        .foregroundStyle(ThemeColors.textMuted)
                }
                .buttonStyle(.plain)
            }
            .padding(Spacing.md)
            .background(ThemeColors.backgroundSecondary)

            Divider()

            if results.isEmpty && !searchText.isEmpty && !isSearching {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundStyle(ThemeColors.textMuted)
                    Text("No results found")
                        .font(Typography.ui)
                        .foregroundStyle(ThemeColors.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(Spacing.xl)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(results) { result in
                            SearchResultRow(result: result)
                                .onTapGesture {
                                    Task {
                                        await appState.openFile(at: result.file)
                                        appState.goToLine(result.line)
                                        appState.toggleProjectSearch()
                                    }
                                }
                        }
                    }
                }
            }
        }
        .frame(width: 600, height: 400)
        .background(ThemeColors.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(ThemeColors.textMuted.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20)
        .onAppear { isFocused = true }
        .onKeyPress(.escape) {
            appState.toggleProjectSearch()
            return .handled
        }
    }

    private func performSearch() {
        guard !searchText.isEmpty, let project = appState.currentProject else { return }
        isSearching = true
        results = []

        Task {
            let found = await searchInProject(query: searchText, root: project)
            await MainActor.run {
                results = found
                isSearching = false
            }
        }
    }

    private func searchInProject(query: String, root: URL) async -> [SearchResult] {
        await Task.detached {
            var results: [SearchResult] = []
            let fm = FileManager.default
            guard let enumerator = fm.enumerator(
                at: root,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            ) else { return results }

            let queryLower = query.lowercased()

            while let fileURL = enumerator.nextObject() as? URL {
                let path = fileURL.path
                if path.contains("/.git/") || path.contains("/node_modules/") ||
                   path.contains("/.build/") || path.contains("/DerivedData/") { continue }

                guard let values = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]),
                      values.isRegularFile == true else { continue }

                guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else { continue }

                let lines = content.components(separatedBy: .newlines)
                for (index, line) in lines.enumerated() {
                    if line.lowercased().contains(queryLower) {
                        results.append(SearchResult(
                            file: fileURL,
                            line: index + 1,
                            content: line.trimmingCharacters(in: .whitespaces),
                            query: query
                        ))
                        if results.count >= 100 { return results }
                    }
                }
            }
            return results
        }.value
    }
}

struct SearchResult: Identifiable {
    let id = UUID()
    let file: URL
    let line: Int
    let content: String
    let query: String
}

struct SearchResultRow: View {
    let result: SearchResult

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: Icons.forFileExtension(result.file.pathExtension))
                .font(.system(size: 12))
                .foregroundStyle(ThemeColors.textSecondary)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Spacing.xs) {
                    Text(result.file.lastPathComponent)
                        .font(Typography.ui)
                        .foregroundStyle(ThemeColors.textPrimary)

                    Text(":\(result.line)")
                        .font(Typography.uiSmall)
                        .foregroundStyle(ThemeColors.textMuted)
                }

                Text(result.content)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(ThemeColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .contentShape(Rectangle())
        .background(Color.clear)
    }
}
