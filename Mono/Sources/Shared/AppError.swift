import Foundation

enum AppError: LocalizedError, Equatable {
    case fileLoadFailed(url: URL, reason: String)
    case fileSaveFailed(url: URL, reason: String)
    case fileNotFound(url: URL)
    case permissionDenied(url: URL)
    case renameFailed(name: String, reason: String)
    case deleteFailed(name: String, reason: String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .fileLoadFailed(let url, _):
            return "Failed to load '\(url.lastPathComponent)'"
        case .fileSaveFailed(let url, _):
            return "Failed to save '\(url.lastPathComponent)'"
        case .fileNotFound(let url):
            return "File not found: '\(url.lastPathComponent)'"
        case .permissionDenied(let url):
            return "Permission denied: '\(url.lastPathComponent)'"
        case .renameFailed(let name, _):
            return "Failed to rename '\(name)'"
        case .deleteFailed(let name, _):
            return "Failed to delete '\(name)'"
        case .unknown(let message):
            return message
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .fileLoadFailed(_, let reason):
            return reason
        case .fileSaveFailed(_, let reason):
            return reason
        case .fileNotFound:
            return "The file may have been moved or deleted."
        case .permissionDenied:
            return "Check if you have read/write access to this file."
        case .renameFailed(_, let reason):
            return reason
        case .deleteFailed(_, let reason):
            return reason
        case .unknown:
            return nil
        }
    }
}
