import Foundation

enum SnapshotReferenceCache {
  private struct Entry {
    let modificationDate: Date?
    let data: Data
  }

  private static let lock = NSLock()
  private static var cache: [URL: Entry] = [:]

  static func data(for url: URL, fileManager: FileManager = .default) throws -> Data {
    let attributes = try fileManager.attributesOfItem(atPath: url.path)
    let modificationDate = attributes[.modificationDate] as? Date

    lock.lock()
    if let cached = cache[url], cached.modificationDate == modificationDate {
      let data = cached.data
      lock.unlock()
      return data
    }
    lock.unlock()

    let data = try Data(contentsOf: url, options: .mappedIfSafe)

    lock.lock()
    cache[url] = Entry(modificationDate: modificationDate, data: data)
    lock.unlock()

    return data
  }

  static func invalidate(for url: URL) {
    lock.lock()
    defer { lock.unlock() }
    cache.removeValue(forKey: url)
  }
}

enum SnapshotDirectoryCache {
  private static let lock = NSLock()
  private static var createdDirectories = Set<URL>()

  static func createDirectoryIfNeeded(
    at url: URL,
    fileManager: FileManager = .default
  ) throws {
    lock.lock()
    if createdDirectories.contains(url) {
      lock.unlock()
      return
    }
    lock.unlock()

    try fileManager.createDirectory(at: url, withIntermediateDirectories: true)

    lock.lock()
    createdDirectories.insert(url)
    lock.unlock()
  }
}
