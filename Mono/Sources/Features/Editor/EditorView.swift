import SwiftUI

struct EditorView: NSViewRepresentable {
    @Environment(AppState.self) private var appState
    let tab: EditorTab

    func makeNSView(context: Context) -> MonoTextView {
        let textView = MonoTextView(frame: .zero)
        textView.onTextChange = { newContent in
            Task { @MainActor in
                updateTab(content: newContent)
            }
        }
        return textView
    }

    func updateNSView(_ nsView: MonoTextView, context: Context) {
        nsView.configure(for: Language.from(extension: tab.fileExtension))
        if !tab.content.isEmpty && nsView.text != tab.content {
            nsView.text = tab.content
        }
    }

    private func updateTab(content: String) {
        guard let index = appState.openTabs.firstIndex(where: { $0.id == tab.id }) else { return }
        if appState.openTabs[index].content != content {
            appState.openTabs[index].content = content
            appState.openTabs[index].isModified = true
        }
    }
}
