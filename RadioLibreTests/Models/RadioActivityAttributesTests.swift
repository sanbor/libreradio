import XCTest
@testable import RadioLibre

@available(iOS 16.2, *)
final class RadioActivityAttributesTests: XCTestCase {

    // MARK: - ContentState Codable

    func testContentStateEncodesAndDecodesAllFields() throws {
        let state = RadioActivityAttributes.ContentState(
            stationName: "Jazz FM",
            codec: "MP3",
            bitrateLabel: "128k",
            flagEmoji: "🇫🇷",
            countryName: "France",
            isPlaying: true,
            isLoading: false,
            isBuffering: false
        )

        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(RadioActivityAttributes.ContentState.self, from: data)

        XCTAssertEqual(decoded.stationName, "Jazz FM")
        XCTAssertEqual(decoded.codec, "MP3")
        XCTAssertEqual(decoded.bitrateLabel, "128k")
        XCTAssertEqual(decoded.flagEmoji, "🇫🇷")
        XCTAssertEqual(decoded.countryName, "France")
        XCTAssertEqual(decoded.isPlaying, true)
        XCTAssertEqual(decoded.isLoading, false)
        XCTAssertEqual(decoded.isBuffering, false)
    }

    func testContentStateEncodesAndDecodesNetherlandsFields() throws {
        let state = RadioActivityAttributes.ContentState(
            stationName: "Radio NL",
            codec: "AAC",
            bitrateLabel: "192k",
            flagEmoji: "🇳🇱",
            countryName: "Netherlands",
            isPlaying: true,
            isLoading: false,
            isBuffering: false
        )

        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(RadioActivityAttributes.ContentState.self, from: data)

        XCTAssertEqual(decoded.stationName, "Radio NL")
        XCTAssertEqual(decoded.flagEmoji, "🇳🇱")
        XCTAssertEqual(decoded.countryName, "Netherlands")
    }

    func testContentStateEncodesAndDecodesNilOptionals() throws {
        let state = RadioActivityAttributes.ContentState(
            stationName: "Minimal",
            codec: nil,
            bitrateLabel: "—",
            flagEmoji: nil,
            countryName: nil,
            isPlaying: false,
            isLoading: true,
            isBuffering: false
        )

        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(RadioActivityAttributes.ContentState.self, from: data)

        XCTAssertEqual(decoded.stationName, "Minimal")
        XCTAssertNil(decoded.codec)
        XCTAssertEqual(decoded.bitrateLabel, "—")
        XCTAssertNil(decoded.flagEmoji)
        XCTAssertNil(decoded.countryName)
        XCTAssertEqual(decoded.isPlaying, false)
        XCTAssertEqual(decoded.isLoading, true)
    }

    // MARK: - Hashable

    func testContentStateEqualWhenAllFieldsMatch() {
        let a = RadioActivityAttributes.ContentState(
            stationName: "Jazz FM", codec: "MP3", bitrateLabel: "128k",
            flagEmoji: "🇫🇷", countryName: "France", isPlaying: true, isLoading: false, isBuffering: false
        )
        let b = RadioActivityAttributes.ContentState(
            stationName: "Jazz FM", codec: "MP3", bitrateLabel: "128k",
            flagEmoji: "🇫🇷", countryName: "France", isPlaying: true, isLoading: false, isBuffering: false
        )
        XCTAssertEqual(a, b)
    }

    func testContentStateNotEqualWhenFieldsDiffer() {
        let a = RadioActivityAttributes.ContentState(
            stationName: "Jazz FM", codec: "MP3", bitrateLabel: "128k",
            flagEmoji: "🇫🇷", countryName: "France", isPlaying: true, isLoading: false, isBuffering: false
        )
        let b = RadioActivityAttributes.ContentState(
            stationName: "Rock FM", codec: "AAC", bitrateLabel: "256k",
            flagEmoji: "🇦🇷", countryName: "Argentina", isPlaying: false, isLoading: true, isBuffering: false
        )
        XCTAssertNotEqual(a, b)
    }

    func testContentStateCanBeUsedInSet() {
        let a = RadioActivityAttributes.ContentState(
            stationName: "Jazz FM", codec: "MP3", bitrateLabel: "128k",
            flagEmoji: nil, countryName: nil, isPlaying: true, isLoading: false, isBuffering: false
        )
        let b = RadioActivityAttributes.ContentState(
            stationName: "Rock FM", codec: "AAC", bitrateLabel: "256k",
            flagEmoji: nil, countryName: nil, isPlaying: false, isLoading: false, isBuffering: false
        )
        let set: Set = [a, b, a]
        XCTAssertEqual(set.count, 2)
    }
}
