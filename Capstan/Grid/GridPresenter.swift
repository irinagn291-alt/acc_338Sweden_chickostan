import Foundation
import Observation

/// Presentation fold. Screens will bind `board`. They do not read the archive
/// file, UserDefaults, or the raw ledger.
@MainActor
@Observable
final class GridPresenter {
    private let archive: GridArchive
    private(set) var board: GridBoard

    /// Ledger for sheets. The file and UserDefaults stay behind the archive.
    var chart: GridChart { archive.chart }

    init(archive: GridArchive) {
        self.archive = archive
        self.board = GridBoard.project(archive.chart)
    }

    func load(now: Date = Date()) async {
        await archive.load(now: now)
        publish(.none)
    }

    func pin(columnID: UUID, at date: Date = Date()) {
        publish(archive.pin(columnID: columnID, at: date))
    }

    func tick(columnID: UUID, at date: Date = Date()) {
        publish(archive.tick(columnID: columnID, at: date))
    }

    func peel(at date: Date = Date()) {
        publish(archive.peel(at: date))
    }

    func addColumn(name: String, id: UUID = UUID(), at date: Date = Date()) {
        publish(archive.addColumn(name: name, id: id, at: date))
    }

    func rename(columnID: UUID, name: String) {
        publish(archive.rename(columnID: columnID, name: name))
    }

    func delete(columnID: UUID) {
        publish(archive.delete(columnID: columnID))
    }

    func setBand(columnID: UUID, dailyLimit: Int?) {
        publish(archive.setBand(columnID: columnID, dailyLimit: dailyLimit))
    }

    func resetToday(at date: Date = Date()) {
        publish(archive.resetToday(at: date))
    }

    func completeOnboarding() {
        archive.completeOnboarding()
        publish(.none)
    }

    func reopenOnboarding() {
        archive.reopenOnboarding()
        publish(.none)
    }

    func flush() async {
        await archive.flush()
    }

    /// Scene moved to inactive or background. The debounced save must hit disk.
    func flushForSceneExit() async {
        await archive.flush()
    }

    func resetAllData(now: Date = Date()) async {
        await archive.resetAllData(now: now)
        publish(.vacant)
    }

    private func publish(_ notice: GridNotice) {
        board = GridBoard.project(archive.chart, notice: notice, recoveryNote: archive.recoveryNote)
    }
}
