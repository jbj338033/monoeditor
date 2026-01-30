import SwiftUI
import AppKit
import SwiftTerm

struct TerminalContainerView: View {
    @Environment(AppState.self) private var appState
    @State private var terminalState: TerminalState

    init() {
        _terminalState = State(initialValue: TerminalState())
    }

    var body: some View {
        VStack(spacing: 0) {
            TerminalToolbar(terminalState: terminalState)
            TerminalView(terminalState: terminalState, projectURL: appState.currentProject)
                .id(terminalState.terminalId)
        }
        .background(ThemeColors.backgroundPrimary)
        .onChange(of: appState.currentProject) { _, newProject in
            terminalState.currentDirectory = newProject
        }
    }
}

struct TerminalToolbar: View {
    @Bindable var terminalState: TerminalState

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Menu {
                ForEach(Shell.availableShells) { shell in
                    Button {
                        terminalState.changeShell(to: shell)
                    } label: {
                        HStack {
                            Text(shell.name)
                            if shell == terminalState.selectedShell {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "terminal")
                        .font(.system(size: 10))
                    Text(terminalState.selectedShell.name)
                        .font(Typography.statusBar)
                }
                .foregroundStyle(ThemeColors.textSecondary)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(ThemeColors.backgroundTertiary, in: RoundedRectangle(cornerRadius: 4))
            }
            .menuStyle(.borderlessButton)
            .fixedSize()

            Spacer()

            Button {
                terminalState.restart()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 11))
                    .foregroundStyle(ThemeColors.textMuted)
            }
            .buttonStyle(.plain)
            .help("Restart Terminal")
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .frame(height: 28)
        .background(ThemeColors.backgroundSecondary)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(ThemeColors.textMuted.opacity(0.2))
                .frame(height: 1)
        }
    }
}

struct TerminalView: NSViewRepresentable {
    let terminalState: TerminalState
    let projectURL: URL?

    func makeNSView(context: Context) -> MonoTerminalView {
        let terminal = MonoTerminalView(frame: .zero)
        terminal.configureAppearance()
        terminal.startShell(
            shell: terminalState.selectedShell,
            workingDirectory: projectURL
        )
        context.coordinator.terminal = terminal
        return terminal
    }

    func updateNSView(_ nsView: MonoTerminalView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        weak var terminal: MonoTerminalView?
    }
}

final class MonoTerminalView: LocalProcessTerminalView {
    private var shellProcess: Process?

    func configureAppearance() {
        font = MonoFonts.NS.terminal
        nativeBackgroundColor = ThemeColors.NS.backgroundPrimary
        nativeForegroundColor = ThemeColors.NS.textPrimary

        func c(_ r: UInt16, _ g: UInt16, _ b: UInt16) -> SwiftTerm.Color {
            SwiftTerm.Color(red: r * 257, green: g * 257, blue: b * 257)
        }

        let colors: [SwiftTerm.Color] = [
            c(0x1E, 0x1E, 0x1E),  // 0: Black
            c(0xF1, 0x4C, 0x4C),  // 1: Red
            c(0x89, 0xD1, 0x85),  // 2: Green
            c(0xCC, 0xA7, 0x00),  // 3: Yellow
            c(0x3B, 0x8E, 0xEA),  // 4: Blue
            c(0xBC, 0x3F, 0xBC),  // 5: Magenta
            c(0x29, 0xB8, 0xDB),  // 6: Cyan
            c(0xE4, 0xE4, 0xE4),  // 7: White
            c(0x6E, 0x6E, 0x6E),  // 8: Bright Black
            c(0xF1, 0x4C, 0x4C),  // 9: Bright Red
            c(0x89, 0xD1, 0x85),  // 10: Bright Green
            c(0xE9, 0xA7, 0x00),  // 11: Bright Yellow
            c(0x3B, 0x8E, 0xEA),  // 12: Bright Blue
            c(0xBC, 0x3F, 0xBC),  // 13: Bright Magenta
            c(0x29, 0xB8, 0xDB),  // 14: Bright Cyan
            c(0xFF, 0xFF, 0xFF),  // 15: Bright White
        ]
        installColors(colors)

        caretColor = ThemeColors.NS.accent
        selectedTextBackgroundColor = ThemeColors.NS.selection
    }

    func startShell(shell: Shell, workingDirectory: URL?) {
        var environment = ProcessInfo.processInfo.environment
        environment["TERM"] = "xterm-256color"
        environment["LANG"] = "en_US.UTF-8"

        if let dir = workingDirectory {
            environment["PWD"] = dir.path
        }

        let envArray = environment.map { "\($0.key)=\($0.value)" }

        startProcess(
            executable: shell.rawValue,
            args: ["--login"],
            environment: envArray,
            execName: shell.name
        )

        if let dir = workingDirectory {
            let cdCommand = "cd \"\(dir.path)\" && clear\n"
            send(txt: cdCommand)
        }
    }

    func clear() {
        send(txt: "clear\n")
    }
}
