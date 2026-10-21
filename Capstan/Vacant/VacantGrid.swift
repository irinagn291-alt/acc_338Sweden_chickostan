import Foundation

/// Empty column list. Pin and Tick do not invent a cap. The grid evaluates
/// to Vacant until a column exists.
struct VacantGrid: Equatable, Sendable {
    var daykey: Int
}
