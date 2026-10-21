import Foundation

/// One successful count on the pinned column. The fold returns to Bare.
/// The +1 lives only as this mark; the day total is counted from the ledger.
struct TickMarkEvent: Codable, Equatable, Sendable, Identifiable {
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
