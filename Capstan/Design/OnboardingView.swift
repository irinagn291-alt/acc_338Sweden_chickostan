import SwiftUI

/// Three pages. Start and Skip both leave a habit ready to pin.
struct OnboardingView: View {
    var onFinish: () -> Void
    @State private var page = 0
    @ScaledMetric(relativeTo: .largeTitle) private var artHeight: CGFloat = 240

    private let pages: [(image: String, title: String, line: String)] = [
        (
            "cps_Onboarding1",
            "Count one habit at a time.",
            "Pin the habit you mean. The next tick lands there, not on a neighbor."
        ),
        (
            "cps_Onboarding2",
            "Tick only what you pinned.",
            "A tick on any other habit is kept as a miss and does not add."
        ),
        (
            "cps_Onboarding3",
            "Peel a wrong tap.",
            "Peel drops the latest tick or miss from today, then you pin again."
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: CapstanSpace.m) {
            pageView(pages[page])
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            Text(pageCaption)
                .font(CapstanType.font(.caption, tabular: true))
                .foregroundStyle(CapstanColor.muted)
            HStack(spacing: CapstanSpace.s) {
                if page > 0 {
                    Button("Back") { page -= 1 }
                        .buttonStyle(CapstanPressStyle(role: .quiet))
                }
                Button(page == pages.count - 1 ? "Start" : "Next") {
                    if page == pages.count - 1 {
                        onFinish()
                    } else {
                        page += 1
                    }
                }
                .buttonStyle(CapstanPressStyle(role: .accent))
            }
            Button("Skip") { onFinish() }
                .buttonStyle(CapstanPressStyle(role: .quiet))
        }
        .padding(CapstanSpace.m)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CapstanColor.bg.ignoresSafeArea())
    }

    private var pageCaption: String {
        let current = CapstanFormat.count(page + 1)
        let total = CapstanFormat.count(pages.count)
        return "Page \(current) of \(total)"
    }

    private func pageView(_ page: (image: String, title: String, line: String)) -> some View {
        VStack(alignment: .leading, spacing: CapstanSpace.m) {
            Image(page.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: artHeight)
                .background(CapstanColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: CapstanRadius.card, style: .continuous))
                .accessibilityHidden(true)
            CapstanRule(thick: true)
            Text(page.title)
                .font(CapstanType.font(.title))
                .foregroundStyle(CapstanColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(page.line)
                .font(CapstanType.font(.body))
                .foregroundStyle(CapstanColor.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
