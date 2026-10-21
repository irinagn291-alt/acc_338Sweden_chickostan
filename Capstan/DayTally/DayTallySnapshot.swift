import Foundation

/// Family invariant: a column's value is max(0, value + delta). Totals are
/// folded from TickMarks after the latest period snap, never stored.
struct DayTallySnapshot: Equatable, Sendable {
    var columnID: UUID
    var daykey: Int
    var value: Int
}

/// Logged when a day elapses or the person resets today. `delta` is −old
/// so the log shows the snap. It is not added back into the tally.
struct PeriodSnap: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var columnID: UUID
    var daykey: Int
    var delta: Int
    var instant: Date

    init(id: UUID = UUID(), columnID: UUID, daykey: Int, delta: Int, instant: Date) {
        self.id = id
        self.columnID = columnID
        self.daykey = daykey
        self.delta = delta
        self.instant = instant
    }
}

enum DayTallyMath {
    static func apply(value: Int, delta: Int) -> Int {
        max(0, value + delta)
    }
}
