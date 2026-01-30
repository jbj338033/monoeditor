import Foundation
import Observation

enum PendingItemType {
    case file
    case folder
}

struct PendingItem: Identifiable {
    let id = UUID()
    let parentURL: URL
    let type: PendingItemType
}

@MainActor
@Observable
final class FileTreeModel {
    let rootURL: URL
    var rootItems: [FileItem] = []
    var pendingItem: PendingItem?

    private var fileService: FileService { FileService.shared }

    init(rootURL: URL) {
        self.rootURL = rootURL
    }

    func startCreatingFile(in directory: URL) {
        pendingItem = PendingItem(parentURL: directory, type: .file)
    }

    func startCreatingFolder(in directory: URL) {
        pendingItem = PendingItem(parentURL: directory, type: .folder)
    }

    func cancelPendingItem() {
        pendingItem = nil
    }

    func commitPendingItem(name: String) async throws -> URL? {
        guard let pending = pendingItem else { return nil }
        pendingItem = nil

        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return nil }

        switch pending.type {
        case .file:
            return try await createFile(in: pending.parentURL, name: trimmedName)
        case .folder:
            return try await createFolder(in: pending.parentURL, name: trimmedName)
        }
    }

    func loadRoot() async {
        rootItems = await loadContents(of: rootURL)
    }

    func refresh() async {
        await loadRoot()
    }

    func toggleExpansion(_ item: FileItem) async {
        guard item.isDirectory else { return }

        if item.isExpanded {
            item.isExpanded = false
            item.children = nil
        } else {
            item.children = await loadContents(of: item.url)
            item.isExpanded = true
        }
    }

    func createFile(in directory: URL, name: String) async throws -> URL {
        let url = try await fileService.createFile(at: directory, name: name)
        await refreshParent(of: url)
        return url
    }

    func createFolder(in directory: URL, name: String) async throws -> URL {
        let url = try await fileService.createFolder(at: directory, name: name)
        await refreshParent(of: url)
        return url
    }

    func delete(_ item: FileItem) async throws {
        try await fileService.delete(at: item.url)
        await refreshParent(of: item.url)
    }

    func rename(_ item: FileItem, to newName: String) async throws -> URL {
        let newURL = try await fileService.rename(at: item.url, to: newName)
        await refreshParent(of: item.url)
        return newURL
    }

    private func refreshParent(of url: URL) async {
        let parentURL = url.deletingLastPathComponent()

        if parentURL == rootURL {
            await loadRoot()
            return
        }

        func findAndRefresh(in items: [FileItem]) async {
            for item in items {
                if item.url == parentURL && item.isExpanded {
                    item.children = await loadContents(of: item.url)
                    return
                }
                if let children = item.children {
                    await findAndRefresh(in: children)
                }
            }
        }

        await findAndRefresh(in: rootItems)
    }

    private func loadContents(of url: URL) async -> [FileItem] {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        let items = contents.compactMap { fileURL -> FileItem? in
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.isDirectoryKey]),
                  let isDirectory = resourceValues.isDirectory else {
                return nil
            }
            return FileItem(url: fileURL, isDirectory: isDirectory)
        }

        return items.sorted { lhs, rhs in
            if lhs.isDirectory != rhs.isDirectory {
                return lhs.isDirectory
            }
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }
}
