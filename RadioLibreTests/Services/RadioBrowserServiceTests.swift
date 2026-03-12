import XCTest
@testable import RadioLibre

final class RadioBrowserServiceTests: XCTestCase {

    // MARK: - Station decoding

    func testStationDTODecoding() throws {
        let json = """
        [{
            "stationuuid": "test-uuid-1234",
            "name": "Test Radio",
            "url": "https://stream.example.com/radio",
            "url_resolved": "https://stream.example.com/radio",
            "homepage": "https://example.com",
            "favicon": "https://example.com/icon.png",
            "tags": "rock,jazz,classic",
            "country": "Germany",
            "countrycode": "DE",
            "state": "",
            "language": "german",
            "languagecodes": "de",
            "codec": "MP3",
            "bitrate": 128,
            "hls": 0,
            "votes": 1000,
            "clickcount": 500,
            "clicktrend": 50,
            "lastcheckok": 1,
            "lastcheckoktime": "2026-01-01 12:00:00",
            "lastcheckoktime_iso8601": "2026-01-01T12:00:00Z",
            "geo_lat": null,
            "geo_long": null,
            "has_extended_info": false
        }]
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let stations = try decoder.decode([StationDTO].self, from: json)

        XCTAssertEqual(stations.count, 1)
        let station = stations[0]
        XCTAssertEqual(station.stationuuid, "test-uuid-1234")
        XCTAssertEqual(station.name, "Test Radio")
        XCTAssertEqual(station.urlResolved, "https://stream.example.com/radio")
        XCTAssertEqual(station.codec, "MP3")
        XCTAssertEqual(station.bitrate, 128)
        XCTAssertFalse(station.isHLS)
        XCTAssertTrue(station.isOnline)
        XCTAssertEqual(station.tagList, ["rock", "jazz", "classic"])
        XCTAssertEqual(station.bitrateLabel, "128k")
        XCTAssertNotNil(station.streamURL)
    }

    func testStationDTOTagListParsing() {
        let stationJSON = """
        {
            "stationuuid": "abc",
            "name": "Test",
            "url": "https://example.com/stream",
            "tags": "  rock , jazz ,  blues  "
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let station = try? decoder.decode(StationDTO.self, from: stationJSON)
        XCTAssertEqual(station?.tagList, ["rock", "jazz", "blues"])
    }

    func testEmptyTagList() {
        let stationJSON = """
        {
            "stationuuid": "abc",
            "name": "Test",
            "url": "https://example.com/stream"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let station = try? decoder.decode(StationDTO.self, from: stationJSON)
        XCTAssertEqual(station?.tagList, [])
    }

    // MARK: - Country decoding

    func testCountryDecoding() throws {
        let json = """
        [{"name": "Germany", "iso_3166_1": "DE", "stationcount": 500}]
        """.data(using: .utf8)!

        let countries = try JSONDecoder().decode([Country].self, from: json)
        XCTAssertEqual(countries.count, 1)
        XCTAssertEqual(countries[0].name, "Germany")
        XCTAssertEqual(countries[0].iso3166, "DE")
        XCTAssertEqual(countries[0].stationcount, 500)
    }

    // MARK: - Vote response decoding

    func testVoteResponseDecoding() throws {
        let json = #"{"ok": true, "message": "voted for station successfully"}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(VoteResponse.self, from: json)
        XCTAssertTrue(response.ok)
        XCTAssertEqual(response.message, "voted for station successfully")
    }
}
