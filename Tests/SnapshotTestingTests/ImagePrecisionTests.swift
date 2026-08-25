import XCTest

@testable import SnapshotTesting

final class ImagePrecisionTests: XCTestCase {
  func testImagePrecisionFailureMessage_passesWithinOneByteTolerance() {
    let byteCount = 1_000_000
    let threshold = Int((1 - 0.96) * Float(byteCount))
    let differentByteCount = threshold + 1

    XCTAssertNil(
      imagePrecisionFailureMessage(
        differentUnitCount: differentByteCount,
        unitCount: byteCount,
        precision: 0.96
      )
    )
  }

  func testImagePrecisionFailureMessage_failsForMeaningfulDifference() {
    let byteCount = 1_000_000
    let differentByteCount = Int((1 - 0.90) * Float(byteCount))

    XCTAssertEqual(
      imagePrecisionFailureMessage(
        differentUnitCount: differentByteCount,
        unitCount: byteCount,
        precision: 0.96
      ),
      "Actual image precision 0.9 is less than required 0.96"
    )
  }

  func testImagePrecisionFailureMessage_passesWhenPrecisionMatches() {
    XCTAssertNil(
      imagePrecisionFailureMessage(
        differentUnitCount: 0,
        unitCount: 10_000,
        precision: 0.98
      )
    )
  }
}
