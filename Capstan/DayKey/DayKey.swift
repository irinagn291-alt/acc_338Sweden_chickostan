import Foundation

/// Integer YYYYMMDD stamp. Period edges use `Calendar.startOfDay` so a tally
/// belongs to one civil day and rolls only when that day actually advances.
enum DayKey {
    static func stamp(_ date: Date, calendar: Calendar = .current) -> Int {
        let parts = calendar.dateComponents([.year, .month, .day], from: calendar.startOfDay(for: date))
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }

    static func date(from stamp: Int, calendar: Calendar = .current) -> Date? {
        var parts = DateComponents()
        parts.year = stamp / 10_000
        parts.month = (stamp / 100) % 100
        parts.day = stamp % 100
        guard let day = calendar.date(from: parts) else { return nil }
        return calendar.startOfDay(for: day)
    }
}
