import Foundation

/// The seam between the fold and storage. Views talk to `GridPresenter`,
/// which talks to this type. Nothing in the UI touches the file or UserDefaults.
@MainActor
final class GridArchive {
    private(set) var chart: GridChart
    private(set) var recoveryNote: String?
    private let store: GridFileStore
    private let calendar: Calendar
    private let seedEnabled: Bool
    private let debounceNanoseconds: UInt64
    private var saveTask: Task<Void, Never>?

    init(
        store: GridFileStore,
        calendar: Calendar = .current,
        seedEnabled: Bool = true,
        debounceNanoseconds: UInt64 = 350_000_000,
        now: Date = Date()
    ) {
        self.store = store
        self.calendar = calendar
        self.seedEnabled = seedEnabled
        self.debounceNanoseconds = debounceNanoseconds
        self.chart = GridChart.empty(daykey: DayKey.stamp(now, calendar: calendar))
    }

    func load(now: Date = Date()) async {
        let loaded = await readChart()
        if let chart = loaded.chart {
            self.chart = chart
            recoveryNote = loaded.note
        } else {
            chart = GridChart.empty(daykey: DayKey.stamp(now, calendar: calendar))
            recoveryNote = loaded.note
            await installSeedIfNeeded(now: now)
        }
        let rolled = GridReducer.advance(chart, to: now, calendar: calendar)
        if rolled.1 == .snapped {
            chart = rolled.0
            await flush()
        } else {
            chart = rolled.0
        }
    }

    func pin(columnID: UUID, at date: Date = Date()) -> GridNotice {
        commit(GridReducer.pin(chart, columnID: columnID, at: date, calendar: calendar))
    }

    func tick(columnID: UUID, at date: Date = Date()) -> GridNotice {
        commit(GridReducer.tick(chart, columnID: columnID, at: date, calendar: calendar))
    }

    func peel(at date: Date = Date()) -> GridNotice {
        commit(GridReducer.peel(chart, at: date, calendar: calendar))
    }

    func addColumn(name: String, id: UUID = UUID(), at date: Date = Date()) -> GridNotice {
        commit(GridReducer.addColumn(chart, name: name, id: id, at: date, calendar: calendar))
    }

    func rename(columnID: UUID, name: String) -> GridNotice {
        commit(GridReducer.rename(chart, columnID: columnID, name: name))
    }

    func delete(columnID: UUID) -> GridNotice {
        commit(GridReducer.delete(chart, columnID: columnID))
    }

    func setBand(columnID: UUID, dailyLimit: Int?) -> GridNotice {
        commit(GridReducer.setBand(chart, columnID: columnID, dailyLimit: dailyLimit))
    }

    func resetToday(at date: Date = Date()) -> GridNotice {
        commit(GridReducer.resetToday(chart, at: date, calendar: calendar))
    }

    func completeOnboarding() {
        chart = GridReducer.completeOnboarding(chart)
        scheduleSave()
    }

    func reopenOnboarding() {
        chart.onboardingComplete = false
        scheduleSave()
    }

    func flush() async {
        saveTask?.cancel()
        saveTask = nil
        await persist(chart)
    }

    func resetAllData(now: Date = Date()) async {
        saveTask?.cancel()
        saveTask = nil
        chart = GridChart.empty(daykey: DayKey.stamp(now, calendar: calendar))
        recoveryNote = nil
        let fileURL = store.fileURL
        let backupURL = store.backupURL
        let defaults = store.defaults
        let archiveKey = store.archiveKey
        do {
            try await GridDisk.erase(fileURL: fileURL, backupURL: backupURL)
            defaults.removeObject(forKey: archiveKey)
        } catch {
            recoveryNote = "The old grid could not be removed. Try the reset again."
        }
    }

    private func commit(_ result: (GridChart, GridNotice)) -> GridNotice {
        chart = result.0
        scheduleSave()
        return result.1
    }

    private func scheduleSave() {
        saveTask?.cancel()
        let snapshot = chart
        let wait = debounceNanoseconds
        saveTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: wait)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            await self?.persist(snapshot)
        }
    }

    private func persist(_ snapshot: GridChart) async {
        let directory = store.directory
        let fileURL = store.fileURL
        let backupURL = store.backupURL
        let defaults = store.defaults
        let archiveKey = store.archiveKey
        do {
            let data = try GridDisk.encoded(snapshot)
            try await GridDisk.write(data: data, directory: directory, fileURL: fileURL, backupURL: backupURL)
            defaults.set(data, forKey: archiveKey)
        } catch {
            recoveryNote = "The grid could not be saved. The marks stay on screen until the next save."
        }
    }

    private func readChart() async -> GridLoad {
        let fileURL = store.fileURL
        let backupURL = store.backupURL
        let mirrored = store.defaults.data(forKey: store.archiveKey)
        let primary = await GridDisk.read(fileURL)
        switch primary {
        case .value(let chart):
            return GridLoad(chart: chart, note: nil)
        case .missing:
            if let mirrored, let chart = GridDisk.chart(from: mirrored) {
                return GridLoad(chart: chart, note: nil)
            }
            return GridLoad(chart: nil, note: nil)
        case .corrupt:
            let backup = await GridDisk.read(backupURL)
            if case .value(let chart) = backup {
                return GridLoad(
                    chart: chart,
                    note: "The saved grid was unreadable. Chickostan restored the previous copy."
                )
            }
            return GridLoad(
                chart: nil,
                note: "The saved grid was unreadable. Chickostan started from an empty grid."
            )
        }
    }

    private func installSeedIfNeeded(now: Date) async {
        #if targetEnvironment(simulator)
        guard seedEnabled else { return }
        guard store.defaults.bool(forKey: DemoSeed.defaultsKey) == false else { return }
        chart = DemoSeed.chart(now: now, calendar: calendar)
        store.defaults.set(true, forKey: DemoSeed.defaultsKey)
        await persist(chart)
        #else
        _ = now
        #endif
    }
}
