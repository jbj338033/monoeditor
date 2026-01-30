import SwiftUI

struct FindReplaceView: View {
    @Environment(AppState.self) private var appState
    @FocusState private var findFocused: Bool

    var body: some View {
        @Bindable var appState = appState

        VStack(spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(ThemeColors.textSecondary)
                    .frame(width: 16)

                TextField("Find", text: $appState.findQuery)
                    .textFieldStyle(.plain)
                    .font(Typography.ui)
                    .focused($findFocused)
                    .onChange(of: appState.findQuery) { _, newValue in
                        appState.updateFindQuery(newValue)
                    }
                    .onSubmit {
                        appState.triggerFindNext()
                    }

                if !appState.findQuery.isEmpty {
                    Text("\(appState.findCurrentMatch)/\(appState.findMatchCount)")
                        .font(Typography.uiSmall)
                        .foregroundStyle(ThemeColors.textMuted)
                        .frame(width: 50)

                    Button {
                        appState.triggerFindNext()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundStyle(ThemeColors.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .help("Find Next (Enter)")
                }

                Button {
                    appState.toggleFindReplace()
                } label: {
                    Image(systemName: Icons.close)
                        .font(.system(size: 10))
                        .foregroundStyle(ThemeColors.textMuted)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: Spacing.sm) {
                Image(systemName: "arrow.2.squarepath")
                    .foregroundStyle(ThemeColors.textSecondary)
                    .frame(width: 16)

                TextField("Replace", text: $appState.replaceQuery)
                    .textFieldStyle(.plain)
                    .font(Typography.ui)

                HStack(spacing: Spacing.xs) {
                    Button("Replace") {
                        appState.triggerReplace()
                    }
                    .buttonStyle(.plain)
                    .font(Typography.uiSmall)
                    .foregroundStyle(ThemeColors.textPrimary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(ThemeColors.backgroundTertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .disabled(appState.findQuery.isEmpty)

                    Button("All") {
                        appState.triggerReplaceAll()
                    }
                    .buttonStyle(.plain)
                    .font(Typography.uiSmall)
                    .foregroundStyle(ThemeColors.textPrimary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(ThemeColors.backgroundTertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .disabled(appState.findQuery.isEmpty)
                }
            }
        }
        .padding(Spacing.md)
        .background(ThemeColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(ThemeColors.textMuted.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            findFocused = true
        }
        .onKeyPress(.escape) {
            appState.toggleFindReplace()
            return .handled
        }
    }
}
