import Foundation

struct TrackHistoryItem: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let artist: String?
    let stationName: String
    let stationUUID: String
    let timestamp: Date

    init(
        id: UUID = UUID(),
        title: String,
        artist: String?,
        stationName: String,
        stationUUID: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.stationName = stationName
        self.stationUUID = stationUUID
        self.timestamp = timestamp
    }
}
