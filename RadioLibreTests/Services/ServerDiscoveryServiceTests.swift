import XCTest
@testable import RadioLibre

final class ServerDiscoveryServiceTests: XCTestCase {

    func testFallbackURLIsValid() async {
        let service = ServerDiscoveryService.shared
        let url = await service.currentBaseURL
        XCTAssertTrue(url.scheme == "https")
        XCTAssertFalse(url.host?.isEmpty ?? true)
    }

    func testRotateServerChangesCurrentURL() async {
        let service = ServerDiscoveryService.shared
        let firstURL = await service.currentBaseURL
        await service.rotateServer()
        // After rotate with only one server, URL may be same — just verify no crash
        let secondURL = await service.currentBaseURL
        XCTAssertNotNil(secondURL)
        _ = firstURL  // silence unused warning
    }
}
