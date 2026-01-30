import SwiftUI

struct FindReplaceView: View {
    @Environment(AppState.self) private var appState
    @State private var findText: String = ""
    @State private var replaceText: String = ""
    @State private var matchCount: Int = 0
    @State private var currentMatch: Int = 0
    @FocusState private var findFocused: Bool

    var onFind: ((String) -> Int)?
    var onReplace: ((String, String) -> Void)?
    var onReplaceAll: ((String, String) -> Int)?

    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(ThemeColors.textSecondary)
                    .frame(width: 16)

                TextField("Find", text: $findText)
                    .textFieldStyle(.plain)
                    .font(Typography.ui)
                    .focused($findFocused)
                    .onChange(of: findText) { _, newValue in
                        matchCount = onFind?(newValue) ?? 0
                        currentMatch = matchCount > 0 ? 1 : 0
                    }

                if !findText.isEmpty {
                    Text("\(currentMatch)/\(matchCount)")
                        .font(Typography.uiSmall)
                        .foregroundStyle(ThemeColors.textMuted)
                        .frame(width: 50)
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

                TextField("Replace", text: $replaceText)
                    .textFieldStyle(.plain)
                    .font(Typography.ui)

                HStack(spacing: Spacing.xs) {
                    Button("Replace") {
                        onReplace?(findText, replaceText)
                    }
                    .buttonStyle(.plain)
                    .font(Typography.uiSmall)
                    .foregroundStyle(ThemeColors.textPrimary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(ThemeColors.backgroundTertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .disabled(findText.isEmpty)

                    Button("All") {
                        if let count = onReplaceAll?(findText, replaceText) {
                            matchCount = 0
                            currentMatch = 0
                        }
                    }
                    .buttonStyle(.plain)
                    .font(Typography.uiSmall)
                    .foregroundStyle(ThemeColors.textPrimary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(ThemeColors.backgroundTertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .disabled(findText.isEmpty)
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
