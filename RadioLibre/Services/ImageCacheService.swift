import Foundation
import UIKit
import CryptoKit

/// Async image cache: memory (NSCache) + disk (FileManager caches directory).
actor ImageCacheService {
    static let shared = ImageCacheService()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCacheDirectory: URL

    private init() {
        memoryCache.countLimit = 200
        memoryCache.totalCostLimit = 50 * 1024 * 1024  // 50 MB

        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheDirectory = caches.appendingPathComponent("favicons", isDirectory: true)
        try? FileManager.default.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
    }

    func image(for url: URL) async -> UIImage? {
        let key = cacheKey(for: url)

        // 1. Memory cache
        if let cached = memoryCache.object(forKey: key as NSString) {
            return cached
        }

        // 2. Disk cache
        let diskURL = diskCacheDirectory.appendingPathComponent(key)
        if let data = try? Data(contentsOf: diskURL), let image = UIImage(data: data) {
            memoryCache.setObject(image, forKey: key as NSString)
            return image
        }

        // 3. Download
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else {
            return nil
        }

        // Store in both caches
        memoryCache.setObject(image, forKey: key as NSString)
        try? data.write(to: diskURL)

        return image
    }

    // MARK: - Private

    private func cacheKey(for url: URL) -> String {
        let urlString = url.absoluteString
        let hash = SHA256.hash(data: Data(urlString.utf8))
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
