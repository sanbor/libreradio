import Foundation

enum AppError: LocalizedError {
    case networkUnavailable
    case serverDiscoveryFailed
    case serverError(statusCode: Int)
    case decodingFailed(underlying: Error)
    case streamURLInvalid
    case audioSessionFailed(underlying: Error)
    case playbackFailed(underlying: Error)
    case noServersAvailable

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection"
        case .serverDiscoveryFailed:
            return "Failed to discover Radio Browser servers"
        case .serverError(let code):
            return "Server error (\(code))"
        case .decodingFailed:
            return "Failed to parse server response"
        case .streamURLInvalid:
            return "Invalid stream URL"
        case .audioSessionFailed:
            return "Failed to configure audio session"
        case .playbackFailed(let error):
            return "Playback failed: \(error.localizedDescription)"
        case .noServersAvailable:
            return "No Radio Browser servers available"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Check your internet connection and try again."
        case .serverDiscoveryFailed, .noServersAvailable:
            return "Try again later."
        case .serverError:
            return "The server is having issues. Try again later."
        case .decodingFailed:
            return "The app may need to be updated."
        case .streamURLInvalid:
            return "This station may have moved or shut down."
        case .audioSessionFailed, .playbackFailed:
            return "Try restarting the app."
        }
    }
}
