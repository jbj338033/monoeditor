import Foundation

extension String {
    var lineCount: Int {
        var count = 0
        enumerateLines { _, _ in
            count += 1
        }
        return max(count, 1)
    }

    func lineRange(for line: Int) -> Range<String.Index>? {
        var currentLine = 0
        var start = startIndex

        while currentLine < line && start < endIndex {
            guard let range = rangeOfCharacter(from: .newlines, range: start..<endIndex) else {
                return nil
            }
            start = index(after: range.lowerBound)
            currentLine += 1
        }

        guard currentLine == line else { return nil }

        let end = rangeOfCharacter(from: .newlines, range: start..<endIndex)?.lowerBound ?? endIndex
        return start..<end
    }

    func line(at index: Int) -> Substring? {
        guard let range = lineRange(for: index) else { return nil }
        return self[range]
    }
}
