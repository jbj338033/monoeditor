import SwiftUI
import Observation

@MainActor
@Observable
final class AppState {
    var currentProject: URL?
    var openTabs: [EditorTab] = []
    var activeTabId: UUID?
    var sidebarWidth: CGFloat = Dimensions.sidebarWidth
    var terminalHeight: CGFloat = Dimensions.terminalHeight
    var isSidebarVisible: Bool = true
    var isTerminalVisible: Bool = false

    private var fileService: FileService { FileService.shared }

    var activeTab: EditorTab? {
        activeTabId.flatMap { id in openTabs.first { $0.id == id } }
    }

    func openFile(at url: URL) async {
        if let existing = openTabs.first(where: { $0.url == url }) {
            activeTabId = existing.id
            return
        }

        var tab = EditorTab(url: url)

        do {
            tab.content = try await fileService.readFile(at: url)
        } catch {
            tab.content = "// Error loading file: \(error.localizedDescription)"
        }

        openTabs.append(tab)
        activeTabId = tab.id
    }

    func closeTab(_ id: UUID) {
        openTabs.removeAll { $0.id == id }
        if activeTabId == id {
            activeTabId = openTabs.last?.id
        }
    }

    func closeAllTabs() {
        openTabs.removeAll()
        activeTabId = nil
    }

    func setProject(_ url: URL?) {
        currentProject = url
        closeAllTabs()
    }

    func saveActiveTab() async throws {
        guard let index = openTabs.firstIndex(where: { $0.id == activeTabId }) else {
            return
        }

        let tab = openTabs[index]
        try await fileService.writeFile(tab.content, to: tab.url)
        openTabs[index].isModified = false
    }
}
