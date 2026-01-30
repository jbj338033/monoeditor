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

    var cursorLine: Int = 1
    var cursorColumn: Int = 1

    var isFindBarVisible: Bool = false
    var shouldTriggerNewFile: Bool = false
    var isGoToLineVisible: Bool = false
    var goToLineNumber: Int?

    var currentError: AppError?
    var showErrorAlert: Bool = false

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
            tab.loadError = nil
        } catch {
            tab.content = ""
            tab.loadError = error.localizedDescription
            showError(.fileLoadFailed(url: url, reason: error.localizedDescription))
        }

        openTabs.append(tab)
        activeTabId = tab.id
    }

    func showError(_ error: AppError) {
        currentError = error
        showErrorAlert = true
    }

    func closeTab(_ id: UUID, force: Bool = false) {
        guard let tab = openTabs.first(where: { $0.id == id }) else { return }

        if tab.isModified && !force {
            showSaveConfirmation(for: tab)
            return
        }

        performCloseTab(id)
    }

    private func performCloseTab(_ id: UUID) {
        openTabs.removeAll { $0.id == id }
        if activeTabId == id {
            activeTabId = openTabs.last?.id
        }
    }

    private func showSaveConfirmation(for tab: EditorTab) {
        let alert = NSAlert()
        alert.messageText = "Do you want to save changes to \"\(tab.name)\"?"
        alert.informativeText = "Your changes will be lost if you don't save them."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Don't Save")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()

        switch response {
        case .alertFirstButtonReturn:
            Task {
                do {
                    try await saveTab(id: tab.id)
                    performCloseTab(tab.id)
                } catch {
                    showError(.fileLoadFailed(url: tab.url, reason: error.localizedDescription))
                }
            }
        case .alertSecondButtonReturn:
            performCloseTab(tab.id)
        default:
            break
        }
    }

    private func saveTab(id: UUID) async throws {
        guard let index = openTabs.firstIndex(where: { $0.id == id }) else { return }
        let tab = openTabs[index]
        try await fileService.writeFile(tab.content, to: tab.url)
        openTabs[index].isModified = false
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

    func saveActiveTabAs(to url: URL) async throws {
        guard let index = openTabs.firstIndex(where: { $0.id == activeTabId }) else {
            return
        }

        let tab = openTabs[index]
        try await fileService.writeFile(tab.content, to: url)

        var newTab = EditorTab(url: url)
        newTab.content = tab.content
        openTabs[index] = newTab
        activeTabId = newTab.id
    }

    func createNewFile(in directory: URL, name: String) async throws {
        let url = try await fileService.createFile(at: directory, name: name)
        await openFile(at: url)
    }

    func updateCursorPosition(line: Int, column: Int) {
        cursorLine = line
        cursorColumn = column
    }

    func toggleFindBar() {
        isFindBarVisible.toggle()
    }

    func triggerNewFile() {
        guard currentProject != nil else { return }
        shouldTriggerNewFile = true
    }

    func toggleGoToLine() {
        isGoToLineVisible.toggle()
        if !isGoToLineVisible {
            goToLineNumber = nil
        }
    }

    func goToLine(_ line: Int) {
        goToLineNumber = line
        isGoToLineVisible = false
    }

    func selectTab(at index: Int) {
        guard index >= 0, index < openTabs.count else { return }
        activeTabId = openTabs[index].id
    }
}
