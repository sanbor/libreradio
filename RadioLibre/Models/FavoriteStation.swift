import Foundation
import SwiftData

@Model
final class FavoriteStation {
    @Attribute(.unique) var stationuuid: String
    var name: String
    var urlResolved: String
    var faviconURL: String?
    var tags: String?
    var countrycode: String?
    var language: String?
    var codec: String?
    var bitrate: Int
    var addedAt: Date
    var sortOrder: Int

    init(from dto: StationDTO, sortOrder: Int = 0) {
        self.stationuuid = dto.stationuuid
        self.name = dto.name
        self.urlResolved = dto.urlResolved ?? dto.url
        self.faviconURL = dto.favicon
        self.tags = dto.tags
        self.countrycode = dto.countrycode
        self.language = dto.language
        self.codec = dto.codec
        self.bitrate = dto.bitrate ?? 0
        self.addedAt = Date()
        self.sortOrder = sortOrder
    }

    func toDTO() -> StationDTO {
        StationDTO(
            stationuuid: stationuuid,
            name: name,
            url: urlResolved,
            urlResolved: urlResolved,
            homepage: nil,
            favicon: faviconURL,
            tags: tags,
            country: nil,
            countrycode: countrycode,
            state: nil,
            language: language,
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
