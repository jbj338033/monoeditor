import Foundation

extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }

    var isHidden: Bool {
        (try? resourceValues(forKeys: [.isHiddenKey]))?.isHidden == true
    }

    var fileSize: Int? {
        (try? resourceValues(forKeys: [.fileSizeKey]))?.fileSize
    }

    var creationDate: Date? {
        (try? resourceValues(forKeys: [.creationDateKey]))?.creationDate
    }

    var modificationDate: Date? {
        (try? resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
    }
}
