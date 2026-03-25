import Foundation
import UIKit
import WidgetKit

@MainActor
final class WidgetDataService {
    static let shared = WidgetDataService()

    private let defaults: UserDefaults?
    private var currentStationId: String?
    private var currentFaviconData: Data?
    private var lastWrittenData: NowPlayingWidgetData?
    private(set) var writeCount = 0

    init(defaults: UserDefaults? = UserDefaults(suiteName: NowPlayingWidgetData.suiteName)) {
        self.defaults = defaults
    }

    func update(station: StationDTO, isPlaying: Bool, isLoading: Bool, isBuffering: Bool) {
        if station.stationuuid != currentStationId {
            currentStationId = station.stationuuid
            currentFaviconData = nil
            fetchFavicon(for: station)
        }

        let data = NowPlayingWidgetData(
            stationName: station.name,
            codec: station.codec,
            bitrateLabel: station.bitrateLabel,
            flagEmoji: station.flagEmoji,
            countryLocation: station.locationLabel,
            isPlaying: isPlaying,
            isLoading: isLoading,
            isBuffering: isBuffering,
            faviconData: currentFaviconData
        )

        guard data != lastWrittenData else { return }
        lastWrittenData = data
        writeToDefaults(data)
    }

    func clear() {
        currentStationId = nil
        currentFaviconData = nil
        lastWrittenData = nil
        defaults?.removeObject(forKey: NowPlayingWidgetData.userDefaultsKey)
        writeCount += 1
        WidgetCenter.shared.reloadTimelines(ofKind: NowPlayingWidgetData.widgetKind)
    }

    // MARK: - Private

    private func writeToDefaults(_ data: NowPlayingWidgetData) {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        defaults?.set(encoded, forKey: NowPlayingWidgetData.userDefaultsKey)
        writeCount += 1
        WidgetCenter.shared.reloadTimelines(ofKind: NowPlayingWidgetData.widgetKind)
    }

    private func fetchFavicon(for station: StationDTO) {
        guard let url = station.faviconURL else { return }
        let stationId = station.stationuuid

        Task {
            guard let image = await ImageCacheService.shared.image(for: url) else { return }

            let size = CGSize(width: 80, height: 80)
            let renderer = UIGraphicsImageRenderer(size: size)
            let resized = renderer.jpegData(withCompressionQuality: 0.7) { context in
                image.draw(in: CGRect(origin: .zero, size: size))
            }

            guard currentStationId == stationId else { return }
            currentFaviconData = resized

            // Re-build and write updated data with favicon
            if let last = lastWrittenData {
                let updated = NowPlayingWidgetData(
                    stationName: last.stationName,
                    codec: last.codec,
                    bitrateLabel: last.bitrateLabel,
                    flagEmoji: last.flagEmoji,
                    countryLocation: last.countryLocation,
                    isPlaying: last.isPlaying,
                    isLoading: last.isLoading,
                    isBuffering: last.isBuffering,
                    faviconData: resized
                )
                lastWrittenData = updated
                writeToDefaults(updated)
            }
        }
    }
}
