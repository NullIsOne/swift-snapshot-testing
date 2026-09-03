import XCTest

@testable import SnapshotTesting

final class SnapshotReferencePathResolverTests: XCTestCase {
  func testResolveSourceFilePath_withoutReferenceRoot_returnsCompileTimePath() {
    let compileTime = "/Users/builds/iRz0CLGrr/0/orderapp-newmobile/ios/Tests/Foo/Bar.swift"

    XCTAssertEqual(
      SnapshotReferencePathResolver.resolveSourceFilePath(compileTime),
      compileTime
    )
  }

  func testResolveSourceFilePath_withSnapshotReferenceDir_rewritesTestsSuffix() {
    let compileTime = "/Users/builds/iRz0CLGrr/0/orderapp-newmobile/ios/Tests/BurgerKingUITests/Foo.swift"
    let env = ["SNAPSHOT_REFERENCE_DIR": "/Users/builds/WKVgd1Ke_/0/orderapp-newmobile/ios"]
    let expected = "/Users/builds/WKVgd1Ke_/0/orderapp-newmobile/ios/Tests/BurgerKingUITests/Foo.swift"

    setenv("SNAPSHOT_REFERENCE_DIR", env["SNAPSHOT_REFERENCE_DIR"], 1)
    defer { unsetenv("SNAPSHOT_REFERENCE_DIR") }

    XCTAssertEqual(
      SnapshotReferencePathResolver.resolveSourceFilePath(compileTime),
      expected
    )
  }

  func testResolveSourceFilePath_prefersSnapshotReferenceDirOverCIProjectDir() {
    setenv("SNAPSHOT_REFERENCE_DIR", "/preferred/root", 1)
    setenv("CI_PROJECT_DIR", "/fallback/root", 1)
    defer {
      unsetenv("SNAPSHOT_REFERENCE_DIR")
      unsetenv("CI_PROJECT_DIR")
    }

    XCTAssertEqual(
      SnapshotReferencePathResolver.referenceRoot(from: ProcessInfo.processInfo.environment),
      "/preferred/root"
    )
  }

  func testResolveSourceFilePath_withNestedTestsSegment_rewritesFromFirstTestsAnchor() {
    let compileTime =
      "/Users/builds/aIPZTUFfM/0/orderapp-newmobile/ios/Tests/BurgerKingUITests/Tests/Scenario/AnalyticsEvents/AuthEventsUITests.swift"
    let expected =
      "/Users/builds/WKVgd1Ke_/0/orderapp-newmobile/ios/Tests/BurgerKingUITests/Tests/Scenario/AnalyticsEvents/AuthEventsUITests.swift"

    setenv("SNAPSHOT_REFERENCE_DIR", "/Users/builds/WKVgd1Ke_/0/orderapp-newmobile/ios", 1)
    defer { unsetenv("SNAPSHOT_REFERENCE_DIR") }

    XCTAssertEqual(
      SnapshotReferencePathResolver.resolveSourceFilePath(compileTime),
      expected
    )
  }

  func testResolveSourceFilePath_withoutTestsAnchor_returnsCompileTimePath() {
    let compileTime = "/Users/builds/iRz0CLGrr/0/orderapp-newmobile/ios/Modules/Foo/Bar.swift"

    setenv("CI_PROJECT_DIR", "/Users/builds/WKVgd1Ke_/0/orderapp-newmobile/ios", 1)
    defer { unsetenv("CI_PROJECT_DIR") }

    XCTAssertEqual(
      SnapshotReferencePathResolver.resolveSourceFilePath(compileTime),
      compileTime
    )
  }
}
