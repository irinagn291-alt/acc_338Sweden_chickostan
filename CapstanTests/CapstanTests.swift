import XCTest
@testable import Capstan

@MainActor
final class CapstanTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        self.calendar = calendar
    }

    func testDayTallyStaysNonNegativeAndLogsEveryTick() {
        let pushups = UUID()
        var chart = chart(on: date(2026, 10, 21))
        chart = GridReducer.addColumn(chart, name: "Pushups", id: pushups, at: date(2026, 10, 21), calendar: calendar).0
        XCTAssertEqual(chart.tally(columnID: pushups, daykey: chart.activeDaykey).value, 0)

        chart = pinTick(chart, pushups, at: date(2026, 10, 21, 9, 0))
        chart = pinTick(chart, pushups, at: date(2026, 10, 21, 9, 5))
        XCTAssertEqual(chart.ticks.count, 2)
        XCTAssertEqual(chart.tally(columnID: pushups, daykey: 20261021).value, 2)
        XCTAssertEqual(DayTallyMath.apply(value: 2, delta: 1), 3)
        XCTAssertEqual(DayTallyMath.apply(value: 0, delta: -4), 0)

        let peeled = GridReducer.peel(chart, at: date(2026, 10, 21, 9, 6), calendar: calendar)
        XCTAssertEqual(peeled.0.ticks.count, 1)
        XCTAssertEqual(peeled.0.tally(columnID: pushups, daykey: 20261021).value, 1)
        XCTAssertEqual(peeled.0.peels.count, 1)
    }

    func testPeriodElapseLogsTheNegativeOfTheOldTally() {
        let water = UUID()
        var chart = chart(on: date(2026, 10, 20))
        chart = GridReducer.addColumn(chart, name: "Water", id: water, at: date(2026, 10, 20), calendar: calendar).0
        chart = pinTick(chart, water, at: date(2026, 10, 20, 8, 0))
        chart = pinTick(chart, water, at: date(2026, 10, 20, 8, 2))
        let rolled = GridReducer.advance(chart, to: date(2026, 10, 21, 0, 5), calendar: calendar)
        XCTAssertEqual(rolled.1, .snapped)
        XCTAssertEqual(rolled.0.activeDaykey, 20261021)
        XCTAssertEqual(rolled.0.snaps.map(\.delta), [-2])
        XCTAssertEqual(rolled.0.tally(columnID: water, daykey: 20261020).value, 0)
        XCTAssertEqual(rolled.0.tally(columnID: water, daykey: 20261021).value, 0)
    }

    func testTickOnBareWritesHollowAndVacantGridStaysVacant() {
        let pages = UUID()
        var chart = chart(on: date(2026, 10, 21))
        let vacantTick = GridReducer.tick(chart, columnID: pages, at: date(2026, 10, 21, 10, 0), calendar: calendar)
        XCTAssertEqual(vacantTick.1, .vacant)
        XCTAssertEqual(vacantTick.0.phase, .vacant)
        XCTAssertTrue(vacantTick.0.hollows.isEmpty)
        XCTAssertTrue(vacantTick.0.ticks.isEmpty)

        chart = GridReducer.addColumn(chart, name: "Pages", id: pages, at: date(2026, 10, 21), calendar: calendar).0
        XCTAssertEqual(chart.phase, .bare)
        let hollow = GridReducer.tick(chart, columnID: pages, at: date(2026, 10, 21, 10, 1), calendar: calendar)
        XCTAssertEqual(hollow.1, .hollow)
        XCTAssertEqual(hollow.0.phase, .bare)
        XCTAssertEqual(hollow.0.hollows.count, 1)
        XCTAssertEqual(hollow.0.tally(columnID: pages, daykey: 20261021).value, 0)

        let blank = GridReducer.addColumn(chart, name: "   ", id: UUID(), at: date(2026, 10, 21), calendar: calendar)
        XCTAssertEqual(blank.1, .refused)
        let missing = GridReducer.tick(chart, columnID: UUID(), at: date(2026, 10, 21, 10, 2), calendar: calendar)
        XCTAssertEqual(missing.1, .refused)
        let nothingToPeel = GridReducer.peel(chart, at: date(2026, 10, 21, 10, 3), calendar: calendar)
        XCTAssertEqual(nothingToPeel.1, .refused)
    }

    func testPinThenTickFoldsBareToPinnedAndBack() {
        let pushups = UUID()
        let espresso = UUID()
        var chart = chart(on: date(2026, 10, 21))
        chart = GridReducer.addColumn(chart, name: "Pushups", id: pushups, at: date(2026, 10, 21), calendar: calendar).0
        chart = GridReducer.addColumn(chart, name: "Espresso", id: espresso, at: date(2026, 10, 21), calendar: calendar).0

        let pinned = GridReducer.pin(chart, columnID: pushups, at: date(2026, 10, 21, 7, 0), calendar: calendar)
        XCTAssertEqual(pinned.1, .pinned(pushups))
        XCTAssertEqual(pinned.0.phase, .pinned(pushups))
        XCTAssertEqual(pinned.0.pins.count, 1)
        XCTAssertEqual(pinned.0.reticle, ReticleLock(columnID: pushups))

        let moved = GridReducer.pin(pinned.0, columnID: espresso, at: date(2026, 10, 21, 7, 1), calendar: calendar)
        XCTAssertEqual(moved.1, .reassigned(espresso))
        XCTAssertEqual(moved.0.phase, .pinned(espresso))
        XCTAssertEqual(moved.0.ticks.count, 0)
        XCTAssertEqual(moved.0.tally(columnID: espresso, daykey: 20261021).value, 0)

        let stray = GridReducer.tick(moved.0, columnID: pushups, at: date(2026, 10, 21, 7, 2), calendar: calendar)
        XCTAssertEqual(stray.1, .stray(pushups))
        XCTAssertEqual(stray.0.phase, .pinned(espresso))
        XCTAssertEqual(stray.0.strays.count, 1)
        XCTAssertEqual(stray.0.tally(columnID: pushups, daykey: 20261021).value, 0)

        let ticked = GridReducer.tick(stray.0, columnID: espresso, at: date(2026, 10, 21, 7, 3), calendar: calendar)
        XCTAssertEqual(ticked.1, .ticked(espresso))
        XCTAssertEqual(ticked.0.phase, .bare)
        XCTAssertEqual(ticked.0.reticle, nil)
        XCTAssertEqual(ticked.0.tally(columnID: espresso, daykey: 20261021).value, 1)

        let peeledTick = GridReducer.peel(ticked.0, at: date(2026, 10, 21, 7, 4), calendar: calendar)
        XCTAssertEqual(peeledTick.1, .peeled)
        XCTAssertEqual(peeledTick.0.ticks.count, 0)
        XCTAssertEqual(peeledTick.0.tally(columnID: espresso, daykey: 20261021).value, 0)
        let peeledStray = GridReducer.peel(peeledTick.0, at: date(2026, 10, 21, 7, 5), calendar: calendar)
        XCTAssertEqual(peeledStray.1, .peeled)
        XCTAssertTrue(peeledStray.0.strays.isEmpty)
        XCTAssertEqual(peeledStray.0.phase, .bare)
    }

    func testBoardProjectsTheFoldWithoutReadingStorage() {
        let pages = UUID()
        var chart = chart(on: date(2026, 10, 21))
        let vacant = GridBoard.project(chart)
        XCTAssertNotNil(vacant.vacant)
        XCTAssertEqual(vacant.phase, .vacant)

        chart = GridReducer.addColumn(chart, name: "Pages", id: pages, at: date(2026, 10, 21), calendar: calendar).0
        chart = GridReducer.setBand(chart, columnID: pages, dailyLimit: 1).0
        chart = GridReducer.pin(chart, columnID: pages, at: date(2026, 10, 21, 11, 0), calendar: calendar).0
        chart = GridReducer.tick(chart, columnID: pages, at: date(2026, 10, 21, 11, 1), calendar: calendar).0
        let board = GridBoard.project(chart, notice: .ticked(pages))
        XCTAssertEqual(board.columns.count, 1)
        XCTAssertEqual(board.columns[0].tally, 1)
        XCTAssertTrue(board.columns[0].overBand)
        XCTAssertFalse(board.columns[0].pinned)
        XCTAssertEqual(board.phase, .bare)
        XCTAssertNil(board.vacant)
    }

    func testArchiveRoundTripSurvivesARelaunch() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("capstan-tests-\(UUID().uuidString)", isDirectory: true)
        let defaults = UserDefaults(suiteName: "capstan.tests.\(UUID().uuidString)")!
        let store = GridFileStore(directory: directory, defaults: defaults, archiveKey: GridFileStore.archiveKey)
        let first = GridArchive(store: store, calendar: calendar, seedEnabled: false, now: date(2026, 10, 21))
        await first.load(now: date(2026, 10, 21))
        let column = UUID()
        XCTAssertEqual(first.addColumn(name: "Espresso", id: column, at: date(2026, 10, 21)), .none)
        XCTAssertEqual(first.pin(columnID: column, at: date(2026, 10, 21, 8, 0)), .pinned(column))
        XCTAssertEqual(first.tick(columnID: column, at: date(2026, 10, 21, 8, 1)), .ticked(column))
        await first.flush()

        let second = GridArchive(store: store, calendar: calendar, seedEnabled: false, now: date(2026, 10, 21, 12, 0))
        await second.load(now: date(2026, 10, 21, 12, 0))
        XCTAssertEqual(second.chart.columns.map(\.name), ["Espresso"])
        XCTAssertEqual(second.chart.phase, .bare)
        XCTAssertEqual(second.chart.ticks.count, 1)
        XCTAssertEqual(second.chart.tally(columnID: column, daykey: 20261021).value, 1)
        XCTAssertNotNil(defaults.data(forKey: GridFileStore.archiveKey))

        await second.resetAllData(now: date(2026, 10, 21, 12, 1))
        let third = GridArchive(store: store, calendar: calendar, seedEnabled: false, now: date(2026, 10, 21, 12, 2))
        await third.load(now: date(2026, 10, 21, 12, 2))
        XCTAssertTrue(third.chart.columns.isEmpty)
        XCTAssertEqual(third.chart.phase, .vacant)
        XCTAssertNil(defaults.data(forKey: GridFileStore.archiveKey))
        try? FileManager.default.removeItem(at: directory)
    }

    func testCorruptArchiveFallsBackToTheBackup() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("capstan-backup-\(UUID().uuidString)", isDirectory: true)
        let defaults = UserDefaults(suiteName: "capstan.backup.\(UUID().uuidString)")!
        let store = GridFileStore(directory: directory, defaults: defaults, archiveKey: GridFileStore.archiveKey)
        var chart = chart(on: date(2026, 10, 21))
        let column = UUID()
        chart = GridReducer.addColumn(chart, name: "Water", id: column, at: date(2026, 10, 21), calendar: calendar).0
        let data = try GridDisk.encoded(chart)
        try await GridDisk.write(data: data, directory: directory, fileURL: store.fileURL, backupURL: store.backupURL)
        try await GridDisk.write(data: data, directory: directory, fileURL: store.fileURL, backupURL: store.backupURL)
        try Data("not-json".utf8).write(to: store.fileURL, options: .atomic)
        let archive = GridArchive(store: store, calendar: calendar, seedEnabled: false, now: date(2026, 10, 21))
        await archive.load(now: date(2026, 10, 21))
        let loaded = (chart: archive.chart, note: archive.recoveryNote)
        XCTAssertEqual(loaded.chart.columns.map(\.name), ["Water"])
        XCTAssertEqual(loaded.note?.isEmpty, false)
        try? FileManager.default.removeItem(at: directory)
    }

    func testReviewLaunchParsesTheScreenArgument() {
        XCTAssertEqual(ReviewLaunch.screen(in: ["Capstan", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Capstan", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Capstan", "-ReviewScreen", "goals"]), "goals")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Capstan", "-ReviewScreen", "settings"]), "settings")
        XCTAssertNil(ReviewLaunch.screen(in: ["Capstan"]))
        XCTAssertNil(ReviewLaunch.screen(in: ["Capstan", "-ReviewScreen"]))
    }

    func testSimulatorSeedLeavesTheFirstColumnPinned() {
        let seeded = DemoSeed.chart(now: date(2026, 10, 21, 15, 0), calendar: calendar)
        XCTAssertEqual(seeded.columns.map(\.name), ["Pushups", "Espresso", "Pages", "Water"])
        XCTAssertTrue(seeded.onboardingComplete)
        XCTAssertEqual(seeded.phase, .pinned(DemoSeed.pushups))
        XCTAssertGreaterThan(seeded.ticks.count, 4)
        let board = GridBoard.project(seeded)
        XCTAssertEqual(board.columns.first?.pinned, true)
        XCTAssertNil(board.vacant)
    }

    private func chart(on day: Date) -> GridChart {
        GridChart.empty(daykey: DayKey.stamp(day, calendar: calendar))
    }

    private func pinTick(_ chart: GridChart, _ column: UUID, at date: Date) -> GridChart {
        let pinned = GridReducer.pin(chart, columnID: column, at: date, calendar: calendar).0
        return GridReducer.tick(pinned, columnID: column, at: date.addingTimeInterval(1), calendar: calendar).0
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
        var parts = DateComponents()
        parts.calendar = calendar
        parts.timeZone = calendar.timeZone
        parts.year = year
        parts.month = month
        parts.day = day
        parts.hour = hour
        parts.minute = minute
        return calendar.date(from: parts)!
    }
}
