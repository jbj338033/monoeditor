import Foundation
import AppKit

extension NSRange {
    init(_ textRange: NSTextRange, in storage: NSTextContentStorage) {
        let start = storage.offset(from: storage.documentRange.location, to: textRange.location)
        let end = storage.offset(from: storage.documentRange.location, to: textRange.endLocation)
        self.init(location: start, length: end - start)
    }

    func textRange(in storage: NSTextContentStorage) -> NSTextRange? {
        guard let start = storage.location(storage.documentRange.location, offsetBy: location),
              let end = storage.location(start, offsetBy: length) else {
            return nil
        }
        return NSTextRange(location: start, end: end)
    }
}
