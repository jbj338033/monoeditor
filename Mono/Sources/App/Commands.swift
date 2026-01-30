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
                appState.triggerNewFile()
            }
            .keyboardShortcut("n", modifiers: [.command])
            .disabled(appState.currentProject == nil)
        }

        CommandGroup(replacing: .saveItem) {
            Button("Save") {
                Task {
                    do {
                        try await appState.saveActiveTab()
                    } catch {
                        showError(error, title: "Save Failed")
                    }
                }
            }
            .keyboardShortcut("s", modifiers: [.command])
            .disabled(appState.activeTab == nil)

            Button("Save As...") {
                saveAs()
            }
            .keyboardShortcut("s", modifiers: [.command, .shift])
            .disabled(appState.activeTab == nil)
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
                appState.toggleFindBar()
            }
            .keyboardShortcut("f", modifiers: [.command])
            .disabled(appState.activeTab == nil)
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

    private func saveAs() {
        guard let tab = appState.activeTab else { return }

        let panel = NSSavePanel()
        panel.nameFieldStringValue = tab.name
        panel.canCreateDirectories = true
        panel.message = "Save file as"

        if let project = appState.currentProject {
            panel.directoryURL = project
        }

        if panel.runModal() == .OK, let url = panel.url {
            Task {
                do {
                    try await appState.saveActiveTabAs(to: url)
                } catch {
                    showError(error)
                }
            }
        }
    }

    @MainActor
    private func showError(_ error: Error, title: String = "Error") {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
