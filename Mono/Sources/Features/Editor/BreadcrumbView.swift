import SwiftUI

struct BreadcrumbView: View {
    let url: URL
    let projectRoot: URL?

    private var pathComponents: [PathComponent] {
        var components: [PathComponent] = []
        var current = url

        while current.path != "/" {
            let isFile = !current.hasDirectoryPath
            components.insert(PathComponent(name: current.lastPathComponent, url: current, isFile: isFile), at: 0)

            if let root = projectRoot, current.path == root.path {
                break
            }
            current = current.deletingLastPathComponent()
        }
        return components
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(Array(pathComponents.enumerated()), id: \.offset) { index, component in
                    if index > 0 {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 8))
                            .foregroundStyle(ThemeColors.textMuted)
                    }

                    HStack(spacing: Spacing.xs) {
                        Image(systemName: component.isFile
                              ? Icons.forFileExtension(component.url.pathExtension)
                              : Icons.folder)
                            .font(.system(size: 10))
                            .foregroundStyle(ThemeColors.textSecondary)

                        Text(component.name)
                            .font(Typography.uiSmall)
                            .foregroundStyle(ThemeColors.textSecondary)
                    }
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, 2)
                    .background(ThemeColors.backgroundTertiary.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }
            .padding(.horizontal, Spacing.sm)
        }
        .frame(height: 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ThemeColors.backgroundSecondary)
    }
}

private struct PathComponent {
    let name: String
    let url: URL
    let isFile: Bool
}
