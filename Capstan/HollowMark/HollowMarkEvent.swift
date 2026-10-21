import Foundation

/// Tick while Bare. The reducer refuses the count and writes this mark
/// so the miss is in the log with zero tally change.
struct HollowMarkEvent: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var daykey: Int
    var instant: Date
    /// Column the tap named, when the grid still has columns.
    var columnID: UUID?

    init(id: UUID = UUID(), daykey: Int, instant: Date, columnID: UUID?) {
        self.id = id
        self.daykey = daykey
        self.instant = instant
        self.columnID = columnID
    }
}
