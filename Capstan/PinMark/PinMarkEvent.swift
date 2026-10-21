import Foundation

/// Pin arms one column and folds Bare into Pinned, or reassigns the lock
/// when the grid is already Pinned. A pin never changes a tally.
struct PinMarkEvent: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var columnID: UUID
    var daykey: Int
    var instant: Date

    init(id: UUID = UUID(), columnID: UUID, daykey: Int, instant: Date) {
        self.id = id
        self.columnID = columnID
        self.daykey = daykey
        self.instant = instant
    }
}
