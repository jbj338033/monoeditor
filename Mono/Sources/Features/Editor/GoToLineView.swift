import SwiftUI

struct GoToLineView: View {
    @Environment(AppState.self) private var appState
    @State private var lineText: String = ""
    @State private var isInvalidInput: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "arrow.down.to.line")
                .foregroundStyle(ThemeColors.textSecondary)

            TextField("Line number", text: $lineText)
                .textFieldStyle(.plain)
                .font(Typography.ui)
                .frame(width: 100)
                .focused($isFocused)
                .foregroundStyle(isInvalidInput ? ThemeColors.error : ThemeColors.textPrimary)
                .onChange(of: lineText) { _, _ in
                    isInvalidInput = false
                }
                .onSubmit {
                    if let line = Int(lineText), line > 0 {
                        appState.goToLine(line)
                    } else {
                        isInvalidInput = true
                    }
                }
                .onExitCommand {
                    appState.toggleGoToLine()
                }

            if isInvalidInput {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 10))
                    .foregroundStyle(ThemeColors.error)
            }

            Button {
                appState.toggleGoToLine()
            } label: {
                Image(systemName: Icons.close)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(ThemeColors.textMuted)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(ThemeColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isInvalidInput ? ThemeColors.error.opacity(0.5) : ThemeColors.textMuted.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            isFocused = true
        }
    }
}
