import Foundation

/// All Radio Browser API calls. Thread-safe actor with automatic server rotation on failure.
actor RadioBrowserService {
    static let shared = RadioBrowserService()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let discovery: ServerDiscoveryService

    private init(discovery: ServerDiscoveryService = .shared) {
        self.discovery = discovery

        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["User-Agent": "RadioLibre/1.0 (iOS; Swift)"]
        config.timeoutIntervalForRequest = 15
        self.session = URLSession(configuration: config)

        let dec = JSONDecoder()
        self.decoder = dec
    }

    // MARK: - Discovery

    func fetchTopByClicks(limit: Int = 100) async throws -> [StationDTO] {
        try await fetch(path: "json/stations/topclick/\(limit)")
    }

    func fetchTopByVotes(limit: Int = 100) async throws -> [StationDTO] {
        try await fetch(path: "json/stations/topvote/\(limit)")
    }

    func fetchLastClick(limit: Int = 100) async throws -> [StationDTO] {
        try await fetch(path: "json/stations/lastclick/\(limit)")
    }

    func fetchLastChange(limit: Int = 100) async throws -> [StationDTO] {
        try await fetch(path: "json/stations/lastchange/\(limit)")
    }

    func fetchLocalStations(countrycode: String, limit: Int = 100) async throws -> [StationDTO] {
        let params = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "order", value: "clickcount"),
            URLQueryItem(name: "reverse", value: "true"),
            URLQueryItem(name: "hidebroken", value: "true")
        ]
        return try await fetch(path: "json/stations/bycountrycodeexact/\(countrycode)", queryItems: params)
    }

    // MARK: - Search

    func searchStations(
        name: String? = nil,
        countrycode: String? = nil,
        country: String? = nil,
        language: String? = nil,
        tag: String? = nil,
        tagList: String? = nil,
        codec: String? = nil,
        bitrateMin: Int? = nil,
        bitrateMax: Int? = nil,
        isHttps: Bool? = nil,
        order: String = "clickcount",
        reverse: Bool = true,
        limit: Int = 50,
        offset: Int = 0,
        hidebroken: Bool = true
    ) async throws -> [StationDTO] {
        var params: [URLQueryItem] = [
            URLQueryItem(name: "order", value: order),
            URLQueryItem(name: "reverse", value: reverse ? "true" : "false"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "hidebroken", value: hidebroken ? "true" : "false")
        ]
        if let name { params.append(URLQueryItem(name: "name", value: name)) }
        if let countrycode { params.append(URLQueryItem(name: "countrycode", value: countrycode)) }
        if let country { params.append(URLQueryItem(name: "country", value: country)) }
        if let language { params.append(URLQueryItem(name: "language", value: language)) }
        if let tag { params.append(URLQueryItem(name: "tag", value: tag)) }
        if let tagList { params.append(URLQueryItem(name: "tagList", value: tagList)) }
        if let codec { params.append(URLQueryItem(name: "codec", value: codec)) }
        if let bitrateMin { params.append(URLQueryItem(name: "bitrateMin", value: "\(bitrateMin)")) }
        if let bitrateMax { params.append(URLQueryItem(name: "bitrateMax", value: "\(bitrateMax)")) }
        if let isHttps { params.append(URLQueryItem(name: "is_https", value: isHttps ? "true" : "false")) }

        return try await fetch(path: "json/stations/search", queryItems: params)
    }

    // MARK: - Browse

    func fetchCountries(hidebroken: Bool = true) async throws -> [Country] {
        let params = [
            URLQueryItem(name: "order", value: "stationcount"),
            URLQueryItem(name: "reverse", value: "true"),
            URLQueryItem(name: "hidebroken", value: hidebroken ? "true" : "false")
        ]
        return try await fetch(path: "json/countries", queryItems: params)
    }

    func fetchLanguages(hidebroken: Bool = true) async throws -> [Language] {
        let params = [
            URLQueryItem(name: "order", value: "stationcount"),
            URLQueryItem(name: "reverse", value: "true"),
            URLQueryItem(name: "hidebroken", value: hidebroken ? "true" : "false")
        ]
        return try await fetch(path: "json/languages", queryItems: params)
    }

    func fetchTags(limit: Int = 200, hidebroken: Bool = true, order: String = "stationcount", reverse: Bool = true) async throws -> [Tag] {
        let params = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "order", value: order),
            URLQueryItem(name: "reverse", value: reverse ? "true" : "false"),
            URLQueryItem(name: "hidebroken", value: hidebroken ? "true" : "false")
        ]
        return try await fetch(path: "json/tags", queryItems: params)
    }

    // MARK: - Filtered station lists

    func fetchStationsByCountry(_ countrycode: String, order: String = "clickcount", reverse: Bool = true, limit: Int = 100, offset: Int = 0) async throws -> [StationDTO] {
        let params = [
            URLQueryItem(name: "order", value: order),
            URLQueryItem(name: "reverse", value: reverse ? "true" : "false"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "hidebroken", value: "true")
        ]
        return try await fetch(path: "json/stations/bycountrycodeexact/\(countrycode)", queryItems: params)
    }

    func fetchStationsByLanguage(_ language: String, order: String = "clickcount", reverse: Bool = true, limit: Int = 100, offset: Int = 0) async throws -> [StationDTO] {
        let params = [
            URLQueryItem(name: "order", value: order),
            URLQueryItem(name: "reverse", value: reverse ? "true" : "false"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "hidebroken", value: "true")
        ]
        return try await fetch(path: "json/stations/bylanguageexact/\(language)", queryItems: params)
    }

    func fetchStationsByTag(_ tag: String, order: String = "clickcount", reverse: Bool = true, limit: Int = 100, offset: Int = 0) async throws -> [StationDTO] {
        let params = [
            URLQueryItem(name: "order", value: order),
            URLQueryItem(name: "reverse", value: reverse ? "true" : "false"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "hidebroken", value: "true")
        ]
        return try await fetch(path: "json/stations/bytagexact/\(tag)", queryItems: params)
    }

    // MARK: - Station lookup

    func fetchStation(uuid: String) async throws -> StationDTO {
        let stations: [StationDTO] = try await fetch(path: "json/stations/byuuid", queryItems: [
            URLQueryItem(name: "uuids", value: uuid)
        ])
        guard let station = stations.first else {
            throw AppError.serverError(statusCode: 404)
        }
        return station
    }

    func fetchStations(uuids: [String]) async throws -> [StationDTO] {
        guard !uuids.isEmpty else { return [] }
        return try await fetch(path: "json/stations/byuuid", queryItems: [
            URLQueryItem(name: "uuids", value: uuids.joined(separator: ","))
        ])
    }

    // MARK: - Analytics (fire-and-forget)

    func trackClick(stationuuid: String) async {
        let baseURL = await discovery.currentBaseURL
        guard let url = URL(string: "\(baseURL)/json/url/\(stationuuid)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        _ = try? await session.data(for: request)
    }

    func vote(stationuuid: String) async throws -> VoteResponse {
        let baseURL = await discovery.currentBaseURL
        guard let url = URL(string: "\(baseURL)/json/vote/\(stationuuid)") else {
            throw AppError.streamURLInvalid
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw AppError.serverError(statusCode: http.statusCode)
        }
        do {
            return try decoder.decode(VoteResponse.self, from: data)
        } catch {
            throw AppError.decodingFailed(underlying: error)
        }
    }

    // MARK: - Server info

    func fetchStats() async throws -> ServerStats {
        try await fetchSingle(path: "json/stats")
    }

    // MARK: - Internal

    private func fetch<T: Decodable>(path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        let url = try buildURL(path: path, queryItems: queryItems)
        return try await performRequest(url: url)
    }

    private func fetchSingle<T: Decodable>(path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        let url = try buildURL(path: path, queryItems: queryItems)
        return try await performRequest(url: url)
    }

    private func buildURL(path: String, queryItems: [URLQueryItem]) async throws -> URL {
        let baseURL = await discovery.currentBaseURL
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        guard let url = components?.url else {
            throw AppError.streamURLInvalid
        }
        return url
    }

    private func performRequest<T: Decodable>(url: URL) async throws -> T {
        let request = URLRequest(url: url)
        do {
            let (data, response) = try await session.data(for: request)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                throw AppError.serverError(statusCode: http.statusCode)
            }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw AppError.decodingFailed(underlying: error)
            }
        } catch let error as AppError {
            throw error
        } catch {
            // Rotate server and retry once on network failures
            await discovery.rotateServer()
            let retryURL = try await buildURL(
                path: url.path.hasPrefix("/") ? String(url.path.dropFirst()) : url.path,
                queryItems: url.query.flatMap { URLComponents(string: "?\($0)")?.queryItems } ?? []
            )
            let (data, response) = try await session.data(for: URLRequest(url: retryURL))
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                throw AppError.serverError(statusCode: http.statusCode)
            }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw AppError.decodingFailed(underlying: error)
            }
        }
    }
}
