import SwiftUI
import UIKit

/// Perfect regular 4×4 grid: 16 equal squares, always fully visible (no scroll).
struct PadGridView: View {
    @EnvironmentObject private var controller: PadController
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        GeometryReader { geo in
            let gap: CGFloat = 10
            let block = min(geo.size.width, geo.size.height)
            let cell = (block - gap * 3) / 4
            let rows = controller.gridRowsTopFirst

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
            subtitle: side >= 70 ? subtitle : "",
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
            corner: max(6, side * 0.08)
        )
    }
}

final class PadUIView: UIView {
    var onDown: ((CGFloat?) -> Void)?
    var onUp: (() -> Void)?
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stack = UIStackView()
    private var touching = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = false
        clipsToBounds = true
        backgroundColor = UIColor(white: 0.85, alpha: 0.25)

        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        subtitleLabel.font = .systemFont(ofSize: 11, weight: .medium)
        for label in [titleLabel, subtitleLabel] {
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.55
            label.textColor = UIColor(white: 0.85, alpha: 1)
        }
        titleLabel.numberOfLines = 2

        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

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
        layer.cornerRadius = corner
        backgroundColor = isLit
            ? UIColor(red: 0.78, green: 0.55, blue: 1.0, alpha: 0.92)
            : UIColor(white: 0.88, alpha: 0.24)
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 1, alpha: 0.18).cgColor
        transform = isActive ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
        let text = isLit ? UIColor.white : UIColor(white: 0.82, alpha: 1)
        titleLabel.textColor = text
        subtitleLabel.textColor = isLit ? UIColor.white.withAlphaComponent(0.85) : UIColor(white: 0.55, alpha: 1)
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
