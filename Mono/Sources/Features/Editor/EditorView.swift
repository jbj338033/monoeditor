import SwiftUI
import AppKit

struct EditorView: NSViewControllerRepresentable {
    @Environment(AppState.self) private var appState
    let tab: EditorTab
    private let settings = SettingsService.shared

    func makeNSViewController(context: Context) -> EditorViewController {
        let controller = EditorViewController()
        context.coordinator.viewController = controller
        context.coordinator.setupCallbacks(for: controller.monoTextView)
        context.coordinator.lastKnownContent = tab.content
        controller.monoTextView.configure(for: Language.from(extension: tab.fileExtension))
        controller.monoTextView.text = tab.content
        return controller
    }

    func updateNSViewController(_ controller: EditorViewController, context: Context) {
        let tabChanged = context.coordinator.currentTabId != tab.id

        guard !context.coordinator.isUpdating else { return }
        context.coordinator.isUpdating = true
        defer { context.coordinator.isUpdating = false }

        let textView = controller.monoTextView

        if tabChanged {
            context.coordinator.currentTabId = tab.id
            context.coordinator.lastKnownContent = tab.content
            textView.configure(for: Language.from(extension: tab.fileExtension))
            textView.text = tab.content
        } else if context.coordinator.lastKnownContent != tab.content {
            context.coordinator.lastKnownContent = tab.content
            textView.text = tab.content
        }

        if appState.isFindBarVisible {
            textView.showFindBar()
        }

        if let line = appState.goToLineNumber {
            let maxLine = textView.lineCount
            let targetLine = min(line, maxLine)
            textView.goToLine(targetLine)
            DispatchQueue.main.async {
                appState.goToLineNumber = nil
            }
        }

        textView.updateFontSize(settings.editorFontSize)

        if let action = appState.findReplaceAction {
            DispatchQueue.main.async {
                appState.findReplaceAction = nil
            }
            switch action {
            case .find:
                let count = textView.findMatches(for: appState.findQuery)
                let currentMatch = count > 0 ? 1 : 0
                if count > 0 {
                    _ = textView.findNext(for: appState.findQuery)
                }
                DispatchQueue.main.async {
                    appState.updateFindResults(matchCount: count, currentMatch: currentMatch)
                }
            case .findNext:
                if textView.findNext(for: appState.findQuery) {
                    let current = min(appState.findCurrentMatch + 1, appState.findMatchCount)
                    let nextMatch = current > appState.findMatchCount ? 1 : current
                    DispatchQueue.main.async {
                        appState.findCurrentMatch = nextMatch
                    }
                }
            case .replace:
                textView.replaceCurrent(find: appState.findQuery, replace: appState.replaceQuery)
                let count = textView.findMatches(for: appState.findQuery)
                DispatchQueue.main.async {
                    appState.updateFindResults(matchCount: count, currentMatch: min(appState.findCurrentMatch, count))
                }
            case .replaceAll:
                _ = textView.replaceAll(find: appState.findQuery, replace: appState.replaceQuery)
                DispatchQueue.main.async {
                    appState.updateFindResults(matchCount: 0, currentMatch: 0)
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(appState: appState, tabId: tab.id)
    }

    @MainActor
    class Coordinator {
        let appState: AppState
        var currentTabId: UUID
        var lastKnownContent: String = ""
        var isUpdating: Bool = false
        weak var viewController: EditorViewController?

        init(appState: AppState, tabId: UUID) {
            self.appState = appState
            self.currentTabId = tabId
        }

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

        func updateTab(content: String) {
            guard let index = appState.openTabs.firstIndex(where: { $0.id == currentTabId }) else { return }
            if appState.openTabs[index].content != content {
                appState.openTabs[index].content = content
                appState.openTabs[index].isModified = true
            }
        }
    }
}

// MARK: - EditorViewController

final class EditorViewController: NSViewController {
    let monoTextView = MonoTextView(frame: .zero)

    override func loadView() {
        view = monoTextView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
