import Foundation
import Observation

enum Shell: String, CaseIterable, Identifiable {
    case zsh = "/bin/zsh"
    case bash = "/bin/bash"
    case fish = "/opt/homebrew/bin/fish"
    case sh = "/bin/sh"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .zsh: return "zsh"
        case .bash: return "bash"
        case .fish: return "fish"
        case .sh: return "sh"
        }
    }

    var icon: String {
        switch self {
        case .zsh, .bash, .sh: return "terminal"
        case .fish: return "fish"
        }
    }

    var isAvailable: Bool {
        FileManager.default.isExecutableFile(atPath: rawValue)
    }

    static var availableShells: [Shell] {
        allCases.filter { $0.isAvailable }
    }

    static var defaultShell: Shell {
        let envShell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        return Shell(rawValue: envShell) ?? .zsh
    }
}

@MainActor
@Observable
final class TerminalState {
    var selectedShell: Shell
    var terminalId: UUID
    var isRunning: Bool = false
    var currentDirectory: URL?

    init(shell: Shell? = nil, directory: URL? = nil) {
        self.selectedShell = shell ?? Shell.defaultShell
        self.terminalId = UUID()
        self.currentDirectory = directory
    }

    func restart() {
        terminalId = UUID()
    }

    func changeShell(to shell: Shell) {
        selectedShell = shell
        restart()
    }
}
