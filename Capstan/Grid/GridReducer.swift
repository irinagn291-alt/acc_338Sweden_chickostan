import Foundation

/// What the fold accepted. The presenter turns this into the line under the tally.
enum GridNotice: Equatable, Sendable {
    case none
    case pinned(UUID)
    case reassigned(UUID)
    case ticked(UUID)
    case stray(UUID)
    case hollow
    case peeled
    case vacant
    case refused
    case snapped
}

/// Pure Capstan fold. Pin writes a PinMark and folds Bare to Pinned.
/// Tick on the pinned column writes a TickMark, adds one, and folds to Bare.
/// Tick on another column writes a StrayMark and keeps Pinned.
/// Tick on Bare writes a HollowMark. Peel drops the last TickMark or StrayMark.
/// An empty column list writes Vacant.
enum GridReducer {
    static func pin(_ chart: GridChart, columnID: UUID, at date: Date, calendar: Calendar = .current) -> (GridChart, GridNotice) {
        var chart = advance(chart, to: date, calendar: calendar).0
        guard chart.columns.contains(where: { $0.id == columnID }) else {
            return (chart, chart.phase == .vacant ? .vacant : .refused)
        }
        let daykey = DayKey.stamp(date, calendar: calendar)
        chart.pins.append(PinMarkEvent(columnID: columnID, daykey: daykey, instant: date))
        let notice: GridNotice
        switch chart.phase {
        case .pinned:
            notice = .reassigned(columnID)
        case .bare, .vacant:
            notice = .pinned(columnID)
        }
        chart.phase = .pinned(columnID)
        return (chart, notice)
    }

    static func tick(_ chart: GridChart, columnID: UUID, at date: Date, calendar: Calendar = .current) -> (GridChart, GridNotice) {
        var chart = advance(chart, to: date, calendar: calendar).0
        let daykey = DayKey.stamp(date, calendar: calendar)
        if chart.columns.isEmpty {
            chart.phase = .vacant
            return (chart, .vacant)
        }
        guard chart.columns.contains(where: { $0.id == columnID }) else {
            return (chart, .refused)
        }
        switch chart.phase {
        case .vacant:
            chart.phase = .bare
            chart.hollows.append(HollowMarkEvent(daykey: daykey, instant: date, columnID: columnID))
            return (chart, .hollow)
        case .bare:
            chart.hollows.append(HollowMarkEvent(daykey: daykey, instant: date, columnID: columnID))
            return (chart, .hollow)
        case .pinned(let armed):
            if armed == columnID {
                chart.ticks.append(TickMarkEvent(columnID: columnID, daykey: daykey, instant: date))
                chart.phase = .bare
                return (chart, .ticked(columnID))
            }
            chart.strays.append(StrayMarkEvent(columnID: columnID, daykey: daykey, instant: date))
            return (chart, .stray(columnID))
        }
    }

    static func peel(_ chart: GridChart, at date: Date, calendar: Calendar = .current) -> (GridChart, GridNotice) {
        var chart = advance(chart, to: date, calendar: calendar).0
        let daykey = chart.activeDaykey
        guard let target = latestReversible(chart, daykey: daykey) else {
            return (chart, .refused)
        }
        switch target {
        case .tick(let mark):
            chart.ticks.removeAll { $0.id == mark.id }
            chart.peels.append(
                PeelMarkEvent(
                    daykey: daykey,
                    instant: date,
                    columnID: mark.columnID,
                    dropped: .tick,
                    droppedID: mark.id
                )
            )
        case .stray(let mark):
            chart.strays.removeAll { $0.id == mark.id }
            chart.peels.append(
                PeelMarkEvent(
                    daykey: daykey,
                    instant: date,
                    columnID: mark.columnID,
                    dropped: .stray,
                    droppedID: mark.id
                )
            )
        }
        return (chart, .peeled)
    }

    static func advance(_ chart: GridChart, to date: Date, calendar: Calendar = .current) -> (GridChart, GridNotice) {
        var chart = chart
        let daykey = DayKey.stamp(date, calendar: calendar)
        guard daykey > chart.activeDaykey else {
            return (chart, .none)
        }
        let previous = chart.activeDaykey
        for column in chart.columns {
            let old = chart.tally(columnID: column.id, daykey: previous).value
            guard old > 0 else { continue }
            let logged = DayTallyMath.apply(value: old, delta: -old) - old
            chart.snaps.append(
                PeriodSnap(columnID: column.id, daykey: previous, delta: logged, instant: date)
            )
        }
        chart.activeDaykey = daykey
        return (chart, .snapped)
    }

    static func resetToday(_ chart: GridChart, at date: Date, calendar: Calendar = .current) -> (GridChart, GridNotice) {
        var chart = advance(chart, to: date, calendar: calendar).0
        let daykey = chart.activeDaykey
        var wrote = false
        for column in chart.columns {
            let old = chart.tally(columnID: column.id, daykey: daykey).value
            guard old > 0 else { continue }
            let logged = DayTallyMath.apply(value: old, delta: -old) - old
            chart.snaps.append(
                PeriodSnap(columnID: column.id, daykey: daykey, delta: logged, instant: date)
            )
            wrote = true
        }
        return (chart, wrote ? .snapped : .none)
    }

    static func addColumn(_ chart: GridChart, name: String, id: UUID, at date: Date, calendar: Calendar = .current) -> (GridChart, GridNotice) {
        var chart = advance(chart, to: date, calendar: calendar).0
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return (chart, .refused) }
        guard !chart.columns.contains(where: { $0.id == id }) else { return (chart, .refused) }
        let wasVacant = chart.columns.isEmpty
        chart.columns.append(ColumnRecord(id: id, name: trimmed, created: date))
        if wasVacant {
            chart.phase = .bare
        }
        return (chart, .none)
    }

    static func rename(_ chart: GridChart, columnID: UUID, name: String) -> (GridChart, GridNotice) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return (chart, .refused) }
        guard let index = chart.columns.firstIndex(where: { $0.id == columnID }) else {
            return (chart, .refused)
        }
        var chart = chart
        chart.columns[index].name = trimmed
        return (chart, .none)
    }

    static func delete(_ chart: GridChart, columnID: UUID) -> (GridChart, GridNotice) {
        guard chart.columns.contains(where: { $0.id == columnID }) else {
            return (chart, .refused)
        }
        var chart = chart
        chart.columns.removeAll { $0.id == columnID }
        chart.bands.removeAll { $0.columnID == columnID }
        if chart.columns.isEmpty {
            chart.phase = .vacant
            return (chart, .vacant)
        }
        if case .pinned(let armed) = chart.phase, armed == columnID {
            chart.phase = .bare
        }
        return (chart, .none)
    }

    static func setBand(_ chart: GridChart, columnID: UUID, dailyLimit: Int?) -> (GridChart, GridNotice) {
        guard chart.columns.contains(where: { $0.id == columnID }) else {
            return (chart, .refused)
        }
        var chart = chart
        chart.bands.removeAll { $0.columnID == columnID }
        if let dailyLimit {
            chart.bands.append(CapBandThreshold(columnID: columnID, dailyLimit: dailyLimit))
        }
        return (chart, .none)
    }

    static func completeOnboarding(_ chart: GridChart) -> GridChart {
        var chart = chart
        chart.onboardingComplete = true
        return chart
    }

    private enum Reversible {
        case tick(TickMarkEvent)
        case stray(StrayMarkEvent)
    }

    private static func latestReversible(_ chart: GridChart, daykey: Int) -> Reversible? {
        struct Candidate {
            var instant: Date
            var mark: Reversible
        }
        var candidates: [Candidate] = []
        for tick in chart.ticks where tick.daykey == daykey {
            let floor = chart.snaps
                .filter { $0.columnID == tick.columnID && $0.daykey == daykey }
                .map(\.instant)
                .max()
            if let floor, tick.instant <= floor { continue }
            candidates.append(Candidate(instant: tick.instant, mark: .tick(tick)))
        }
        for stray in chart.strays where stray.daykey == daykey {
            candidates.append(Candidate(instant: stray.instant, mark: .stray(stray)))
        }
        guard let latest = candidates.max(by: { $0.instant < $1.instant }) else { return nil }
        return latest.mark
    }
}
