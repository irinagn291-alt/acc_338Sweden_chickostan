import Foundation

/// Optional daily warning threshold for one column. Crossing it is a soft
/// signal. The tally itself stays a fold over marks, not a stored remainder.
struct CapBandThreshold: Codable, Equatable, Sendable, Identifiable {
    var columnID: UUID
    var dailyLimit: Int

    var id: UUID { columnID }

    init(columnID: UUID, dailyLimit: Int) {
        self.columnID = columnID
        self.dailyLimit = max(0, dailyLimit)
    }
}
