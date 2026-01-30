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

            Divider()

            ForEach(1...9, id: \.self) { number in
                Button("Tab \(number)") {
                    appState.selectTab(at: number - 1)
                }
                .keyboardShortcut(KeyEquivalent(Character("\(number)")), modifiers: [.command])
            }

            Divider()

            Button("Increase Font Size") {
                SettingsService.shared.increaseFontSize()
            }
            .keyboardShortcut("+", modifiers: [.command])

            Button("Decrease Font Size") {
                SettingsService.shared.decreaseFontSize()
            }
            .keyboardShortcut("-", modifiers: [.command])

            Button("Reset Font Size") {
                SettingsService.shared.resetFontSize()
            }
            .keyboardShortcut("0", modifiers: [.command])
        }

        CommandGroup(replacing: .textEditing) {
            Button("Find in File") {
                appState.toggleFindBar()
            }
            .keyboardShortcut("f", modifiers: [.command])
            .disabled(appState.activeTab == nil)

            Button("Find and Replace...") {
                appState.toggleFindReplace()
            }
            .keyboardShortcut("h", modifiers: [.command])
            .disabled(appState.activeTab == nil)

            Button("Go to Line...") {
                appState.toggleGoToLine()
            }
            .keyboardShortcut("g", modifiers: [.command])
            .disabled(appState.activeTab == nil)

            Divider()

            Button("Quick Open...") {
                appState.toggleQuickOpen()
            }
            .keyboardShortcut("p", modifiers: [.command])
            .disabled(appState.currentProject == nil)

            Button("Search in Project...") {
                appState.toggleProjectSearch()
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])
            .disabled(appState.currentProject == nil)
        }

        CommandGroup(after: .appSettings) {
            Button("Settings...") {
                appState.toggleSettings()
            }
            .keyboardShortcut(",", modifiers: [.command])
        }

        CommandMenu("Tab") {
            Button("Next Recent Tab") {
                appState.cycleToNextRecentTab()
            }
            .keyboardShortcut("\t", modifiers: [.control])
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
