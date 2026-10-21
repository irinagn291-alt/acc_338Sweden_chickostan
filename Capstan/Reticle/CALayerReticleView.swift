import SwiftUI

/// The lock. Pin a habit here, or tick the one already under the lock.
struct CALayerReticleView: View {
    @Bindable var presenter: GridPresenter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CapstanSpace.m) {
                Text(headline)
                    .font(CapstanType.font(.title))
                    .foregroundStyle(CapstanColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                CapstanRule(thick: true)
                Text(bodyCopy)
                    .font(CapstanType.font(.body))
                    .foregroundStyle(CapstanColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if let face = pinned {
                    VStack(alignment: .leading, spacing: CapstanSpace.s) {
                        Text(face.name)
                            .font(CapstanType.font(.headline))
                            .foregroundStyle(CapstanColor.ink)
                            .lineLimit(1)
                        Text(CapstanFormat.count(face.tally))
                            .font(CapstanType.font(.display, tabular: true))
                            .foregroundStyle(CapstanColor.accent)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Pinned")
                            .font(CapstanType.font(.caption))
                            .foregroundStyle(CapstanColor.ink)
                    }
                    .padding(CapstanSpace.l)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(
                        RoundedRectangle(cornerRadius: CapstanRadius.card, style: .continuous)
                            .stroke(CapstanColor.accent, lineWidth: CapstanStroke.thick)
                    )
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CapstanRadius.card, style: .continuous))
                    Button {
                        presenter.tick(columnID: face.id)
                    } label: {
                        Text("Tick \(face.name)")
                            .lineLimit(1)
                    }
                    .buttonStyle(CapstanPressStyle(role: .accent))
                }
                if !others.isEmpty {
                    Text(pinned == nil ? "Pin a habit" : "Move the lock")
                        .font(CapstanType.font(.headline))
                        .foregroundStyle(CapstanColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(others) { face in
                        Button {
                            presenter.pin(columnID: face.id)
                        } label: {
                            Text("Pin \(face.name)")
                                .lineLimit(1)
                        }
                        .buttonStyle(CapstanPressStyle(role: pinned == nil ? .accent : .quiet))
                    }
                }
            }
            .padding(CapstanSpace.m)
        }
        .background(CapstanColor.bg.ignoresSafeArea())
        .navigationTitle("Lock")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var pinned: ColumnFace? {
        guard let id = presenter.board.reticle?.columnID else { return nil }
        return presenter.board.columns.first { $0.id == id }
    }

    private var others: [ColumnFace] {
        presenter.board.columns.filter { $0.id != pinned?.id }
    }

    private var headline: String {
        if let pinned {
            return "\(pinned.name) is pinned."
        }
        return "Pin a habit to set the lock."
    }

    private var bodyCopy: String {
        if let pinned {
            return "Tick adds one to \(pinned.name), then the lock releases. Pin another habit to move the lock."
        }
        return "Tick adds one to the pinned habit, then the lock releases. A tick on any other habit is a miss and does not add."
    }
}
