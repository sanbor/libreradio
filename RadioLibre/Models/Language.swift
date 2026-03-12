import Foundation

struct Language: Codable, Identifiable, Hashable {
    var id: String { name }

    let name: String
    let iso639: String?
    let stationcount: Int

    enum CodingKeys: String, CodingKey {
        case name
        case iso639 = "iso_639"
        case stationcount
    }
}
