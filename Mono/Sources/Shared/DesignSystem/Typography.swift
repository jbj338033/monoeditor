import SwiftUI
import AppKit

enum Typography {
    static let editor = Font.custom("SF Mono", size: 13)
    static let editorBold = Font.custom("SF Mono", size: 13).weight(.semibold)
    static let lineNumber = Font.custom("SF Mono", size: 11)
    static let terminal = Font.custom("SF Mono", size: 12)

    static let ui = Font.system(size: 13)
    static let uiSmall = Font.system(size: 11)
    static let uiBold = Font.system(size: 13, weight: .semibold)
    static let tabTitle = Font.system(size: 12)
    static let statusBar = Font.system(size: 11)
    static let sidebarItem = Font.system(size: 13)

    enum NS {
        static func editor(size: CGFloat = 13) -> NSFont {
            NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        }

        static func editorBold(size: CGFloat = 13) -> NSFont {
            NSFont.monospacedSystemFont(ofSize: size, weight: .semibold)
        }

        static var lineNumber: NSFont {
            NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        }

        static var terminal: NSFont {
            NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        }
    }
}

typealias MonoFonts = Typography

enum EditorFontSize: Int, CaseIterable {
    case small = 11
    case medium = 13
    case large = 15
    case xlarge = 17
    case xxlarge = 20

    var font: NSFont {
        Typography.NS.editor(size: CGFloat(rawValue))
    }
}
