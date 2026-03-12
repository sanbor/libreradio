import XCTest
import SwiftData
@testable import RadioLibre

@MainActor
final class FavoritesViewModelTests: XCTestCase {

    private func makeContext() throws -> ModelContext {
        let schema = Schema([FavoriteStation.self, HistoryEntry.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        return ModelContext(container)
    }

    private func makeStation(uuid: String = "test-uuid") -> StationDTO {
        StationDTO(
            stationuuid: uuid,
            name: "Test Radio",
            url: "https://example.com/stream",
            urlResolved: "https://example.com/stream",
            homepage: nil,
            favicon: nil,
            tags: "rock,jazz",
            country: "US",
            countrycode: "US",
            state: nil,
            language: "english",
            languagecodes: "en",
            codec: "MP3",
            bitrate: 128,
            hls: 0,
            votes: 100,
            clickcount: 50,
            clicktrend: 5,
            lastcheckok: 1,
            lastcheckoktime: nil,
            lastcheckoktime_iso8601: nil,
            geoLat: nil,
            geoLong: nil,
            hasExtendedInfo: false
        )
    }

    func testAddAndRemoveFavorite() throws {
        let context = try makeContext()
        let vm = FavoritesViewModel()
        let station = makeStation()

        XCTAssertFalse(vm.isFavorite(uuid: station.stationuuid, context: context))
        vm.addFavorite(station: station, context: context)
        XCTAssertTrue(vm.isFavorite(uuid: station.stationuuid, context: context))
        vm.removeFavorite(uuid: station.stationuuid, context: context)
        XCTAssertFalse(vm.isFavorite(uuid: station.stationuuid, context: context))
    }

    func testToggleFavorite() throws {
        let context = try makeContext()
        let vm = FavoritesViewModel()
        let station = makeStation(uuid: "toggle-uuid")

        vm.toggleFavorite(station: station, context: context)
        XCTAssertTrue(vm.isFavorite(uuid: station.stationuuid, context: context))

        vm.toggleFavorite(station: station, context: context)
        XCTAssertFalse(vm.isFavorite(uuid: station.stationuuid, context: context))
    }

    func testAddDuplicateFavorite() throws {
        let context = try makeContext()
        let vm = FavoritesViewModel()
        let station = makeStation(uuid: "dup-uuid")

        vm.addFavorite(station: station, context: context)
        vm.addFavorite(station: station, context: context)  // Should not crash or duplicate

        let descriptor = FetchDescriptor<FavoriteStation>()
        let count = try context.fetch(descriptor).count
        XCTAssertEqual(count, 1)
    }
}
