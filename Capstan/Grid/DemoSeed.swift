import Foundation

/// Simulator seed. Four lived-in columns and a PinMark on the first cap so
/// Tick is live before the first frame. Devices never call this.
enum DemoSeed {
    static let defaultsKey = "cps.demo.v1"

    static let pushups = demoID("A1000001-0000-4000-8000-000000000001")
    static let espresso = demoID("A1000001-0000-4000-8000-000000000002")
    static let pages = demoID("A1000001-0000-4000-8000-000000000003")
    static let water = demoID("A1000001-0000-4000-8000-000000000004")

    /// Programmer error if a literal is malformed. These ids are not loaded from disk.
    private static func demoID(_ raw: String) -> UUID {
        guard let id = UUID(uuidString: raw) else {
            fatalError("Demo column id is not a UUID: \(raw)")
        }
        return id
    }

    static func chart(now: Date, calendar: Calendar = .current) -> GridChart {
        let today = calendar.startOfDay(for: now)
        let daykey = DayKey.stamp(today, calendar: calendar)
        let names: [(UUID, String, Int)] = [
            (pushups, "Pushups", 40),
            (espresso, "Espresso", 4),
            (pages, "Pages", 30),
            (water, "Water", 8)
        ]
        var chart = GridChart(activeDaykey: daykey, onboardingComplete: true)
        for (id, name, limit) in names {
            let added = GridReducer.addColumn(chart, name: name, id: id, at: today, calendar: calendar)
            chart = added.0
            chart = GridReducer.setBand(chart, columnID: id, dailyLimit: limit).0
        }
        for offset in [2, 1] {
            guard let past = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            for (index, item) in names.enumerated() {
                let count = offset + index
                for step in 0..<count {
                    let instant = past.addingTimeInterval(TimeInterval(step + 1) * 60)
                    chart = GridReducer.pin(chart, columnID: item.0, at: instant, calendar: calendar).0
                    let ticked = past.addingTimeInterval(TimeInterval(step + 1) * 60 + 5)
                    chart = GridReducer.tick(chart, columnID: item.0, at: ticked, calendar: calendar).0
                }
            }
        }
        // Open today already pinned on Pushups. A couple of finished counts
        // sit on the ledger, then the reticle locks again so Tick is armed.
        let morning = today.addingTimeInterval(8 * 3600)
        chart = GridReducer.pin(chart, columnID: pushups, at: morning, calendar: calendar).0
        chart = GridReducer.tick(chart, columnID: pushups, at: morning.addingTimeInterval(5), calendar: calendar).0
        chart = GridReducer.pin(chart, columnID: espresso, at: morning.addingTimeInterval(3600), calendar: calendar).0
        chart = GridReducer.tick(chart, columnID: espresso, at: morning.addingTimeInterval(3605), calendar: calendar).0
        let noon = today.addingTimeInterval(12 * 3600)
        chart = GridReducer.tick(chart, columnID: pages, at: noon, calendar: calendar).0
        chart = GridReducer.pin(chart, columnID: pages, at: noon.addingTimeInterval(20), calendar: calendar).0
        chart = GridReducer.tick(chart, columnID: water, at: noon.addingTimeInterval(40), calendar: calendar).0
        chart = GridReducer.tick(chart, columnID: espresso, at: noon.addingTimeInterval(50), calendar: calendar).0
        chart = GridReducer.peel(chart, at: noon.addingTimeInterval(60), calendar: calendar).0
        chart = GridReducer.pin(chart, columnID: pushups, at: morning.addingTimeInterval(7200), calendar: calendar).0
        chart.onboardingComplete = true
        return chart
    }
}
