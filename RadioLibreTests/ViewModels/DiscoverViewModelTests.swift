import XCTest
@testable import RadioLibre

@MainActor
final class DiscoverViewModelTests: XCTestCase {

    private var discovery: ServerDiscoveryService!
    private var service: RadioBrowserService!
    private var suiteName: String!
    private var cache: StationCacheService!

    override func setUp() async throws {
        discovery = ServerDiscoveryService()
        await discovery.setServers(["mock.api.radio-browser.info"])

        let session = TestFixtures.makeMockSession()
        service = RadioBrowserService(discovery: discovery, session: session)

        suiteName = "test.discover.\(UUID().uuidString)"
        let testDefaults = UserDefaults(suiteName: suiteName)!
        cache = StationCacheService(defaults: testDefaults)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        if let suiteName = suiteName {
            UserDefaults.standard.removePersistentDomain(forName: suiteName)
        }
    }

    func testLoadPopulatesAllSections() async {
        MockURLProtocol.requestHandler = { request in
            let data = TestFixtures.stationArrayJSON(count: 2).data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let vm = DiscoverViewModel(service: service, cache: cache)
        await vm.load()

        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.error)
        XCTAssertEqual(vm.topByClicks.count, 2)
        XCTAssertEqual(vm.topByVotes.count, 2)
        XCTAssertEqual(vm.localStations.count, 2)
        XCTAssertEqual(vm.recentlyChanged.count, 2)
        XCTAssertEqual(vm.currentlyPlaying.count, 2)
    }

    func testLoadSetsErrorOnFailure() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        let vm = DiscoverViewModel(service: service, cache: cache)
        await vm.load()

        XCTAssertFalse(vm.isLoading)
        XCTAssertNotNil(vm.error)
    }

    func testLoadSetsErrorForServerError() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let vm = DiscoverViewModel(service: service, cache: cache)
        await vm.load()

        XCTAssertNotNil(vm.error)
    }

    func testRefreshReloadsData() async {
        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            let data = TestFixtures.stationArrayJSON(count: 1).data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let vm = DiscoverViewModel(service: service, cache: cache)
        await vm.load()
        let firstCallCount = callCount
        XCTAssertGreaterThan(firstCallCount, 0)

        await vm.refresh()
        XCTAssertGreaterThan(callCount, firstCallCount)
    }

    func testLoadGuardsAgainstConcurrency() async {
        MockURLProtocol.requestHandler = { request in
            let data = TestFixtures.stationArrayJSON(count: 1).data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let vm = DiscoverViewModel(service: service, cache: cache)
        vm.isLoading = true // simulate already loading

        // Should return immediately due to guard
        await vm.load()

        // isLoading still true because guard returned early
        XCTAssertTrue(vm.isLoading)
    }

    func testInitialState() {
        let vm = DiscoverViewModel(service: service, cache: cache)

        XCTAssertTrue(vm.localStations.isEmpty)
        XCTAssertTrue(vm.topByClicks.isEmpty)
        XCTAssertTrue(vm.topByVotes.isEmpty)
        XCTAssertTrue(vm.recentlyChanged.isEmpty)
        XCTAssertTrue(vm.currentlyPlaying.isEmpty)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.error)
    }

    // MARK: - Cache Tests

    func testCachedDataShownOnNetworkFailure() async {
        let stations = [TestFixtures.makeStation(uuid: "cached-1", name: "Cached Station")]
        let localCountry = Locale.current.region?.identifier ?? "US"
        await cache.save(key: StationCacheService.localKey(countryCode: localCountry), value: stations)
        await cache.save(key: StationCacheService.discoverTopClicks, value: stations)
        await cache.save(key: StationCacheService.discoverTopVotes, value: stations)
        await cache.save(key: StationCacheService.discoverRecentlyChanged, value: stations)
        await cache.save(key: StationCacheService.discoverCurrentlyPlaying, value: stations)

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        let vm = DiscoverViewModel(service: service, cache: cache)
        await vm.load()

        XCTAssertEqual(vm.topByClicks.count, 1)
        XCTAssertEqual(vm.topByClicks[0].name, "Cached Station")
        XCTAssertNil(vm.error)
        XCTAssertFalse(vm.isLoading)
    }

    func testFreshDataReplacesCachedData() async {
        let oldStations = [TestFixtures.makeStation(uuid: "old-1", name: "Old Station")]
        let localCountry = Locale.current.region?.identifier ?? "US"
        await cache.save(key: StationCacheService.localKey(countryCode: localCountry), value: oldStations)
        await cache.save(key: StationCacheService.discoverTopClicks, value: oldStations)
        await cache.save(key: StationCacheService.discoverTopVotes, value: oldStations)
        await cache.save(key: StationCacheService.discoverRecentlyChanged, value: oldStations)
        await cache.save(key: StationCacheService.discoverCurrentlyPlaying, value: oldStations)

        MockURLProtocol.requestHandler = { request in
            let data = TestFixtures.stationArrayJSON(count: 3).data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let vm = DiscoverViewModel(service: service, cache: cache)
        await vm.load()

        XCTAssertEqual(vm.topByClicks.count, 3)
        XCTAssertFalse(vm.isLoading)
    }

    func testCacheUpdatedAfterSuccessfulFetch() async {
        MockURLProtocol.requestHandler = { request in
            let data = TestFixtures.stationArrayJSON(count: 2).data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let vm = DiscoverViewModel(service: service, cache: cache)
        await vm.load()

        let cached: [StationDTO]? = await cache.load(key: StationCacheService.discoverTopClicks)
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.count, 2)
    }

    func testNetworkFailureWithoutCacheShowsError() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        let vm = DiscoverViewModel(service: service, cache: cache)
        await vm.load()

        XCTAssertNotNil(vm.error)
        XCTAssertTrue(vm.localStations.isEmpty)
        XCTAssertFalse(vm.isLoading)
    }
}
