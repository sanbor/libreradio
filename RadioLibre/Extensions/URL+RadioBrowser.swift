import Foundation

extension URL {
    /// Builds a Radio Browser API URL from a base URL and path components/query items.
    static func radioBrowserURL(
        base: URL,
        path: String,
        queryItems: [URLQueryItem] = []
    ) -> URL? {
        var components = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        return components?.url
    }
}
