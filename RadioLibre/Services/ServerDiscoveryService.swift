import Foundation

/// Discovers and manages Radio Browser API servers via DNS resolution with caching.
actor ServerDiscoveryService {
    static let shared = ServerDiscoveryService()

    private var servers: [String] = []
    private var currentIndex: Int = 0
    private var lastResolved: Date?
    private let ttl: TimeInterval = 86400  // 24 hours

    private let userDefaultsServersKey = "radio_browser_servers"
    private let userDefaultsTimestampKey = "radio_browser_servers_ts"

    private let fallbackServers = [
        "de1.api.radio-browser.info",
        "nl1.api.radio-browser.info",
        "at1.api.radio-browser.info"
    ]

    var currentBaseURL: URL {
        let host = servers.isEmpty ? fallbackServers[0] : servers[currentIndex % servers.count]
        return URL(string: "https://\(host)")!
    }

    func resolveIfNeeded() async {
        // Check if cached servers are still valid
        if let cached = loadCachedServers(), !cached.isEmpty {
            if let ts = UserDefaults.standard.object(forKey: userDefaultsTimestampKey) as? Date,
               Date().timeIntervalSince(ts) < ttl {
                servers = cached
                lastResolved = ts
                return
            }
        }
        await resolve()
    }

    func rotateServer() {
        guard servers.count > 1 else { return }
        currentIndex = (currentIndex + 1) % servers.count
    }

    // MARK: - Private

    private func resolve() async {
        // Try DNS-based discovery by resolving all.api.radio-browser.info
        let resolved = await resolveDNS()
        if !resolved.isEmpty {
            servers = resolved.shuffled()
            lastResolved = Date()
            cacheServers(servers)
            return
        }

        // Fallback: use hardcoded list
        servers = fallbackServers.shuffled()
        lastResolved = Date()
        cacheServers(servers)
    }

    private func resolveDNS() async -> [String] {
        // Use getaddrinfo to resolve all.api.radio-browser.info
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                var hints = addrinfo()
                hints.ai_family = AF_UNSPEC
                hints.ai_socktype = SOCK_STREAM

                var result: UnsafeMutablePointer<addrinfo>?
                let status = getaddrinfo("all.api.radio-browser.info", nil, &hints, &result)
                guard status == 0, let result else {
                    continuation.resume(returning: [])
                    return
                }
                defer { freeaddrinfo(result) }

                var hosts: Set<String> = []
                var current = result
                while let info = current {
                    var hostname = [CChar](repeating: 0, count: 256)
                    let addr = info.pointee.ai_addr
                    let addrLen = info.pointee.ai_addrlen
                    if getnameinfo(addr, addrLen, &hostname, 256, nil, 0, NI_NAMEREQD) == 0 {
                        let host = String(cString: hostname)
                        if !host.isEmpty { hosts.insert(host) }
                    }
                    current = info.pointee.ai_next
                }
                continuation.resume(returning: Array(hosts))
            }
        }
    }

    private func loadCachedServers() -> [String]? {
        UserDefaults.standard.stringArray(forKey: userDefaultsServersKey)
    }

    private func cacheServers(_ servers: [String]) {
        UserDefaults.standard.set(servers, forKey: userDefaultsServersKey)
        UserDefaults.standard.set(Date(), forKey: userDefaultsTimestampKey)
    }
}
