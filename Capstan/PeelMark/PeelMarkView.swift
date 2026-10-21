import SwiftUI

/// Peels that removed a tick or a miss.
struct PeelMarkView: View {
    @Bindable var presenter: GridPresenter

    private var lines: [MarkFeed.Line] { MarkFeed.peels(presenter.chart) }

    private var latest: PeelMarkEvent? {
        presenter.chart.peels.max { $0.instant < $1.instant }
    }

    var body: some View {
        MarkList(
            title: "Removed",
            lines: lines,
            marker: CapstanColor.muted,
            emptyTitle: "Nothing has been peeled.",
            emptyLine: "Peel on Today removes the latest tick or miss for this date.",
            imageName: "cps_Onboarding3",
            onRetry: { Task { await presenter.load() } },
            panelTitle: "What was removed",
            metrics: [
                MarkMetric(label: "Removed ticks", value: presenter.chart.peels.filter { $0.dropped == .tick }.count),
                MarkMetric(label: "Removed misses", value: presenter.chart.peels.filter { $0.dropped == .stray }.count)
            ],
            actionTitle: actionTitle,
            actionLine: actionLine,
            onAction: restore
        )
    }

    private var actionTitle: String? {
        guard let latest, let name = lines.first(where: { $0.columnID == latest.columnID })?.habit else { return nil }
        if latest.dropped == .tick, case .pinned(let id) = presenter.chart.phase, id == latest.columnID {
            return "Add \(name) back"
        }
        return "Pin \(name)"
    }

    private var actionLine: String {
        guard let latest else { return "" }
        if latest.dropped == .tick, case .pinned(let id) = presenter.chart.phase, id == latest.columnID {
            return "The latest removal dropped a tick. Add it back onto today's count."
        }
        if latest.dropped == .tick {
            return "The latest removal dropped a tick. Pin the habit, then add it back from Today."
        }
        return "The latest removal dropped a miss. Pin the habit before the next tick."
    }

    private func restore() {
        guard let latest else { return }
        if latest.dropped == .tick, case .pinned(let id) = presenter.chart.phase, id == latest.columnID {
            presenter.tick(columnID: latest.columnID)
        } else {
            presenter.pin(columnID: latest.columnID)
        }
    }
}
