import Foundation

/// Undo of the latest TickMark or StrayMark for the active daykey.
/// The dropped mark leaves the ledger. This record is what remains.
struct PeelMarkEvent: Codable, Equatable, Sendable, Identifiable {
    enum Dropped: String, Codable, Sendable {
        case tick
        case stray
    }

    var id: UUID
    var daykey: Int
    var instant: Date
    var columnID: UUID
    var dropped: Dropped
    var droppedID: UUID

    init(
        id: UUID = UUID(),
        daykey: Int,
        instant: Date,
        columnID: UUID,
        dropped: Dropped,
        droppedID: UUID
    ) {
        self.id = id
        self.daykey = daykey
        self.instant = instant
        self.columnID = columnID
        self.dropped = dropped
        self.droppedID = droppedID
    }
}
