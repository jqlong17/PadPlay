import SwiftUI
import UIKit

/// Perfect regular 4×4 grid: 16 equal squares, always fully visible (no scroll).
struct PadGridView: View {
    @EnvironmentObject private var controller: PadController
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        GeometryReader { geo in
            // Thin chassis wells between pads (preview: seated silicone, not large gaps).
            let gap: CGFloat = max(3, min(5, geo.size.width * 0.01))
            let inset: CGFloat = gap
            let block = min(geo.size.width, geo.size.height)
            // 4 cells + 3 inter-gaps + 2 outer insets must fit in `block`.
            let cell = max(1, (block - inset * 2 - gap * 3) / 4)
            let rows = controller.gridRowsTopFirst
            let wellRadius = max(8, cell * 0.12)

            ZStack {
                RoundedRectangle(cornerRadius: wellRadius, style: .continuous)
                    .fill(PadTheme.chassisWell)
                    .overlay(
                        RoundedRectangle(cornerRadius: wellRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )

                VStack(spacing: gap) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: gap) {
                            ForEach(row) { pad in
                                ForcePadCell(
                                    pad: pad,
                                    side: cell,
                                    title: settings.t(pad.nameKey),
                                    subtitle: settings.t(pad.categoryKey),
                                    isLit: controller.litPads.contains(pad.id),
                                    isActive: controller.activePads.contains(pad.id),
                                    onDown: { force in
                                        controller.padTouchDown(pad: pad, force: force)
                                    },
                                    onUp: {
                                        controller.padTouchUp(pad: pad)
                                    }
                                )
                                .frame(width: cell, height: cell)
                            }
                        }
                        .frame(height: cell)
                    }
                }
                .padding(inset)
            }
            .frame(width: block, height: block)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct ForcePadCell: View {
    let pad: PadInfo
    let side: CGFloat
    let title: String
    let subtitle: String
    let isLit: Bool
    let isActive: Bool
    let onDown: (CGFloat?) -> Void
    let onUp: () -> Void

    var body: some View {
        ForceTouchPadRepresentable(
            side: side,
            isLit: isLit,
            isActive: isActive,
            title: title,
            subtitle: side >= 64 ? subtitle : "",
            onDown: onDown,
            onUp: onUp
        )
        .frame(width: side, height: side)
    }
}

struct ForceTouchPadRepresentable: UIViewRepresentable {
    var side: CGFloat
    var isLit: Bool
    var isActive: Bool
    var title: String
    var subtitle: String
    var onDown: (CGFloat?) -> Void
    var onUp: () -> Void

    func makeUIView(context: Context) -> PadUIView {
        let v = PadUIView()
        v.onDown = onDown
        v.onUp = onUp
        return v
    }

    func updateUIView(_ uiView: PadUIView, context: Context) {
        uiView.onDown = onDown
        uiView.onUp = onUp
        uiView.apply(
            title: title,
            subtitle: subtitle,
            isLit: isLit,
            isActive: isActive,
            corner: max(7, side * 0.1)
        )
    }
}

/// Silicone-style backlit pad: radial purple glow (idle always lit; hit brightens).
final class PadUIView: UIView {
    var onDown: ((CGFloat?) -> Void)?
    var onUp: (() -> Void)?

    private let glowLayer = CAGradientLayer()
    private let sheenLayer = CAGradientLayer()
    private let borderLayer = CAShapeLayer()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stack = UIStackView()
    private var touching = false
    private var corner: CGFloat = 10

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = false
        // Allow soft purple bloom outside the pad; content is masked via cornerRadius.
        clipsToBounds = false
        backgroundColor = .clear
        layer.masksToBounds = false

        glowLayer.type = .radial
        glowLayer.startPoint = CGPoint(x: 0.5, y: 0.42)
        glowLayer.endPoint = CGPoint(x: 1.15, y: 1.15)
        glowLayer.masksToBounds = true
        layer.insertSublayer(glowLayer, at: 0)

        sheenLayer.type = .axial
        sheenLayer.colors = [
            UIColor.white.withAlphaComponent(0.22).cgColor,
            UIColor.white.withAlphaComponent(0.02).cgColor,
            UIColor.clear.cgColor,
        ]
        sheenLayer.locations = [0, 0.35, 1]
        sheenLayer.startPoint = CGPoint(x: 0.5, y: 0)
        sheenLayer.endPoint = CGPoint(x: 0.5, y: 0.55)
        sheenLayer.masksToBounds = true
        layer.insertSublayer(sheenLayer, at: 1)

        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.white.withAlphaComponent(0.22).cgColor
        borderLayer.lineWidth = 1
        layer.addSublayer(borderLayer)

        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        subtitleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        for label in [titleLabel, subtitleLabel] {
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.55
            label.textColor = PadTheme.UI.label
        }
        titleLabel.numberOfLines = 2

        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 5),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -5),
        ])

        applyIdleGlow(lit: false, active: false)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        glowLayer.frame = bounds
        glowLayer.cornerRadius = corner
        sheenLayer.frame = bounds
        sheenLayer.cornerRadius = corner
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: corner)
        borderLayer.path = path.cgPath
        layer.cornerRadius = corner
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: corner).cgPath
    }

    func apply(
        title: String,
        subtitle: String,
        isLit: Bool,
        isActive: Bool,
        corner: CGFloat
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle.isEmpty
        self.corner = corner
        layer.cornerRadius = corner
        applyIdleGlow(lit: isLit, active: isActive)
        transform = isActive ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
        setNeedsLayout()
    }

    private func applyIdleGlow(lit: Bool, active: Bool) {
        // Pads are always purple silicone; hit/lit brightens the core.
        let bright = lit || active
        if bright {
            glowLayer.colors = [
                PadTheme.UI.purpleHitCore.cgColor,
                PadTheme.UI.purpleHitMid.cgColor,
                PadTheme.UI.purpleHitEdge.cgColor,
            ]
            layer.shadowColor = PadTheme.UI.purpleHitMid.cgColor
            layer.shadowOpacity = 0.55
            layer.shadowRadius = 10
            layer.shadowOffset = .zero
            borderLayer.strokeColor = UIColor.white.withAlphaComponent(0.42).cgColor
            titleLabel.textColor = .white
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        } else {
            glowLayer.colors = [
                PadTheme.UI.purpleCore.cgColor,
                PadTheme.UI.purpleMid.cgColor,
                PadTheme.UI.purpleEdge.cgColor,
            ]
            layer.shadowColor = PadTheme.UI.purpleMid.cgColor
            layer.shadowOpacity = 0.28
            layer.shadowRadius = 6
            layer.shadowOffset = .zero
            borderLayer.strokeColor = UIColor.white.withAlphaComponent(0.18).cgColor
            titleLabel.textColor = PadTheme.UI.label
            subtitleLabel.textColor = PadTheme.UI.dimLabel
        }
        glowLayer.locations = [0, 0.42, 1]
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first, !touching else { return }
        touching = true
        let force: CGFloat? = t.maximumPossibleForce > 0 ? t.force : nil
        onDown?(force)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touching = false
        onUp?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touching = false
        onUp?()
    }
}
