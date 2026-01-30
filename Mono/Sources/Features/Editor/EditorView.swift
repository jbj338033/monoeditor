import SwiftUI

struct EditorView: NSViewRepresentable {
    @Environment(AppState.self) private var appState
    let tab: EditorTab

    func makeNSView(context: Context) -> MonoTextView {
        let textView = MonoTextView(frame: .zero)
        context.coordinator.setupCallbacks(for: textView)
        return textView
    }

    func updateNSView(_ nsView: MonoTextView, context: Context) {
        let tabChanged = context.coordinator.currentTabId != tab.id

        guard !context.coordinator.isUpdating else { return }
        context.coordinator.isUpdating = true
        defer { context.coordinator.isUpdating = false }

        if tabChanged {
            context.coordinator.currentTabId = tab.id
            context.coordinator.lastKnownContent = tab.content
            nsView.configure(for: Language.from(extension: tab.fileExtension))
            nsView.text = tab.content
        } else if context.coordinator.lastKnownContent != tab.content {
            context.coordinator.lastKnownContent = tab.content
            nsView.text = tab.content
        }

        if appState.isFindBarVisible {
            nsView.showFindBar()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(appState: appState, tabId: tab.id)
    }

    class Coordinator {
        let appState: AppState
        var currentTabId: UUID
        var lastKnownContent: String = ""
        var isUpdating: Bool = false

        init(appState: AppState, tabId: UUID) {
            self.appState = appState
            self.currentTabId = tabId
        }

        @MainActor
        func setupCallbacks(for textView: MonoTextView) {
            textView.onTextChange = { [weak self] newContent in
                guard let self else { return }
                self.lastKnownContent = newContent
                Task { @MainActor in
                    self.updateTab(content: newContent)
                }
            }
            textView.onCursorChange = { [weak self] line, column in
                guard let self else { return }
                Task { @MainActor in
                    self.appState.updateCursorPosition(line: line, column: column)
                }
            }
        }

        @MainActor
        func updateTab(content: String) {
            guard let index = appState.openTabs.firstIndex(where: { $0.id == currentTabId }) else { return }
            if appState.openTabs[index].content != content {
                appState.openTabs[index].content = content
                appState.openTabs[index].isModified = true
            }
        }
    }
}
