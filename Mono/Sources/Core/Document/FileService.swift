import Foundation

actor FileService {
    static let shared = FileService()

    private init() {}

    func readFile(at url: URL) async throws -> String {
        try String(contentsOf: url, encoding: .utf8)
    }

    func writeFile(_ content: String, to url: URL) async throws {
        try content.write(to: url, atomically: true, encoding: .utf8)
    }

    func createFile(at directory: URL, name: String, content: String = "") async throws -> URL {
        let fileURL = directory.appendingPathComponent(name)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    func createFolder(at directory: URL, name: String) async throws -> URL {
        let folderURL = directory.appendingPathComponent(name)
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false)
        return folderURL
    }

    func delete(at url: URL) async throws {
        try FileManager.default.removeItem(at: url)
    }

    func rename(at url: URL, to newName: String) async throws -> URL {
        let newURL = url.deletingLastPathComponent().appendingPathComponent(newName)
        try FileManager.default.moveItem(at: url, to: newURL)
        return newURL
    }

    func exists(at url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }

    func isDirectory(at url: URL) -> Bool {
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        return isDir.boolValue
    }
}

enum FileError: LocalizedError {
    case notFound(URL)
    case permissionDenied(URL)
    case encodingError(URL)
    case alreadyExists(URL)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .notFound(let url):
            return "File not found: \(url.lastPathComponent)"
        case .permissionDenied(let url):
            return "Permission denied: \(url.lastPathComponent)"
        case .encodingError(let url):
            return "Cannot read file: \(url.lastPathComponent)"
        case .alreadyExists(let url):
            return "File already exists: \(url.lastPathComponent)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
