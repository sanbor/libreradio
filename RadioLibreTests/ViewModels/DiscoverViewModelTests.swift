import XCTest
@testable import RadioLibre

@MainActor
final class DiscoverViewModelTests: XCTestCase {

    func testInitialState() {
        let vm = DiscoverViewModel()
        XCTAssertTrue(vm.localStations.isEmpty)
        XCTAssertTrue(vm.topByClicks.isEmpty)
        XCTAssertTrue(vm.topByVotes.isEmpty)
        XCTAssertTrue(vm.recentlyChanged.isEmpty)
        XCTAssertTrue(vm.currentlyPlaying.isEmpty)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.error)
    }
}
