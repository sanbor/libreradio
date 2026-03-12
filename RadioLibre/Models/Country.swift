import Foundation

struct Country: Codable, Identifiable, Hashable {
    var id: String { iso3166 ?? name }

    let name: String
    let iso3166: String?
    let stationcount: Int

    enum CodingKeys: String, CodingKey {
        case name
        case iso3166 = "iso_3166_1"
        case stationcount
    }

    var flag: String {
        iso3166?.countryFlag ?? ""
    }
}
