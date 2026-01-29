import SwiftUI
import AppKit
import SwiftTerm

struct TerminalView: NSViewRepresentable {
    @Environment(AppState.self) private var appState

    func makeNSView(context: Context) -> LocalProcessTerminalView {
        let terminal = LocalProcessTerminalView(frame: .zero)
        terminal.font = MonoFonts.NS.terminal

        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"

        terminal.startProcess(
            executable: shell,
            args: [],
            environment: nil,
            execName: nil
        )

        if let url = appState.currentProject {
            terminal.send(txt: "cd \"\(url.path)\"\n")
        }

        return terminal
    }

    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
    }
}
