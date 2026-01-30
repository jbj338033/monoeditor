import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var settings = SettingsService.shared

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings")
                    .font(Typography.uiBold)
                    .foregroundStyle(ThemeColors.textPrimary)

                Spacer()

                Button {
                    appState.toggleSettings()
                } label: {
                    Image(systemName: Icons.close)
                        .font(.system(size: 12))
                        .foregroundStyle(ThemeColors.textMuted)
                }
                .buttonStyle(.plain)
            }
            .padding(Spacing.md)
            .background(ThemeColors.backgroundSecondary)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    SettingsSection(title: "Editor") {
                        SettingsRow(title: "Font Size") {
                            Picker("", selection: Binding(
                                get: { settings.editorFontSize },
                                set: { settings.editorFontSize = $0 }
                            )) {
                                ForEach(EditorFontSize.allCases, id: \.self) { size in
                                    Text("\(size.rawValue) pt").tag(size)
                                }
                            }
                            .frame(width: 100)
                        }

                        SettingsRow(title: "Tab Size") {
                            Picker("", selection: Binding(
                                get: { settings.tabSize },
                                set: { settings.tabSize = $0 }
                            )) {
                                Text("2").tag(2)
                                Text("4").tag(4)
                                Text("8").tag(8)
                            }
                            .frame(width: 100)
                        }

                        SettingsRow(title: "Show Line Numbers") {
                            Toggle("", isOn: Binding(
                                get: { settings.showLineNumbers },
                                set: { settings.showLineNumbers = $0 }
                            ))
                            .toggleStyle(.switch)
                        }

                        SettingsRow(title: "Word Wrap") {
                            Toggle("", isOn: Binding(
                                get: { settings.wordWrap },
                                set: { settings.wordWrap = $0 }
                            ))
                            .toggleStyle(.switch)
                        }
                    }

                    SettingsSection(title: "Appearance") {
                        SettingsRow(title: "Theme") {
                            Text("Dark")
                                .font(Typography.uiSmall)
                                .foregroundStyle(ThemeColors.textSecondary)
                        }
                    }
                }
                .padding(Spacing.lg)
            }
        }
        .frame(width: 450, height: 400)
        .background(ThemeColors.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(ThemeColors.textMuted.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20)
        .onKeyPress(.escape) {
            appState.toggleSettings()
            return .handled
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .font(Typography.uiBold)
                .foregroundStyle(ThemeColors.textPrimary)

            VStack(spacing: Spacing.sm) {
                content
            }
            .padding(Spacing.md)
            .background(ThemeColors.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

struct SettingsRow<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack {
            Text(title)
                .font(Typography.ui)
                .foregroundStyle(ThemeColors.textSecondary)

            Spacer()

            content
        }
    }
}
