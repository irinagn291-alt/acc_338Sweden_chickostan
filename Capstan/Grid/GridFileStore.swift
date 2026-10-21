import Foundation

/// Paths and the UserDefaults key for one grid archive. File bytes move
/// through `GridDisk`, which never holds `UserDefaults`.
struct GridFileStore {
    static let archiveKey = "cps.grid.archive.v1"

    var directory: URL
    var defaults: UserDefaults
    var archiveKey: String

    var fileURL: URL { directory.appendingPathComponent("grid-chart.json") }
    var backupURL: URL { directory.appendingPathComponent("grid-chart.json.backup") }
}

struct GridLoad: Sendable {
    var chart: GridChart?
    var note: String?
}

/// Atomic file IO. Detached because Swift 6.2 would otherwise run the work
/// on the main actor that asked for the save.
enum GridDisk {
    static func read(_ url: URL) async -> ReadResult {
        await Task.detached(priority: .utility) {
            guard FileManager.default.fileExists(atPath: url.path) else { return .missing }
            let data: Data
            do {
                data = try Data(contentsOf: url)
            } catch {
                return .corrupt
            }
            guard let chart = chart(from: data) else { return .corrupt }
            return .value(chart)
        }.value
    }

    static func write(data: Data, directory: URL, fileURL: URL, backupURL: URL) async throws {
        try await Task.detached(priority: .utility) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if FileManager.default.fileExists(atPath: backupURL.path) {
                    try FileManager.default.removeItem(at: backupURL)
                }
                try FileManager.default.copyItem(at: fileURL, to: backupURL)
            }
            try data.write(to: fileURL, options: .atomic)
        }.value
    }

    static func erase(fileURL: URL, backupURL: URL) async throws {
        try await Task.detached(priority: .utility) {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try FileManager.default.removeItem(at: backupURL)
            }
        }.value
    }

    static func encoded(_ chart: GridChart) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(chart)
    }

    static func chart(from data: Data) -> GridChart? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(GridChart.self, from: data)
        } catch {
            return nil
        }
    }

    enum ReadResult: Sendable {
        case missing
        case corrupt
        case value(GridChart)
    }
}
