import Foundation

struct Tag: Codable, Identifiable, Hashable {
    var id: String { name }

    let name: String
    let stationcount: Int
}
