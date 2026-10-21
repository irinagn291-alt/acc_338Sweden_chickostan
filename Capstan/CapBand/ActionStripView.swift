import SwiftUI

/// Actions under the live figure. Tick wears accent. Peel does not.
struct ActionStripView: View {
    var tickEnabled: Bool
    var busy: Bool
    var onPin: () -> Void
    var onTick: () -> Void
    var onPeel: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: CapstanSpace.s) {
            Button(action: onPin) {
                Label("Pin", systemImage: "scope")
            }
            .buttonStyle(CapstanPressStyle(role: .quiet))
            .disabled(busy)
            Button(action: onTick) {
                Label("Tick", systemImage: "plus")
            }
            .buttonStyle(CapstanPressStyle(role: .accent))
            .disabled(!tickEnabled || busy)
            Button(action: onPeel) {
                Label("Peel", systemImage: "arrow.uturn.backward")
            }
            .buttonStyle(CapstanPressStyle(role: .quiet))
            .disabled(busy)
        }
        .accessibilityElement(children: .contain)
    }
}

struct BandChip: View {
    var tally: Int
    var limit: Int?
    var overBand: Bool

    var body: some View {
        HStack(spacing: CapstanSpace.s) {
            RoundedRectangle(cornerRadius: CapstanRadius.chip, style: .continuous)
                .fill(overBand ? CapstanColor.ink : CapstanColor.accent)
                .frame(width: CapstanSpace.m, height: CapstanSpace.m)
                .accessibilityHidden(true)
            Text(caption)
                .font(CapstanType.font(.callout, tabular: true))
                .foregroundStyle(CapstanColor.ink)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, CapstanSpace.m)
        .frame(minHeight: 44)
        .background(CapstanColor.surface, in: RoundedRectangle(cornerRadius: CapstanRadius.chip, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CapstanRadius.chip, style: .continuous)
                .stroke(CapstanColor.ink, lineWidth: CapstanStroke.hairline)
        )
        .accessibilityElement(children: .combine)
    }

    private var caption: String {
        if let limit {
            let state = overBand ? "Over the daily cap" : "Within the daily cap"
            return "\(CapstanFormat.count(tally)) of \(CapstanFormat.count(limit)). \(state)"
        }
        return "\(CapstanFormat.count(tally)). No daily cap"
    }
}
