import Foundation

struct StationDTO: Codable, Identifiable, Hashable {
    var id: String { stationuuid }

    let stationuuid: String
    let name: String
    let url: String
    let urlResolved: String?
    let homepage: String?
    let favicon: String?
    let tags: String?
    let country: String?
    let countrycode: String?
    let state: String?
    let language: String?
    let languagecodes: String?
    let codec: String?
    let bitrate: Int?
    let hls: Int?
    let votes: Int?
    let clickcount: Int?
    let clicktrend: Int?
    let lastcheckok: Int?
    let lastcheckoktime: String?
    let lastcheckoktime_iso8601: String?
    let geoLat: Double?
    let geoLong: Double?
    let hasExtendedInfo: Bool?

    enum CodingKeys: String, CodingKey {
        case stationuuid
        case name
        case url
        case urlResolved = "url_resolved"
        case homepage
        case favicon
        case tags
        case country
        case countrycode
        case state
        case language
        case languagecodes
        case codec
        case bitrate
        case hls
        case votes
        case clickcount
        case clicktrend
        case lastcheckok
        case lastcheckoktime
        case lastcheckoktime_iso8601
        case geoLat = "geo_lat"
        case geoLong = "geo_long"
        case hasExtendedInfo = "has_extended_info"
    }

    // MARK: - Computed helpers

    var tagList: [String] {
        guard let tags, !tags.isEmpty else { return [] }
        return tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    var isHLS: Bool { hls == 1 }

    var isOnline: Bool { lastcheckok == 1 }

    var streamURL: URL? {
        if let resolved = urlResolved, !resolved.isEmpty, let url = URL(string: resolved) {
            return url
        }
        return URL(string: url)
    }

    var faviconURL: URL? {
        guard let favicon, !favicon.isEmpty else { return nil }
        return URL(string: favicon)
    }

    var homepageURL: URL? {
        guard let homepage, !homepage.isEmpty else { return nil }
        return URL(string: homepage)
    }

    var bitrateLabel: String {
        guard let bitrate, bitrate > 0 else { return "—" }
        return "\(bitrate)k"
    }

    var codecDisplay: String {
        codec ?? "—"
    }

    var countryFlag: String {
        countrycode?.countryFlag ?? ""
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(stationuuid)
    }

    static func == (lhs: StationDTO, rhs: StationDTO) -> Bool {
        lhs.stationuuid == rhs.stationuuid
    }
}
