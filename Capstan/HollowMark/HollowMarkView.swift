import SwiftUI

/// Ticks refused because nothing was pinned.
struct HollowMarkView: View {
    @Bindable var presenter: GridPresenter

    private var lines: [MarkFeed.Line] { MarkFeed.hollows(presenter.chart) }

    var body: some View {
        MarkList(
            title: "Refused",
            lines: lines,
            marker: CapstanColor.ink,
            emptyTitle: "No refused ticks.",
            emptyLine: "Tick before you pin, and the refusal is kept here without changing a count.",
            imageName: "cps_EmptyHome",
            onRetry: { Task { await presenter.load() } },
            panelTitle: "Refused by habit",
            metrics: MarkList.totals(lines),
            actionTitle: lines.first.map { "Pin \($0.habit)" },
            actionLine: "A tick before a pin is refused. Pin the habit, then tick it on Today.",
            onAction: pinLatest
        )
    }

    private func pinLatest() {
        guard let id = lines.first?.columnID else { return }
        presenter.pin(columnID: id)
    }
}
