import Foundation

struct NowPlayingWidgetData: Codable, Equatable {
    let stationName: String
    let codec: String?
    let bitrateLabel: String
    let flagEmoji: String?
    let countryLocation: String?
    let isPlaying: Bool
    let isLoading: Bool
    let isBuffering: Bool
    let faviconData: Data?

    static let suiteName = "group.org.libreradio.app"
    static let userDefaultsKey = "nowPlayingWidgetData"
    static let widgetKind = "NowPlayingWidget"
}
