import SwiftUI

/// Ticks that landed. Each row is one added count.
struct TickMarkView: View {
    @Bindable var presenter: GridPresenter

    var body: some View {
        MarkList(
            title: "Ticks",
            lines: MarkFeed.ticks(presenter.chart),
            marker: CapstanColor.accent,
            emptyTitle: "No ticks yet.",
            emptyLine: "Pin a habit on Today, then tick. Each add shows up here.",
            imageName: "cps_TwistHero",
            onRetry: { Task { await presenter.load() } }
        )
    }
}
