import Foundation

/// Maintains on-device cache of narration threads and segments within a 500 MB budget.
@MainActor
final class NarrationCacheManager {
    static let shared = NarrationCacheManager()

    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let budgetBytes: Int = 500 * 1_024 * 1_024
    private let metadataURL: URL

    private var metadata: [String: CacheEntry] = [:]

    private init() {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Narrations", isDirectory: true)
        metadataURL = cacheDirectory.appendingPathComponent("metadata.json")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        loadMetadata()
    }

    func store(data: Data, for key: String, scope: CacheScope) {
        let url = cacheDirectory.appendingPathComponent(key)
        do {
            try data.write(to: url, options: .atomic)
            metadata[key] = CacheEntry(scope: scope, sizeBytes: data.count, lastAccessed: Date())
            trimIfNeeded()
            persistMetadata()
        } catch {
            print("Cache write failed: \(error)")
        }
    }

    func data(for key: String) -> Data? {
        let url = cacheDirectory.appendingPathComponent(key)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        metadata[key]?.lastAccessed = Date()
        persistMetadata()
        return try? Data(contentsOf: url)
    }

    func clearAll() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        metadata.removeAll()
        persistMetadata()
    }

    private func trimIfNeeded() {
        var totalSize = metadata.values.reduce(0) { $0 + $1.sizeBytes }
        guard totalSize > budgetBytes else { return }

        let sortedKeys = metadata.keys.sorted { (lhs, rhs) -> Bool in
            let lhsDate = metadata[lhs]?.lastAccessed ?? .distantPast
            let rhsDate = metadata[rhs]?.lastAccessed ?? .distantPast
            return lhsDate < rhsDate
        }

        for key in sortedKeys {
            guard totalSize > budgetBytes else { break }
            removeItem(forKey: key)
            totalSize = metadata.values.reduce(0) { $0 + $1.sizeBytes }
        }
    }

    private func removeItem(forKey key: String) {
        let url = cacheDirectory.appendingPathComponent(key)
        try? fileManager.removeItem(at: url)
        metadata.removeValue(forKey: key)
    }

    private func loadMetadata() {
        guard let data = try? Data(contentsOf: metadataURL),
              let snapshot = try? JSONDecoder().decode([String: CacheEntry].self, from: data) else { return }
        metadata = snapshot
    }

    private func persistMetadata() {
        guard let data = try? JSONEncoder().encode(metadata) else { return }
        try? data.write(to: metadataURL, options: .atomic)
    }
}

enum CacheScope: String, Codable {
    case thread
    case segment
}

struct CacheEntry: Codable {
    let scope: CacheScope
    let sizeBytes: Int
    var lastAccessed: Date
}

