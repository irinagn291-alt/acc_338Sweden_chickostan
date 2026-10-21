import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Tokens for the frame. Hex lives only in `DesignTokens`.
enum CapstanColor {
    static let bg = DesignTokens.bg
    static let surface = DesignTokens.surface
    static let ink = DesignTokens.ink
    static let accent = DesignTokens.accent
    static let muted = DesignTokens.muted

    #if canImport(UIKit)
    static func ui(_ color: Color) -> UIColor {
        let resolved = color.resolve(in: EnvironmentValues())
        return UIColor(
            red: CGFloat(resolved.red),
            green: CGFloat(resolved.green),
            blue: CGFloat(resolved.blue),
            alpha: CGFloat(resolved.opacity)
        )
    }
    #endif
}

/// Six steps. Helvetica Neue only, tabular when a count is live.
enum CapstanType {
    enum Step {
        case display
        case title
        case headline
        case body
        case callout
        case caption

        var size: CGFloat {
            switch self {
            case .display: 44
            case .title: 28
            case .headline: 20
            case .body: 17
            case .callout: 15
            case .caption: 13
            }
        }

        var textStyle: Font.TextStyle {
            switch self {
            case .display: .largeTitle
            case .title: .title2
            case .headline: .headline
            case .body: .body
            case .callout: .callout
            case .caption: .caption
            }
        }

        var weight: Font.Weight {
            switch self {
            case .display, .title: .bold
            case .headline: .semibold
            case .body, .callout, .caption: .regular
            }
        }
    }

    static func font(_ step: Step, tabular: Bool = false) -> Font {
        let base = Font.custom(DesignTokens.fontFamily, size: step.size, relativeTo: step.textStyle)
            .weight(step.weight)
        return tabular ? base.monospacedDigit() : base
    }
}

/// Base unit is 8. Gaps are multiples of it.
enum CapstanSpace {
    static let unit: CGFloat = 8
    static let s = unit
    static let m = unit * 2
    static let l = unit * 3
    static let xl = unit * 4
    static let xxl = unit * 6
}

/// Section 7.4. Cards use `card`. Chips use `chip`. No other radius.
enum CapstanRadius {
    static let card: CGFloat = 8
    static let chip: CGFloat = 6
}

enum CapstanStroke {
    static let hairline: CGFloat = 1
    static let thick: CGFloat = 4
}

/// Quiet motion. 180ms ease-out. Reduce Motion drops travel.
enum CapstanMotion {
    static let duration: Double = 0.18

    static func fade(_ reduce: Bool) -> Animation? {
        reduce ? nil : .easeOut(duration: duration)
    }
}

enum CapstanFormat {
    static func count(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func stamp(_ daykey: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: daykey)) ?? "0"
    }

    /// Chart axis label. Month and day, short enough to sit under one bar.
    static func dayMonth(_ daykey: Int) -> String {
        guard let date = DayKey.date(from: daykey) else { return stamp(daykey) }
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("Md")
        return formatter.string(from: date)
    }

    static func clock(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    static func whole(_ raw: String) -> Int? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let number = formatter.number(from: trimmed) else { return nil }
        let value = number.intValue
        guard value >= 0, Double(value) == number.doubleValue else { return nil }
        return value
    }
}

struct CapstanRule: View {
    var thick = false

    var body: some View {
        Rectangle()
            .fill(CapstanColor.ink)
            .frame(height: thick ? CapstanStroke.thick : CapstanStroke.hairline)
            .accessibilityHidden(true)
    }
}

struct CapstanPlate: ViewModifier {
    var radius: CGFloat = CapstanRadius.card

    func body(content: Content) -> some View {
        content
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(CapstanColor.ink, lineWidth: CapstanStroke.hairline)
            )
    }
}

extension View {
    func capstanPlate(radius: CGFloat = CapstanRadius.card) -> some View {
        modifier(CapstanPlate(radius: radius))
    }
}

/// Pressed, disabled, and accent or destructive. The live verb uses accent.
struct CapstanPressStyle: ButtonStyle {
    enum Role {
        case accent
        case quiet
        case destructive
    }

    var role: Role = .quiet
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CapstanType.font(.headline))
            .foregroundStyle(CapstanColor.ink)
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.horizontal, CapstanSpace.s)
            .background(fill(pressed: configuration.isPressed))
            .overlay(
                RoundedRectangle(cornerRadius: CapstanRadius.card, style: .continuous)
                    .stroke(border, lineWidth: role == .accent ? CapstanStroke.thick : CapstanStroke.hairline)
            )
            .clipShape(RoundedRectangle(cornerRadius: CapstanRadius.card, style: .continuous))
            .opacity(isEnabled ? (configuration.isPressed ? 0.72 : 1) : 0.4)
            .scaleEffect(reduceMotion || !configuration.isPressed ? 1 : 0.98)
            .animation(CapstanMotion.fade(reduceMotion), value: configuration.isPressed)
            .contentShape(RoundedRectangle(cornerRadius: CapstanRadius.card, style: .continuous))
    }

    private func fill(pressed: Bool) -> Color {
        switch role {
        case .accent:
            return pressed ? CapstanColor.accent.opacity(0.82) : CapstanColor.accent
        case .quiet:
            return CapstanColor.surface
        case .destructive:
            return pressed ? CapstanColor.muted.opacity(0.35) : CapstanColor.surface
        }
    }

    private var border: Color {
        role == .destructive ? CapstanColor.muted : CapstanColor.ink
    }
}

struct CapstanScreen<Content: View>: View {
    var title: String
    var onClose: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        NavigationStack {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(CapstanColor.bg.ignoresSafeArea())
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(CapstanType.font(.headline))
                                .foregroundStyle(CapstanColor.ink)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .accessibilityLabel("Close")
                    }
                }
        }
    }
}

#if canImport(UIKit)
enum CapstanHaptic {
    static func commit() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
#endif
