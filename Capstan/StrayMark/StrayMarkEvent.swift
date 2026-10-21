import Foundation

/// Tick landed on a column that is not the pinned cap. The phase stays
/// Pinned and no tally moves.
struct StrayMarkEvent: Codable, Equatable, Sendable, Identifiable {
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
