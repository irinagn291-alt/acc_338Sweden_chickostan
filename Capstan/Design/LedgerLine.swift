import SwiftUI

/// One ledger row. A square marker carries the kind so colour is not the only signal.
struct LedgerLine: View {
    var line: MarkFeed.Line
    var marker: Color

    var body: some View {
        HStack(alignment: .center, spacing: CapstanSpace.m) {
            RoundedRectangle(cornerRadius: CapstanRadius.chip, style: .continuous)
                .fill(marker)
                .frame(width: CapstanSpace.m, height: CapstanSpace.m)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: CapstanSpace.s) {
                Text(line.habit)
                    .font(CapstanType.font(.headline))
                    .foregroundStyle(CapstanColor.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)
                Text(line.detail)
                    .font(CapstanType.font(.callout))
                    .foregroundStyle(CapstanColor.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: CapstanSpace.s)
            VStack(alignment: .trailing, spacing: CapstanSpace.s) {
                Text(CapstanFormat.stamp(line.daykey))
                    .font(CapstanType.font(.caption, tabular: true))
                    .foregroundStyle(CapstanColor.ink)
                Text(CapstanFormat.clock(line.instant))
                    .font(CapstanType.font(.caption, tabular: true))
                    .foregroundStyle(CapstanColor.muted)
            }
        }
        .padding(CapstanSpace.m)
        .frame(maxWidth: .infinity, minHeight: 44)
        .capstanPlate()
    }
}

struct EmptyBoard: View {
    var imageName: String
    var title: String
    var line: String
    var action: String
    var onAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: CapstanSpace.l) {
            Spacer(minLength: CapstanSpace.xl)
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .background(CapstanColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: CapstanRadius.card, style: .continuous))
                .accessibilityHidden(true)
            Text(title)
                .font(CapstanType.font(.title))
                .foregroundStyle(CapstanColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(line)
                .font(CapstanType.font(.body))
                .foregroundStyle(CapstanColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: CapstanSpace.xl)
            Button(action: onAction) {
                Text(action)
            }
            .buttonStyle(CapstanPressStyle(role: .accent))
        }
        .padding(CapstanSpace.m)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
