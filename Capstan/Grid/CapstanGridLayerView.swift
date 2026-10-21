import SwiftUI
import UIKit
import QuartzCore

/// The one custom surface. Column slabs, band markers, and the lock frame
/// are drawn with CALayer. Every other screen stays on stock controls.
struct CapstanGridLayerView: UIViewRepresentable {
    var columns: [ColumnFace]
    var pinnedID: UUID?
    var selectedID: UUID?
    var onSelect: (UUID) -> Void
    var onPeel: () -> Void

    func makeUIView(context: Context) -> CapstanGridCanvas {
        let view = CapstanGridCanvas()
        view.onSelect = onSelect
        view.onPeel = onPeel
        return view
    }

    func updateUIView(_ uiView: CapstanGridCanvas, context: Context) {
        _ = context
        uiView.onSelect = onSelect
        uiView.onPeel = onPeel
        uiView.render(columns: columns, pinnedID: pinnedID, selectedID: selectedID)
    }
}

final class CapstanGridCanvas: UIView {
    var onSelect: (UUID) -> Void = { _ in }
    var onPeel: () -> Void = {}

    private var columns: [ColumnFace] = []
    private var pinnedID: UUID?
    private var selectedID: UUID?
    private var hitFrames: [(UUID, CGRect)] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
        let press = UILongPressGestureRecognizer(target: self, action: #selector(peel(_:)))
        press.minimumPressDuration = 0.45
        addGestureRecognizer(press)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func render(columns: [ColumnFace], pinnedID: UUID?, selectedID: UUID?) {
        self.columns = columns
        self.pinnedID = pinnedID
        self.selectedID = selectedID
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        hitFrames = []
        accessibilityElements = nil
        guard bounds.width > 1, bounds.height > 1 else { return }
        let frames = Self.frames(columns: columns, pinnedID: pinnedID, in: bounds)
        var elements: [UIAccessibilityElement] = []
        for (face, rect) in frames {
            hitFrames.append((face.id, rect))
            let slab = Self.slab(face: face, rect: rect, pinned: face.id == pinnedID, selected: face.id == selectedID, traits: traitCollection)
            slab.frame = rect
            layer.addSublayer(slab)
            let element = UIAccessibilityElement(accessibilityContainer: self)
            element.accessibilityFrameInContainerSpace = rect
            element.accessibilityLabel = Self.label(for: face)
            element.accessibilityTraits = .button
            elements.append(element)
        }
        accessibilityElements = elements
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        guard let hit = hitFrames.last(where: { $0.1.contains(point) }) else { return }
        onSelect(hit.0)
    }

    @objc private func peel(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        onPeel()
    }

    private static func label(for face: ColumnFace) -> String {
        var parts = [face.name, CapstanFormat.count(face.tally)]
        if face.pinned { parts.append("pinned") }
        if face.overBand { parts.append("over the daily cap") }
        return parts.joined(separator: ", ")
    }

    private static func frames(columns: [ColumnFace], pinnedID: UUID?, in bounds: CGRect) -> [(ColumnFace, CGRect)] {
        guard !columns.isEmpty else { return [] }
        let gap = CapstanSpace.s
        let width = bounds.width - gap * 2
        var y = gap
        var result: [(ColumnFace, CGRect)] = []
        let pinned = columns.first { $0.id == pinnedID }
        let rest = columns.filter { $0.id != pinnedID }
        let usable = bounds.height - gap
        if let pinned {
            let height = min(max(usable * 0.42, 88), usable * 0.55)
            result.append((pinned, CGRect(x: gap, y: y, width: width, height: height)))
            y += height + gap
        }
        guard !rest.isEmpty else { return result }
        let weights: [CGFloat] = rest.enumerated().map { index, _ in
            index.isMultiple(of: 2) ? 1.2 : 0.8
        }
        let weightSum = weights.reduce(0, +)
        let leftover = max(usable - (y - gap), CGFloat(rest.count) * 44 + gap * CGFloat(rest.count))
        for (index, face) in rest.enumerated() {
            let share = leftover * (weights[index] / weightSum)
            let height = max(44, share - gap)
            result.append((face, CGRect(x: gap, y: y, width: width, height: height)))
            y += height + gap
        }
        return result
    }

    private static func slab(face: ColumnFace, rect: CGRect, pinned: Bool, selected: Bool, traits: UITraitCollection) -> CALayer {
        let host = CALayer()
        host.bounds = CGRect(origin: .zero, size: rect.size)
        host.backgroundColor = CapstanColor.ui(CapstanColor.surface).cgColor
        host.cornerRadius = CapstanRadius.card
        host.borderWidth = pinned ? CapstanStroke.thick : CapstanStroke.hairline
        host.borderColor = CapstanColor.ui(pinned ? CapstanColor.accent : CapstanColor.ink).cgColor
        if pinned {
            host.shadowColor = CapstanColor.ui(CapstanColor.ink).cgColor
            host.shadowOffset = CGSize(width: CapstanStroke.thick, height: CapstanStroke.thick)
            host.shadowOpacity = 1
            host.shadowRadius = 0
        }
        if selected {
            let inset = CAShapeLayer()
            inset.frame = host.bounds
            inset.path = UIBezierPath(
                roundedRect: host.bounds.insetBy(dx: CapstanSpace.s, dy: CapstanSpace.s),
                cornerRadius: CapstanRadius.chip
            ).cgPath
            inset.fillColor = UIColor.clear.cgColor
            inset.strokeColor = CapstanColor.ui(CapstanColor.ink).cgColor
            inset.lineWidth = CapstanStroke.hairline
            host.addSublayer(inset)
        }
        if pinned {
            let reticle = CAShapeLayer()
            reticle.frame = host.bounds
            reticle.path = brackets(in: host.bounds.insetBy(dx: CapstanSpace.m, dy: CapstanSpace.m)).cgPath
            reticle.strokeColor = CapstanColor.ui(CapstanColor.accent).cgColor
            reticle.fillColor = UIColor.clear.cgColor
            reticle.lineWidth = CapstanStroke.thick
            reticle.lineCap = .square
            host.addSublayer(reticle)
        }
        if let limit = face.dailyLimit, limit > 0 {
            let ratio = min(1, CGFloat(face.tally) / CGFloat(limit))
            let marker = CALayer()
            let barWidth = max(CapstanSpace.s, (rect.width - CapstanSpace.m * 2) * ratio)
            marker.frame = CGRect(
                x: CapstanSpace.m,
                y: rect.height - CapstanSpace.m - CapstanStroke.thick,
                width: barWidth,
                height: CapstanStroke.thick
            )
            marker.backgroundColor = CapstanColor.ui(face.overBand ? CapstanColor.ink : CapstanColor.accent).cgColor
            marker.cornerRadius = CapstanRadius.chip
            host.addSublayer(marker)
            if face.overBand {
                let flag = CALayer()
                flag.frame = CGRect(x: rect.width - CapstanSpace.xl, y: CapstanSpace.m, width: CapstanSpace.m, height: CapstanSpace.m)
                flag.backgroundColor = CapstanColor.ui(CapstanColor.ink).cgColor
                flag.cornerRadius = CapstanRadius.chip
                host.addSublayer(flag)
            }
        }
        let name = textLayer(
            face.name,
            fontSize: 17,
            weight: .medium,
            color: CapstanColor.ink,
            alignment: .left,
            traits: traits
        )
        name.frame = CGRect(x: CapstanSpace.m, y: CapstanSpace.m, width: rect.width * 0.62, height: 28)
        host.addSublayer(name)
        let tally = textLayer(
            CapstanFormat.count(face.tally),
            fontSize: pinned ? 36 : 22,
            weight: .bold,
            color: pinned ? CapstanColor.accent : CapstanColor.ink,
            alignment: .right,
            traits: traits
        )
        tally.frame = CGRect(x: rect.width * 0.5, y: CapstanSpace.m, width: rect.width * 0.5 - CapstanSpace.m, height: pinned ? 44 : 32)
        host.addSublayer(tally)
        return host
    }

    private static func textLayer(
        _ string: String,
        fontSize: CGFloat,
        weight: UIFont.Weight,
        color: Color,
        alignment: CATextLayerAlignmentMode,
        traits: UITraitCollection
    ) -> CATextLayer {
        let layer = CATextLayer()
        layer.string = string
        layer.contentsScale = traits.displayScale
        let base = UIFont(name: DesignTokens.fontFamily, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: weight)
        let scaled = UIFontMetrics(forTextStyle: .body).scaledFont(for: base, compatibleWith: traits)
        layer.font = scaled
        layer.fontSize = scaled.pointSize
        layer.foregroundColor = CapstanColor.ui(color).cgColor
        layer.alignmentMode = alignment
        layer.truncationMode = .end
        layer.isWrapped = false
        return layer
    }

    private static func brackets(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let arm = min(CapstanSpace.l, min(rect.width, rect.height) * 0.28)
        let corners: [(CGPoint, CGPoint, CGPoint)] = [
            (CGPoint(x: rect.minX, y: rect.minY + arm), CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.minX + arm, y: rect.minY)),
            (CGPoint(x: rect.maxX - arm, y: rect.minY), CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.minY + arm)),
            (CGPoint(x: rect.minX, y: rect.maxY - arm), CGPoint(x: rect.minX, y: rect.maxY), CGPoint(x: rect.minX + arm, y: rect.maxY)),
            (CGPoint(x: rect.maxX - arm, y: rect.maxY), CGPoint(x: rect.maxX, y: rect.maxY), CGPoint(x: rect.maxX, y: rect.maxY - arm))
        ]
        for (start, corner, end) in corners {
            path.move(to: start)
            path.addLine(to: corner)
            path.addLine(to: end)
        }
        return path
    }
}
