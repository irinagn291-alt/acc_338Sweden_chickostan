import Foundation

/// A named cap on the grid. Identity is a stable id, never a row index.
/// Day totals are not stored here; `DayTallySnapshot` folds them from marks.
struct ColumnRecord: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var name: String
    var created: Date

    init(id: UUID = UUID(), name: String, created: Date) {
        self.id = id
        self.name = name
        self.created = created
    }
}
