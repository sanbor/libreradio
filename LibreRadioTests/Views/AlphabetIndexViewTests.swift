import XCTest
@testable import LibreRadio

final class AlphabetIndexViewTests: XCTestCase {

    // MARK: - letterIndex(forY:letterCount:)

    func testIndexAtTopReturnsZero() {
        // Y just inside the top padding (4pt). Letter 0 starts at adjustedY=0.
        let index = AlphabetIndexView.letterIndex(forY: 5, letterCount: 26)
        XCTAssertEqual(index, 0)
    }

    func testIndexAtBottomReturnsLastIndex() {
        // 26 letters × 16pt each + 4pt top padding = last letter ends at y=419.
        // y=420 falls in the 4pt bottom padding, which clamps to the last letter.
        let index = AlphabetIndexView.letterIndex(forY: 420, letterCount: 26)
        XCTAssertEqual(index, 25)
    }

    func testIndexAboveRangeReturnsNil() {
        let index = AlphabetIndexView.letterIndex(forY: -10, letterCount: 26)
        XCTAssertNil(index)
    }

    func testIndexBelowRangeReturnsNil() {
        // y=500 is past the total view height (26*16+8=424), so it returns nil.
        let index = AlphabetIndexView.letterIndex(forY: 500, letterCount: 26)
        XCTAssertNil(index)
    }

    func testIndexInMiddleReturnsCorrectIndex() {
        // For 5 letters, each 16pt. Y=30 → adjustedY=26 → Int(26/16)=1.
        let index = AlphabetIndexView.letterIndex(forY: 30, letterCount: 5)
        XCTAssertEqual(index, 1)
    }

    func testZeroLetterCountReturnsNil() {
        let index = AlphabetIndexView.letterIndex(forY: 10, letterCount: 0)
        XCTAssertNil(index)
    }

    func testSingleLetterReturnsZero() {
        // 1 letter: occupies y=4–19. Y=5 → adjustedY=1 → Int(1/16)=0.
        let index = AlphabetIndexView.letterIndex(forY: 5, letterCount: 1)
        XCTAssertEqual(index, 0)
    }

    func testSingleLetterOutOfRangeReturnsNil() {
        // 1 letter: total height = 1*16+8 = 24. y=30 >= 24 → nil.
        let index = AlphabetIndexView.letterIndex(forY: 30, letterCount: 1)
        XCTAssertNil(index)
    }

    func testExactBoundaryReturnsCorrectIndex() {
        // For 3 letters, each 16pt, starting at y=4 (top padding).
        // Y=4 → adjustedY=0 → Int(0/16)=0.
        let index = AlphabetIndexView.letterIndex(forY: 4, letterCount: 3)
        XCTAssertEqual(index, 0)
    }
}
