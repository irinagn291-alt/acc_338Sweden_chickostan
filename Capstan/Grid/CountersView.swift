import SwiftUI

/// Today's habits. Pin an open habit, or tick the one that is pinned.
struct CountersView: View {
    @Bindable var presenter: GridPresenter

    var body: some View {
        Group {
            if presenter.board.columns.isEmpty {
                EmptyBoard(
                    imageName: "cps_EmptyGridCutout",
                    title: "No habits yet.",
                    line: "Add a habit, pin it, then tick.",
                    action: "Add a habit",
                    onAction: { presenter.addColumn(name: "Reps") }
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: CapstanSpace.m) {
                        Text(lead)
                            .font(CapstanType.font(.body))
                            .foregroundStyle(CapstanColor.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        CapstanRule(thick: true)
                        ForEach(Array(presenter.board.columns.enumerated()), id: \.element.id) { index, face in
                            habitCard(face, lead: index == 0)
                        }
                    }
                    .padding(CapstanSpace.m)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CapstanColor.bg.ignoresSafeArea())
        .navigationTitle("Habits")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var lead: String {
        if presenter.board.columns.contains(where: \.pinned) {
            return "Tick the pinned habit. Pin another habit to move the lock."
        }
        return "Pin a habit. The next tick lands only on that habit."
    }

    private func habitCard(_ face: ColumnFace, lead: Bool) -> some View {
        VStack(alignment: .leading, spacing: CapstanSpace.m) {
            HStack(alignment: .center, spacing: CapstanSpace.m) {
                Text(CapstanFormat.count(face.tally))
                    .font(CapstanType.font(lead ? .display : .title, tabular: true))
                    .foregroundStyle(lead ? CapstanColor.accent : CapstanColor.ink)
                    .fixedSize(horizontal: true, vertical: true)
                VStack(alignment: .leading, spacing: CapstanSpace.s) {
                    Text(face.name)
                        .font(CapstanType.font(.headline))
                        .foregroundStyle(CapstanColor.ink)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Text(face.pinned ? "Pinned" : "Open")
                        .font(CapstanType.font(.caption))
                        .foregroundStyle(CapstanColor.ink)
                    if let limit = face.dailyLimit {
                        Text(ratio(face.tally, limit))
                            .font(CapstanType.font(.callout, tabular: true))
                            .foregroundStyle(CapstanColor.ink)
                    }
                }
                Spacer(minLength: CapstanSpace.s)
            }
            Button {
                if face.pinned {
                    presenter.tick(columnID: face.id)
                } else {
                    presenter.pin(columnID: face.id)
                }
            } label: {
                Text(face.pinned ? "Tick \(face.name)" : "Pin \(face.name)")
                    .lineLimit(1)
            }
            .buttonStyle(CapstanPressStyle(role: .accent))
        }
        .padding(CapstanSpace.m)
        .frame(maxWidth: .infinity, minHeight: lead ? 120 : 72, alignment: .leading)
        .capstanPlate()
    }

    private func ratio(_ tally: Int, _ limit: Int) -> String {
        CapstanFormat.count(tally) + " of " + CapstanFormat.count(limit)
    }
}
