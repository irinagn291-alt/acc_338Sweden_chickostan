import SwiftUI

@main
struct CapstanWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchRoot()
        }
    }
}

/// Apple Watch cover. Read `ReviewLaunch.screen` and open the same
/// today / log / goals destinations as the iPhone app.
struct WatchRoot: View {
    var body: some View {
        switch ReviewLaunch.screen {
        case "log":
            WatchLog()
        case "goals":
            WatchGoals()
        default:
            WatchToday()
        }
    }
}

private enum WatchMetric {
    static let unit: CGFloat = 8
    static let card: CGFloat = 8
}

private struct WatchToday: View {
    var body: some View {
        VStack(alignment: .leading, spacing: WatchMetric.unit) {
            Text("Today")
                .font(.custom(DesignTokens.fontFamily, size: 17, relativeTo: .headline))
            Text("Pin one habit, then tick.")
                .font(.custom(DesignTokens.fontFamily, size: 13, relativeTo: .caption))
            Text("Tick")
                .font(.custom(DesignTokens.fontFamily, size: 20, relativeTo: .title3))
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(DesignTokens.accent, in: RoundedRectangle(cornerRadius: WatchMetric.card))
        }
        .padding(WatchMetric.unit)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DesignTokens.bg)
    }
}

private struct WatchLog: View {
    var body: some View {
        VStack(alignment: .leading, spacing: WatchMetric.unit) {
            Text("Log")
                .font(.custom(DesignTokens.fontFamily, size: 17, relativeTo: .headline))
            Text("Seven days of ticks, misses, and removed counts.")
                .font(.custom(DesignTokens.fontFamily, size: 13, relativeTo: .caption))
        }
        .padding(WatchMetric.unit)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DesignTokens.surface)
    }
}

private struct WatchGoals: View {
    var body: some View {
        VStack(alignment: .leading, spacing: WatchMetric.unit) {
            Text("Settings")
                .font(.custom(DesignTokens.fontFamily, size: 17, relativeTo: .headline))
            Text("Caps, reset, and support live on iPhone.")
                .font(.custom(DesignTokens.fontFamily, size: 13, relativeTo: .caption))
        }
        .padding(WatchMetric.unit)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DesignTokens.bg)
    }
}
