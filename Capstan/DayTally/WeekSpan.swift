import Foundation

/// Seven civil days ending on the active daykey. Totals come from the ledger.
struct WeekSpan {
    struct Point: Identifiable, Equatable, Sendable {
        var daykey: Int
        var value: Int
        var id: Int { daykey }
    }

    static func points(chart: GridChart, columnID: UUID, calendar: Calendar = .current) -> [Point] {
        let end = DayKey.date(from: chart.activeDaykey, calendar: calendar) ?? calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: end)
        return (0..<7).compactMap { offset in
            let shift = offset - 6
            guard let day = calendar.date(byAdding: .day, value: shift, to: start) else { return nil }
            let key = DayKey.stamp(day, calendar: calendar)
            return Point(daykey: key, value: chart.tally(columnID: columnID, daykey: key).value)
        }
    }
}

/// Rows a sheet can show without walking storage itself.
struct MarkFeed {
    struct Line: Identifiable, Equatable, Sendable {
        var id: UUID
        var habit: String
        var detail: String
        var instant: Date
        var daykey: Int
        var columnID: UUID?
    }

    static func habit(_ chart: GridChart, _ id: UUID?) -> String {
        guard let id, let name = chart.columns.first(where: { $0.id == id })?.name else {
            return "Unknown"
        }
        return name
    }

    static func ticks(_ chart: GridChart) -> [Line] {
        chart.ticks.map { mark in
            Line(
                id: mark.id,
                habit: habit(chart, mark.columnID),
                detail: "Added one",
                instant: mark.instant,
                daykey: mark.daykey,
                columnID: mark.columnID
            )
        }
        .sorted { $0.instant > $1.instant }
    }

    static func strays(_ chart: GridChart) -> [Line] {
        chart.strays.map { mark in
            Line(
                id: mark.id,
                habit: habit(chart, mark.columnID),
                detail: "Missed the pin",
                instant: mark.instant,
                daykey: mark.daykey,
                columnID: mark.columnID
            )
        }
        .sorted { $0.instant > $1.instant }
    }

    static func hollows(_ chart: GridChart) -> [Line] {
        chart.hollows.map { mark in
            Line(
                id: mark.id,
                habit: habit(chart, mark.columnID),
                detail: "Refused before a pin",
                instant: mark.instant,
                daykey: mark.daykey,
                columnID: mark.columnID
            )
        }
        .sorted { $0.instant > $1.instant }
    }

    static func peels(_ chart: GridChart) -> [Line] {
        chart.peels.map { mark in
            let detail = mark.dropped == .tick ? "Removed a tick" : "Removed a miss"
            return Line(
                id: mark.id,
                habit: habit(chart, mark.columnID),
                detail: detail,
                instant: mark.instant,
                daykey: mark.daykey,
                columnID: mark.columnID
            )
        }
        .sorted { $0.instant > $1.instant }
    }

    static func snaps(_ chart: GridChart) -> [Line] {
        chart.snaps.map { mark in
            Line(
                id: mark.id,
                habit: habit(chart, mark.columnID),
                detail: "Day closed",
                instant: mark.instant,
                daykey: mark.daykey,
                columnID: mark.columnID
            )
        }
        .sorted { $0.instant > $1.instant }
    }
}
