import Foundation

/// One column as the grid will draw it. Totals and the cap warning are folded
/// here so a view never walks the ledger.
struct ColumnFace: Equatable, Sendable, Identifiable {
    var id: UUID
    var name: String
    var tally: Int
    var dailyLimit: Int?
    var overBand: Bool
    var pinned: Bool
}

/// State between the chart and the grid. Home reads this, not the file.
struct GridBoard: Equatable, Sendable {
    var phase: GridPhase
    var columns: [ColumnFace]
    var reticle: ReticleLock?
    var vacant: VacantGrid?
    var daykey: Int
    var notice: GridNotice
    var onboardingComplete: Bool
    var recoveryNote: String?

    static func project(_ chart: GridChart, notice: GridNotice = .none, recoveryNote: String? = nil) -> GridBoard {
        if chart.columns.isEmpty {
            return GridBoard(
                phase: .vacant,
                columns: [],
                reticle: nil,
                vacant: VacantGrid(daykey: chart.activeDaykey),
                daykey: chart.activeDaykey,
                notice: notice == .none ? .vacant : notice,
                onboardingComplete: chart.onboardingComplete,
                recoveryNote: recoveryNote
            )
        }
        let pinnedID: UUID?
        if case .pinned(let id) = chart.phase {
            pinnedID = id
        } else {
            pinnedID = nil
        }
        let faces = chart.columns.map { column in
            let value = chart.tally(columnID: column.id, daykey: chart.activeDaykey).value
            let limit = chart.band(for: column.id)?.dailyLimit
            let over = limit.map { value >= $0 } ?? false
            return ColumnFace(
                id: column.id,
                name: column.name,
                tally: value,
                dailyLimit: limit,
                overBand: over,
                pinned: pinnedID == column.id
            )
        }
        return GridBoard(
            phase: chart.phase,
            columns: faces,
            reticle: chart.reticle,
            vacant: nil,
            daykey: chart.activeDaykey,
            notice: notice,
            onboardingComplete: chart.onboardingComplete,
            recoveryNote: recoveryNote
        )
    }
}
