import SwiftUI
import UIKit

/// 4×4 pad stage — vision A hard 4px corners + radial backlight face.
/// Labels under each pad (never inside the face). Hit = Recipe A++ rim + soft outer halo.
struct PadGridView: View {
    @EnvironmentObject private var controller: PadController
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        GeometryReader { geo in
            let layout = Self.layout(in: geo.size)
            let rows = controller.gridRowsTopFirst

            ZStack {
                RoundedRectangle(cornerRadius: max(6, layout.padH * 0.08), style: .continuous)
                    .fill(PadTheme.chassisWell)

                VStack(spacing: layout.vGap) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        HStack(alignment: .top, spacing: layout.hGap) {
                            ForEach(row) { pad in
                                ForcePadCell(
                                    pad: pad,
                                    padWidth: layout.padW,
                                    padHeight: layout.padH,
                                    labelHeight: layout.labelH,
                                    title: settings.t(pad.nameKey),
                                    subtitle: settings.t(pad.categoryKey),
                                    flash: controller.flashIntensity(for: pad.id),
                                    isActive: controller.activePads.contains(pad.id),
                                    onDown: { force in
                                        controller.padTouchDown(pad: pad, force: force)
                                    },
                                    onUp: {
                                        controller.padTouchUp(pad: pad)
                                    }
                                )
                                .frame(width: layout.padW, height: layout.cellH, alignment: .top)
                            }
                        }
                    }
                }
                .padding(layout.inset)
            }
            .frame(width: layout.gridW, height: layout.gridH)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    /// Fit 4×4 horizontal pads + under-pad labels into the available rectangle.
    /// Shared with calibration wireframe so reported pad frames match live layout.
    static func layout(in size: CGSize) -> (
        padW: CGFloat, padH: CGFloat, labelH: CGFloat, cellH: CGFloat,
        hGap: CGFloat, vGap: CGFloat, inset: CGFloat, gridW: CGFloat, gridH: CGFloat
    ) {
        let aspect = PadTheme.padAspect
        let inset: CGFloat = max(4, min(10, min(size.width, size.height) * 0.012))
        let availW = max(1, size.width - inset * 2)
        let availH = max(1, size.height - inset * 2)

        // Mock: h-gap ≈ 14% of pad width; v-gap carries the label band.
        func metrics(padW: CGFloat) -> (padH: CGFloat, hGap: CGFloat, labelH: CGFloat, vGap: CGFloat, cellH: CGFloat, gridW: CGFloat, gridH: CGFloat) {
            let padH = padW / aspect
            let hGap = padW * 0.14
            let labelH = max(12, min(22, padH * 0.18))
            let labelPad: CGFloat = max(2, padH * 0.04)
            let vGap = max(4, labelPad) // spacing between rows (label sits in cell)
            let cellH = padH + labelPad + labelH
            let gridW = 4 * padW + 3 * hGap + inset * 2
            let gridH = 4 * cellH + 3 * vGap + inset * 2
            return (padH, hGap, labelH, vGap, cellH, gridW, gridH)
        }

        // Width-limited padW from 4 cols + 3 gaps.
        let padWFromWidth = availW / (4 + 3 * 0.14)
        // Height-limited: 4*(padH + labelBand) + 3*vGap ≈ availH
        let padHFromHeight = availH / (4 * 1.26 + 3 * 0.05)
        let padWFromHeight = padHFromHeight * aspect

        var padW = min(padWFromWidth, padWFromHeight)
        padW = max(36, padW)

        var m = metrics(padW: padW)
        // Shrink if still overflowing (label band heuristic).
        if m.gridW > size.width || m.gridH > size.height {
            let sx = size.width / max(m.gridW, 1)
            let sy = size.height / max(m.gridH, 1)
            padW *= min(sx, sy)
            m = metrics(padW: padW)
        }

        return (
            padW: padW,
            padH: m.padH,
            labelH: m.labelH,
            cellH: m.cellH,
            hGap: m.hGap,
            vGap: m.vGap,
            inset: inset,
            gridW: m.gridW,
            gridH: m.gridH
        )
    }
}

struct ForcePadCell: View {
    let pad: PadInfo
    let padWidth: CGFloat
    let padHeight: CGFloat
    let labelHeight: CGFloat
    let title: String
    let subtitle: String
    /// Strike intensity 0…1 from shared flashPad path (finger + Play/Loop).
    let flash: CGFloat
    let isActive: Bool
    let onDown: (CGFloat?) -> Void
    let onUp: () -> Void

    /// Vision A hard 4px corner (not soft 8.5% continuous).
    private var corner: CGFloat { PadTheme.padCornerRadius }

    /// 0…1 flash amount; held finger uses at least the held floor while down.
    private var t: CGFloat {
        let raw = min(1, max(0, flash))
        if isActive { return max(raw, PadHitLight.heldIntensity) }
        return raw
    }

    /// Settled held look (finger down after peak) vs peak / decay toward idle.
    private var useHeldLook: Bool {
        isActive && flash <= PadHitLight.heldIntensity + 0.02
    }

    private var faceFill: RadialGradient {
        let center: Color
        let mid: Color
        let edge: Color
        if useHeldLook {
            center = PadHitLight.mix(PadTheme.padRadialCenter, PadTheme.padHitRadialCenter, PadHitLight.heldIntensity)
            mid = PadHitLight.mix(PadTheme.padRadialMid, PadTheme.padHitRadialMid, PadHitLight.heldIntensity)
            edge = PadHitLight.mix(PadTheme.padRadialEdge, PadTheme.padHitRadialEdge, PadHitLight.heldIntensity)
        } else {
            center = PadHitLight.mix(PadTheme.padRadialCenter, PadTheme.padHitRadialCenter, t)
            mid = PadHitLight.mix(PadTheme.padRadialMid, PadTheme.padHitRadialMid, t)
            edge = PadHitLight.mix(PadTheme.padRadialEdge, PadTheme.padHitRadialEdge, t)
        }
        let y: CGFloat = useHeldLook || t > 0.2 ? 0.48 : 0.52
        return RadialGradient(
            colors: [center, mid, edge],
            center: UnitPoint(x: 0.5, y: y),
            startRadius: 0,
            endRadius: max(padWidth, padHeight) * 0.72
        )
    }

    private var rimColor: Color {
        if useHeldLook { return PadHitLight.heldStroke }
        return PadHitLight.mix(PadHitLight.idleStroke, PadHitLight.hitStroke, t)
    }

    private var rimWidth: CGFloat {
        if useHeldLook { return PadHitLight.heldStrokeWidth }
        return PadHitLight.idleStrokeWidth
            + (PadHitLight.hitStrokeWidth - PadHitLight.idleStrokeWidth) * t
    }

    private var innerRimOpacity: Double {
        if useHeldLook { return PadHitLight.heldInnerHighlightOpacity }
        return PadHitLight.innerHighlightOpacity * Double(t)
    }

    var body: some View {
        VStack(spacing: max(2, padHeight * 0.04)) {
            let shape = RoundedRectangle(cornerRadius: corner, style: .continuous)
            let expand = PadHitLight.haloClipExpand

            ZStack {
                // Recipe A++ soft outer perimeter halo (behind face).
                // CSS: 0 0 6px 2px rgba(245,232,255,0.50) + 0 0 10px 3px rgba(255,255,255,0.28)
                if t > PadHitLight.intensityEpsilon {
                    shape
                        .stroke(
                            PadHitLight.haloLilac.opacity(PadHitLight.haloLilacOpacity * Double(t)),
                            lineWidth: PadHitLight.haloLilacSpread * 2
                        )
                        .blur(radius: PadHitLight.haloLilacBlur)
                        .allowsHitTesting(false)

                    shape
                        .stroke(
                            Color.white.opacity(PadHitLight.haloWhiteOpacity * Double(t)),
                            lineWidth: PadHitLight.haloWhiteSpread * 2
                        )
                        .blur(radius: PadHitLight.haloWhiteBlur)
                        .allowsHitTesting(false)
                }

                // Vision A radial backlight face + A+ rim/inset.
                shape
                    .fill(faceFill)
                    .overlay(
                        // Soft face bevel from CSS inset highlights
                        shape
                            .strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
                            .blur(radius: 0.3)
                            .padding(0.5)
                            .opacity(t < 0.15 ? 1 : 0.35)
                    )
                    .overlay(
                        shape.strokeBorder(rimColor, lineWidth: rimWidth)
                    )
                    .overlay(
                        shape
                            .strokeBorder(Color.white.opacity(innerRimOpacity), lineWidth: PadHitLight.innerStrokeWidth)
                            .padding(PadHitLight.innerStrokeInset)
                    )
                    .clipShape(shape)
                    .shadow(color: .black.opacity(0.45), radius: 3, y: 2)

                ForceTouchPadRepresentable(
                    onDown: onDown,
                    onUp: onUp
                )
            }
            .frame(width: padWidth, height: padHeight)
            // Allow halo into the gap, then clip so it does not smear onto neighbor faces.
            .padding(expand)
            .clipped()
            .padding(-expand)
            .scaleEffect(isActive ? 0.97 : 1)
            .animation(.easeOut(duration: 0.08), value: isActive)

            // Beginner drum name under the pad — CSS `#dcdce2` weight ~600.
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: max(9, min(13, padHeight * 0.14)), weight: .semibold, design: .rounded))
                    .foregroundStyle(PadTheme.padLabel)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                Spacer(minLength: 2)
                Text(subtitle)
                    .font(.system(size: max(8, min(11, padHeight * 0.11)), weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.45))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(width: padWidth, height: labelHeight, alignment: .top)
            .allowsHitTesting(false)
        }
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

#if DEBUG
/// Tiny harness: idle / peak / held flash intensities (Recipe A++ rim + halo).
#Preview("Pad hit light phases") {
    HStack(spacing: 16) {
        ForEach([(CGFloat(0), false, "idle"), (1.0, false, "peak"), (0.55, true, "held")], id: \.2) { flash, active, label in
            VStack(spacing: 8) {
                ForcePadCell(
                    pad: PadInfo(id: 1, sampleName: "kick", nameKey: "pad.kick", categoryKey: "cat.kick"),
                    padWidth: 120,
                    padHeight: 86,
                    labelHeight: 16,
                    title: label,
                    subtitle: "rim",
                    flash: flash,
                    isActive: active,
                    onDown: { _ in },
                    onUp: {}
                )
                Text(label).font(.caption).foregroundStyle(.white.opacity(0.7))
            }
        }
    }
    .padding(24)
    .background(PadTheme.chassis)
}
#endif

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
