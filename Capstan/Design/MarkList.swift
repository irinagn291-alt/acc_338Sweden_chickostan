import SwiftUI

extension MarkList {
    static func totals(_ lines: [MarkFeed.Line]) -> [MarkMetric] {
        Dictionary(grouping: lines, by: \.habit)
            .map { MarkMetric(label: $0.key, value: $0.value.count) }
            .sorted { $0.label < $1.label }
    }
}

struct MarkMetric: Identifiable, Equatable {
    var label: String
    var value: Int
    var id: String { label }
}

/// A full-width ledger. A filled list keeps a mechanic panel on the rest of the canvas.
struct MarkList: View {
    var title: String
    var lines: [MarkFeed.Line]
    var marker: Color
    var emptyTitle: String
    var emptyLine: String
    var imageName: String
    var onRetry: () -> Void
    var panelTitle: String = ""
    var metrics: [MarkMetric] = []
    var actionTitle: String?
    var actionLine: String?
    var onAction: (() -> Void)?

    var body: some View {
        Group {
            if lines.isEmpty {
                EmptyBoard(
                    imageName: imageName,
                    title: emptyTitle,
                    line: emptyLine,
                    action: "Retry",
                    onAction: onRetry
                )
            } else {
                GeometryReader { geo in
                    ScrollView {
                        VStack(alignment: .leading, spacing: CapstanSpace.m) {
                            Text(CapstanFormat.count(lines.count))
                                .font(CapstanType.font(.display, tabular: true))
                                .foregroundStyle(CapstanColor.accent)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(title)
                                .font(CapstanType.font(.title))
                                .foregroundStyle(CapstanColor.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            CapstanRule(thick: true)
                            ForEach(lines) { line in
                                LedgerLine(line: line, marker: marker)
                            }
                            if !panelTitle.isEmpty {
                                markPanel
                                    .frame(maxWidth: .infinity, minHeight: max(280, geo.size.height * 0.55), alignment: .top)
                            }
                        }
                        .padding(CapstanSpace.m)
                        .frame(maxWidth: .infinity, minHeight: geo.size.height, alignment: .top)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CapstanColor.bg.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var markPanel: some View {
        VStack(alignment: .leading, spacing: CapstanSpace.m) {
            Text(panelTitle)
                .font(CapstanType.font(.headline))
                .foregroundStyle(CapstanColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(metrics) { metric in
                HStack(alignment: .firstTextBaseline, spacing: CapstanSpace.m) {
                    Text(metric.label)
                        .font(CapstanType.font(.body))
                        .foregroundStyle(CapstanColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: CapstanSpace.s)
                    Text(CapstanFormat.count(metric.value))
                        .font(CapstanType.font(.title, tabular: true))
                        .foregroundStyle(CapstanColor.accent)
                }
                .frame(minHeight: 44)
            }
            if let actionLine, !actionLine.isEmpty {
                Text(actionLine)
                    .font(CapstanType.font(.body))
                    .foregroundStyle(CapstanColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let actionTitle, let onAction {
                Button(action: onAction) {
                    Text(actionTitle)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(CapstanPressStyle(role: .accent))
            }
        }
        .padding(CapstanSpace.m)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .capstanPlate()
    }
}
