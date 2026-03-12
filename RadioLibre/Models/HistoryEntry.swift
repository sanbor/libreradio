import Foundation
import SwiftData

@Model
final class HistoryEntry {
    @Attribute(.unique) var id: UUID
    var stationuuid: String
    var name: String
    var urlResolved: String
    var faviconURL: String?
    var codec: String?
    var bitrate: Int
    var countrycode: String?
    var playedAt: Date

    init(from dto: StationDTO) {
        self.id = UUID()
        self.stationuuid = dto.stationuuid
        self.name = dto.name
        self.urlResolved = dto.urlResolved ?? dto.url
        self.faviconURL = dto.favicon
        self.codec = dto.codec
        self.bitrate = dto.bitrate ?? 0
        self.countrycode = dto.countrycode
        self.playedAt = Date()
    }

    func toDTO() -> StationDTO {
        StationDTO(
            stationuuid: stationuuid,
            name: name,
            url: urlResolved,
            urlResolved: urlResolved,
            homepage: nil,
            favicon: faviconURL,
            tags: nil,
            country: nil,
            countrycode: countrycode,
            state: nil,
            language: nil,
            languagecodes: nil,
            codec: codec,
            bitrate: bitrate,
            hls: 0,
            votes: nil,
            clickcount: nil,
            clicktrend: nil,
            lastcheckok: nil,
            lastcheckoktime: nil,
            lastcheckoktime_iso8601: nil,
            geoLat: nil,
            geoLong: nil,
            hasExtendedInfo: nil
        )
    }
}
