import XCTest
@testable import LibreRadio

@MainActor
final class WidgetDataServiceTests: XCTestCase {

    private func makeDefaults() -> UserDefaults {
        let suiteName = "test-\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }

    private func readData(from defaults: UserDefaults) -> NowPlayingWidgetData? {
        guard let data = defaults.data(forKey: NowPlayingWidgetData.userDefaultsKey) else { return nil }
        return try? JSONDecoder().decode(NowPlayingWidgetData.self, from: data)
    }

    // MARK: - Update

    func testUpdateWritesToDefaults() {
        let defaults = makeDefaults()
        let service = WidgetDataService(defaults: defaults)
        let station = StationDTOTests.makeStation(
            name: "Jazz FM",
            country: "France",
            countrycode: "FR",
            codec: "MP3",
            bitrate: 128
        )

        service.update(station: station, isPlaying: true, isLoading: false, isBuffering: false)

        let stored = readData(from: defaults)
        XCTAssertNotNil(stored)
        XCTAssertEqual(stored?.stationName, "Jazz FM")
        XCTAssertEqual(stored?.codec, "MP3")
        XCTAssertEqual(stored?.bitrateLabel, "128k")
        XCTAssertEqual(stored?.flagEmoji, "🇫🇷")
        XCTAssertTrue(stored?.isPlaying ?? false)
        XCTAssertFalse(stored?.isLoading ?? true)
        XCTAssertFalse(stored?.isBuffering ?? true)
    }

    // MARK: - Clear

    func testClearRemovesData() {
        let defaults = makeDefaults()
        let service = WidgetDataService(defaults: defaults)
        let station = StationDTOTests.makeStation(name: "Test")

        service.update(station: station, isPlaying: true, isLoading: false, isBuffering: false)
        XCTAssertNotNil(readData(from: defaults))

        service.clear()
        XCTAssertNil(readData(from: defaults))
    }

    // MARK: - Station Change

    func testStationChangeClearsFavicon() {
        let defaults = makeDefaults()
        let service = WidgetDataService(defaults: defaults)
        let stationA = StationDTOTests.makeStation(uuid: "a", name: "Station A")
        let stationB = StationDTOTests.makeStation(uuid: "b", name: "Station B")

        service.update(station: stationA, isPlaying: true, isLoading: false, isBuffering: false)
        service.update(station: stationB, isPlaying: true, isLoading: false, isBuffering: false)

        let stored = readData(from: defaults)
        XCTAssertEqual(stored?.stationName, "Station B")
        XCTAssertNil(stored?.faviconData)
    }

    // MARK: - Deduplication

    func testDeduplicationSkipsIdenticalWrite() {
        let defaults = makeDefaults()
        let service = WidgetDataService(defaults: defaults)
        let station = StationDTOTests.makeStation(name: "Test")

        service.update(station: station, isPlaying: true, isLoading: false, isBuffering: false)
        let writeCountAfterFirst = service.writeCount

        service.update(station: station, isPlaying: true, isLoading: false, isBuffering: false)
        XCTAssertEqual(service.writeCount, writeCountAfterFirst, "Identical update should not trigger another write")
    }

    func testDifferentStateTriggersWrite() {
        let defaults = makeDefaults()
        let service = WidgetDataService(defaults: defaults)
        let station = StationDTOTests.makeStation(name: "Test")

        service.update(station: station, isPlaying: true, isLoading: false, isBuffering: false)
        let writeCountAfterFirst = service.writeCount

        service.update(station: station, isPlaying: false, isLoading: false, isBuffering: false)
        XCTAssertEqual(service.writeCount, writeCountAfterFirst + 1)
    }

    // MARK: - Nil Defaults

    func testNilDefaultsDoesNotCrash() {
        let service = WidgetDataService(defaults: nil)
        let station = StationDTOTests.makeStation(name: "Test")

        service.update(station: station, isPlaying: true, isLoading: false, isBuffering: false)
        service.clear()
        // No crash = pass
    }
}
