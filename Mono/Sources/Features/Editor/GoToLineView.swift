import SwiftUI

struct GoToLineView: View {
    @Environment(AppState.self) private var appState
    @State private var lineText: String = ""
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
                .onSubmit {
                    if let line = Int(lineText), line > 0 {
                        appState.goToLine(line)
                    }
                }
                .onExitCommand {
                    appState.toggleGoToLine()
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
                .stroke(ThemeColors.textMuted.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            isFocused = true
        }
    }
}
