import Foundation

enum SnapshotReferencePathResolver {
  /// Rewrites compile-time `#filePath` when CI passes a checkout root different from the build machine.
  ///
  /// Example:
  /// - compile-time: `/Users/burger/builds/iRz0CLGrr/0/.../ios/Tests/Foo/Bar.swift`
  /// - `SNAPSHOT_REFERENCE_DIR`: `/Users/burger/builds/WKVgd1Ke_/0/.../ios`
  /// - result: `/Users/burger/builds/WKVgd1Ke_/0/.../ios/Tests/Foo/Bar.swift`
  static func resolveSourceFilePath(_ compileTimePath: String) -> String {
    guard let referenceRoot = referenceRoot(from: ProcessInfo.processInfo.environment) else {
      return compileTimePath
    }

    guard let testsRange = compileTimePath.range(of: "/Tests/") else {
      return compileTimePath
    }

    // First `/Tests/` anchor (repo checkout), not nested `…/BurgerKingUITests/Tests/`.
    let suffix = String(compileTimePath[testsRange.lowerBound...].dropFirst())
    return (referenceRoot as NSString).appendingPathComponent(suffix)
  }

  static func referenceRoot(from environment: [String: String]) -> String? {
    let candidates = [
      environment["SNAPSHOT_REFERENCE_DIR"],
      environment["CI_PROJECT_DIR"],
    ]

    for candidate in candidates {
      guard let root = candidate?.trimmingCharacters(in: .whitespacesAndNewlines), !root.isEmpty else {
        continue
      }
      return root
    }
    return nil
  }
}
