import Charts
import SwiftUI

/// Seven-day counts and the mark ledger. One chart leads. The rest stay short.
struct StatsSheetView: View {
    @Bindable var presenter: GridPresenter
    var onClose: () -> Void
    @ScaledMetric(relativeTo: .body) private var heroHeight: CGFloat = 200
    @ScaledMetric(relativeTo: .caption) private var rowHeight: CGFloat = 88

    var body: some View {
        CapstanScreen(title: "Log", onClose: onClose) {
            Group {
                if presenter.board.columns.isEmpty {
                    EmptyBoard(
                        imageName: "cps_EmptyHome",
                        title: "Nothing to chart yet.",
                        line: "Add a habit, pin it, and tick. The week shows up here.",
                        action: "Close",
                        onAction: onClose
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: CapstanSpace.l) {
                            if let note = presenter.board.recoveryNote, !note.isEmpty {
                                notice(note)
                            }
                            if let lead = presenter.board.columns.first {
                                chart(for: lead, height: heroHeight, prominent: true)
                            }
                            ForEach(presenter.board.columns.dropFirst()) { face in
                                chart(for: face, height: rowHeight, prominent: false)
                            }
                            section("Ticks", MarkFeed.ticks(presenter.chart), CapstanColor.accent)
                            section("Misses", MarkFeed.strays(presenter.chart), CapstanColor.muted)
                            section("Refused", MarkFeed.hollows(presenter.chart), CapstanColor.ink)
                            section("Removed", MarkFeed.peels(presenter.chart), CapstanColor.muted)
                            section("Closed days", MarkFeed.snaps(presenter.chart), CapstanColor.ink)
                        }
                        .padding(CapstanSpace.m)
                    }
                }
            }
        }
    }

    private func chart(for face: ColumnFace, height: CGFloat, prominent: Bool) -> some View {
        let points = WeekSpan.points(chart: presenter.chart, columnID: face.id)
        return VStack(alignment: .leading, spacing: CapstanSpace.s) {
            HStack(alignment: .firstTextBaseline) {
                Text(face.name)
                    .font(CapstanType.font(prominent ? .title : .headline))
                    .foregroundStyle(CapstanColor.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: CapstanSpace.s)
                Text(CapstanFormat.count(face.tally))
                    .font(CapstanType.font(prominent ? .title : .headline, tabular: true))
                    .foregroundStyle(prominent ? CapstanColor.accent : CapstanColor.ink)
            }
            Chart(points) { point in
                BarMark(
                    x: .value("Day", CapstanFormat.dayMonth(point.daykey)),
                    y: .value("Count", point.value)
                )
                .foregroundStyle(prominent ? CapstanColor.accent : CapstanColor.ink)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label)
                                .font(CapstanType.font(.caption))
                                .foregroundStyle(CapstanColor.ink)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: true)
                        }
                    }
                }
            }
            .frame(height: height)
            .padding(CapstanSpace.m)
            .capstanPlate()
        }
    }

    private func section(_ title: String, _ lines: [MarkFeed.Line], _ marker: Color) -> some View {
        VStack(alignment: .leading, spacing: CapstanSpace.s) {
            Text(title)
                .font(CapstanType.font(.headline))
                .foregroundStyle(CapstanColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            CapstanRule()
            if lines.isEmpty {
                Text("None recorded.")
                    .font(CapstanType.font(.body))
                    .foregroundStyle(CapstanColor.muted)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ForEach(lines.prefix(8)) { line in
                    LedgerLine(line: line, marker: marker)
                }
            }
        }
    }

    private func notice(_ note: String) -> some View {
        VStack(alignment: .leading, spacing: CapstanSpace.s) {
            Text(note)
                .font(CapstanType.font(.body))
                .foregroundStyle(CapstanColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            Button("Retry") {
                Task { await presenter.load() }
            }
            .buttonStyle(CapstanPressStyle(role: .quiet))
        }
        .padding(CapstanSpace.m)
        .capstanPlate()
    }
}
