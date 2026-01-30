import Foundation
import SwiftUI

@MainActor
@Observable
final class SettingsService {
    static let shared = SettingsService()

    var editorFontSize: EditorFontSize {
        didSet {
            UserDefaults.standard.set(editorFontSize.rawValue, forKey: Keys.editorFontSize)
        }
    }

    var tabSize: Int {
        didSet {
            UserDefaults.standard.set(tabSize, forKey: Keys.tabSize)
        }
    }

    var showLineNumbers: Bool {
        didSet {
            UserDefaults.standard.set(showLineNumbers, forKey: Keys.showLineNumbers)
        }
    }

    var wordWrap: Bool {
        didSet {
            UserDefaults.standard.set(wordWrap, forKey: Keys.wordWrap)
        }
    }

    private init() {
        let defaults = UserDefaults.standard

        if let sizeRaw = defaults.object(forKey: Keys.editorFontSize) as? Int,
           let size = EditorFontSize(rawValue: sizeRaw) {
            editorFontSize = size
        } else {
            editorFontSize = .medium
        }

        tabSize = defaults.object(forKey: Keys.tabSize) as? Int ?? 4
        showLineNumbers = defaults.object(forKey: Keys.showLineNumbers) as? Bool ?? true
        wordWrap = defaults.object(forKey: Keys.wordWrap) as? Bool ?? false
    }

    func increaseFontSize() {
        let allSizes = EditorFontSize.allCases
        guard let currentIndex = allSizes.firstIndex(of: editorFontSize),
              currentIndex < allSizes.count - 1 else { return }
        editorFontSize = allSizes[currentIndex + 1]
    }

    func decreaseFontSize() {
        let allSizes = EditorFontSize.allCases
        guard let currentIndex = allSizes.firstIndex(of: editorFontSize),
              currentIndex > 0 else { return }
        editorFontSize = allSizes[currentIndex - 1]
    }

    func resetFontSize() {
        editorFontSize = .medium
    }

    private enum Keys {
        static let editorFontSize = "editorFontSize"
        static let tabSize = "tabSize"
        static let showLineNumbers = "showLineNumbers"
        static let wordWrap = "wordWrap"
    }
}
