import XCTest
@testable import RadioLibre

@MainActor
final class SearchViewModelTests: XCTestCase {

    func testInitialState() {
        let vm = SearchViewModel()
        XCTAssertEqual(vm.query, "")
        XCTAssertTrue(vm.results.isEmpty)
        XCTAssertFalse(vm.isSearching)
        XCTAssertFalse(vm.hasSearched)
        XCTAssertNil(vm.error)
    }

    func testClearingQueryResetsState() async {
        let vm = SearchViewModel()
        vm.query = "test"
        // Give a moment for debounce setup
        try? await Task.sleep(nanoseconds: 100_000_000)
        vm.query = ""
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertFalse(vm.hasSearched)
        XCTAssertTrue(vm.results.isEmpty)
    }

    func testClearFiltersResetsFilters() {
        let vm = SearchViewModel()
        vm.filterCodec = "MP3"
        vm.filterBitrateMin = 128
        vm.filterLanguage = "english"
        vm.filterCountrycode = "US"
        vm.clearFilters()
        XCTAssertNil(vm.filterCodec)
        XCTAssertNil(vm.filterBitrateMin)
        XCTAssertNil(vm.filterLanguage)
        XCTAssertNil(vm.filterCountrycode)
    }
}
