import Foundation

enum Dimensions {
    static let sidebarWidth: CGFloat = 220
    static let sidebarMinWidth: CGFloat = 180
    static let sidebarMaxWidth: CGFloat = 400
    static let sidebarItemHeight: CGFloat = 22
    static let sidebarIndent: CGFloat = 16

    static let tabBarHeight: CGFloat = 28
    static let tabMinWidth: CGFloat = 80
    static let tabMaxWidth: CGFloat = 200
    static let tabCloseButtonSize: CGFloat = 14

    static let lineNumberGutterWidth: CGFloat = 50
    static let editorPaddingHorizontal: CGFloat = 16
    static let editorPaddingVertical: CGFloat = 8

    static let statusBarHeight: CGFloat = 22

    static let terminalHeight: CGFloat = 200
    static let terminalMinHeight: CGFloat = 100
    static let terminalMaxHeight: CGFloat = 500

    static let windowMinWidth: CGFloat = 800
    static let windowMinHeight: CGFloat = 600
    static let windowDefaultWidth: CGFloat = 1200
    static let windowDefaultHeight: CGFloat = 800
}

enum AnimationDuration {
    static let instant: Double = 0.1
    static let fast: Double = 0.15
    static let normal: Double = 0.25
    static let slow: Double = 0.35
}

enum CursorTiming {
    static let blinkOn: TimeInterval = 0.53
    static let blinkOff: TimeInterval = 0.53
}
