import SwiftUI
import UIKit

/// Perfect regular 4×4 grid: 16 equal squares, always fully visible (no scroll).
struct PadGridView: View {
    @EnvironmentObject private var controller: PadController
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        GeometryReader { geo in
            let gap: CGFloat = max(2.5, min(4.5, geo.size.width * 0.008))
            let inset: CGFloat = gap
            let block = min(geo.size.width, geo.size.height)
            let cell = max(1, (block - inset * 2 - gap * 3) / 4)
            let rows = controller.gridRowsTopFirst
            let wellRadius = max(8, cell * 0.1)

            ZStack {
                RoundedRectangle(cornerRadius: wellRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.55),
                                PadTheme.chassisWell,
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: wellRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
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

    private var corner: CGFloat { max(6, side * 0.09) }
    private var bright: Bool { isLit || isActive }

    var body: some View {
        ZStack {
            // Silicone / LED pad body — SwiftUI radial so device always matches preview
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: bright
                            ? [PadTheme.purpleHit, PadTheme.purpleGlow, PadTheme.purple, PadTheme.purpleEdge]
                            : [PadTheme.purpleCore, Color(red: 0.68, green: 0.40, blue: 1.0), PadTheme.purple, PadTheme.purpleEdge],
                        center: UnitPoint(x: 0.5, y: 0.42),
                        startRadius: 2,
                        endRadius: side * 0.72
                    )
                )
                .overlay(
                    // Top translucent sheen (rubber face)
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(bright ? 0.28 : 0.18),
                                    Color.white.opacity(0.04),
                                    Color.clear,
                                ],
                                startPoint: .top,
                                endPoint: UnitPoint(x: 0.5, y: 0.55)
                            )
                        )
                        .allowsHitTesting(false)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(bright ? 0.45 : 0.22),
                                    Color.white.opacity(0.06),
                                    Color.black.opacity(0.35),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: PadTheme.purpleGlow.opacity(bright ? 0.55 : 0.3), radius: bright ? 10 : 5, y: 0)

            // Beginner labels — bottom placement like hardware pad faceplate text
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                HStack(alignment: .bottom, spacing: 4) {
                    Text(title)
                        .font(.system(size: max(11, side * 0.13), weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.95))
                        .lineLimit(2)
                        .minimumScaleFactor(0.55)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 2)
                    if side >= 58 {
                        Text(subtitle)
                            .font(.system(size: max(9, side * 0.09), weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.72))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                }
                .padding(.horizontal, max(6, side * 0.07))
                .padding(.bottom, max(6, side * 0.07))
            }
            .allowsHitTesting(false)

            // Force / multi-touch capture only
            ForceTouchPadRepresentable(
                onDown: onDown,
                onUp: onUp
            )
        }
        .scaleEffect(isActive ? 0.97 : 1)
        .animation(.easeOut(duration: 0.08), value: isActive)
    }
}

struct ForceTouchPadRepresentable: UIViewRepresentable {
    var onDown: (CGFloat?) -> Void
    var onUp: () -> Void

    func makeUIView(context: Context) -> PadTouchView {
        let v = PadTouchView()
        v.onDown = onDown
        v.onUp = onUp
        v.backgroundColor = .clear
        v.isOpaque = false
        return v
    }

    func updateUIView(_ uiView: PadTouchView, context: Context) {
        uiView.onDown = onDown
        uiView.onUp = onUp
    }
}

/// Transparent hit target — visual chrome lives in SwiftUI.
final class PadTouchView: UIView {
    var onDown: ((CGFloat?) -> Void)?
    var onUp: (() -> Void)?
    private var touching = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = false
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) { fatalError() }

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
