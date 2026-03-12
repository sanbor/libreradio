import Foundation

struct ClickResponse: Codable {
    let ok: Bool
    let message: String?
    let url: String?
    let stationuuid: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case ok
        case message
        case url
        case stationuuid
        case name
    }
}
