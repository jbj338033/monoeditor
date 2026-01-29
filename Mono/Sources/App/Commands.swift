import SwiftUI

struct MonoCommands: Commands {
    let appState: AppState

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Open Folder...") {
                openFolder()
            }
            .keyboardShortcut("o", modifiers: [.command])

            Divider()

            Button("New File") {
                // TODO: Implement new file
            }
            .keyboardShortcut("n", modifiers: [.command])
        }

        CommandGroup(replacing: .saveItem) {
            Button("Save") {
                // TODO: Implement save
            }
            .keyboardShortcut("s", modifiers: [.command])

            Button("Save As...") {
                // TODO: Implement save as
            }
            .keyboardShortcut("s", modifiers: [.command, .shift])
        }

        CommandMenu("View") {
            Button(appState.isSidebarVisible ? "Hide Sidebar" : "Show Sidebar") {
                withAnimation(.easeOut(duration: AnimationDuration.normal)) {
                    appState.isSidebarVisible.toggle()
                }
            }
            .keyboardShortcut("b", modifiers: [.command])

            Button(appState.isTerminalVisible ? "Hide Terminal" : "Show Terminal") {
                withAnimation(.easeOut(duration: AnimationDuration.normal)) {
                    appState.isTerminalVisible.toggle()
                }
            }
            .keyboardShortcut("j", modifiers: [.command])
        }

        CommandGroup(replacing: .textEditing) {
            Button("Find in File") {
                // TODO: Implement find
            }
            .keyboardShortcut("f", modifiers: [.command])
        }
    }

    private func openFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = false
        panel.message = "Select a folder to open"

        if panel.runModal() == .OK, let url = panel.url {
            Task { @MainActor in
                appState.setProject(url)
            }
        }
    }
}
