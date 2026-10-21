import SwiftUI

/// Ticks that missed the pin and did not add.
struct StrayMarkView: View {
    @Bindable var presenter: GridPresenter

    private var lines: [MarkFeed.Line] { MarkFeed.strays(presenter.chart) }

    var body: some View {
        MarkList(
            title: "Misses",
            lines: lines,
            marker: CapstanColor.muted,
            emptyTitle: "No misses today.",
            emptyLine: "A tick on a habit that is not pinned is stored here and does not add.",
            imageName: "cps_EmptyGridCutout",
            onRetry: { Task { await presenter.load() } },
            panelTitle: "Misses by habit",
            metrics: MarkList.totals(lines),
            actionTitle: lines.first.map { "Pin \($0.habit)" },
            actionLine: "This tick missed the pin and did not add. Pin that habit, then tick it on Today.",
            onAction: pinLatest
        )
    }

    private func pinLatest() {
        guard let id = lines.first?.columnID else { return }
        presenter.pin(columnID: id)
    }
}
