import XCTest
@testable import LibreRadio

final class NowPlayingWidgetDataTests: XCTestCase {

    func testCodableRoundTrip() throws {
        let data = NowPlayingWidgetData(
            stationName: "Jazz FM",
            codec: "MP3",
            bitrateLabel: "128k",
            flagEmoji: "🇫🇷",
            countryLocation: "FR Paris",
            isPlaying: true,
            isLoading: false,
            isBuffering: false,
            faviconData: Data([0xFF, 0xD8, 0xFF])
        )

        let encoded = try JSONEncoder().encode(data)
        let decoded = try JSONDecoder().decode(NowPlayingWidgetData.self, from: encoded)

        XCTAssertEqual(data, decoded)
    }

    func testCodableRoundTripWithNilFields() throws {
        let data = NowPlayingWidgetData(
            stationName: "Minimal",
            codec: nil,
            bitrateLabel: "—",
            flagEmoji: nil,
            countryLocation: nil,
            isPlaying: false,
            isLoading: true,
            isBuffering: false,
            faviconData: nil
        )

        let encoded = try JSONEncoder().encode(data)
        let decoded = try JSONDecoder().decode(NowPlayingWidgetData.self, from: encoded)

        XCTAssertEqual(data, decoded)
        XCTAssertNil(decoded.codec)
        XCTAssertNil(decoded.flagEmoji)
        XCTAssertNil(decoded.countryLocation)
        XCTAssertNil(decoded.faviconData)
    }

    func testEquatableEqual() {
        let a = NowPlayingWidgetData(
            stationName: "Jazz FM", codec: "MP3", bitrateLabel: "128k",
            flagEmoji: "🇫🇷", countryLocation: "FR", isPlaying: true,
            isLoading: false, isBuffering: false, faviconData: nil
        )
        let b = NowPlayingWidgetData(
            stationName: "Jazz FM", codec: "MP3", bitrateLabel: "128k",
            flagEmoji: "🇫🇷", countryLocation: "FR", isPlaying: true,
            isLoading: false, isBuffering: false, faviconData: nil
        )
        XCTAssertEqual(a, b)
    }

    func testEquatableNotEqual() {
        let a = NowPlayingWidgetData(
            stationName: "Jazz FM", codec: "MP3", bitrateLabel: "128k",
            flagEmoji: "🇫🇷", countryLocation: "FR", isPlaying: true,
            isLoading: false, isBuffering: false, faviconData: nil
        )
        let b = NowPlayingWidgetData(
            stationName: "Rock FM", codec: "AAC", bitrateLabel: "256k",
            flagEmoji: "🇦🇷", countryLocation: "AR", isPlaying: false,
            isLoading: true, isBuffering: false, faviconData: nil
        )
        XCTAssertNotEqual(a, b)
    }
}
