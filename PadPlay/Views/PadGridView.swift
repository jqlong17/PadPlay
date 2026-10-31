import SwiftUI
import UIKit

/// 4×4 pad stage — beauty v2 charcoal idle + wells; vision A hard 4px corners (geometry lock).
/// Labels under each pad (never inside the face). Hit = Recipe A++ rim + soft outer halo.
struct PadGridView: View {
    @EnvironmentObject private var controller: PadController
    @EnvironmentObject private var settings: AppSettings

    /// `.top` pins pad13 face to the top of the available rect (shared knob/pad axis).
    var verticalAlignment: VerticalAlignment = .center

    var body: some View {
        GeometryReader { geo in
            let pinTop = verticalAlignment == .top
            let layout = Self.layout(in: geo.size, pinTopFace: pinTop)
            let rows = controller.gridRowsTopFirst
            let frameAlign: Alignment = pinTop ? .top : .center

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
                .padding(.leading, layout.inset)
                .padding(.trailing, layout.inset)
                .padding(.bottom, layout.inset)
                .padding(.top, layout.topInset)
            }
            .frame(width: layout.gridW, height: layout.gridH)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: frameAlign)
        }
    }

    /// Fit 4×4 horizontal pads + under-pad labels into the available rectangle.
    /// Shared with calibration wireframe so reported pad frames match live layout.
    /// When `pinTopFace` is true, top pad faces sit at y=0 of `size` (no top inset).
    static func layout(in size: CGSize, pinTopFace: Bool = false) -> (
        padW: CGFloat, padH: CGFloat, labelH: CGFloat, cellH: CGFloat,
        hGap: CGFloat, vGap: CGFloat, inset: CGFloat, topInset: CGFloat,
        gridW: CGFloat, gridH: CGFloat
    ) {
        let aspect = PadTheme.padAspect
        let inset: CGFloat = max(4, min(10, min(size.width, size.height) * 0.012))
        let topInset: CGFloat = pinTopFace ? 0 : inset
        let availW = max(1, size.width - inset * 2)
        let availH = max(1, size.height - topInset - inset)

        // Mock: h-gap ≈ 14% of pad width; v-gap carries the label band.
        func metrics(padW: CGFloat) -> (padH: CGFloat, hGap: CGFloat, labelH: CGFloat, vGap: CGFloat, cellH: CGFloat, gridW: CGFloat, gridH: CGFloat) {
            let padH = padW / aspect
            let hGap = padW * 0.14
            let labelH = max(12, min(22, padH * 0.18))
            let labelPad: CGFloat = max(2, padH * 0.04)
            let vGap = max(4, labelPad) // spacing between rows (label sits in cell)
            let cellH = padH + labelPad + labelH
            let gridW = 4 * padW + 3 * hGap + inset * 2
            let gridH = 4 * cellH + 3 * vGap + topInset + inset
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
            topInset: topInset,
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

    /// Vision A / beauty v2 hard 4px corner (geometry lock — not soft 8.5% continuous).
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

    /// Recipe A++ hit / held rim (layered on beauty-v2 well — not a cheap white idle ring).
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

    /// Hit face lift opacity — charcoal → lilac/white (sheen fades under hit).
    private var hitLiftOpacity: Double {
        if useHeldLook { return 0.55 }
        return 0.92 * Double(t)
    }

    /// Soft matte sheen fades when flashing (CSS `.pad.hit::before { opacity: 0.15 }`).
    private var sheenOpacity: Double {
        if t <= PadHitLight.intensityEpsilon { return 1.0 }
        return 0.15 + 0.85 * (1.0 - Double(t))
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
    }

    private var maxDim: CGFloat { max(padWidth, padHeight) }

    private var isFlashing: Bool { t > PadHitLight.intensityEpsilon }

    private var showHitRim: Bool { isFlashing || isActive }

    var body: some View {
        VStack(spacing: max(2, padHeight * 0.04)) {
            padFaceStack
                .frame(width: padWidth, height: padHeight)
                // Allow halo into the gap, then clip so it does not smear onto neighbor faces.
                .padding(PadHitLight.haloClipExpand)
                .clipped()
                .padding(-PadHitLight.haloClipExpand)
                .scaleEffect(isActive ? 0.97 : 1)
                .animation(.easeOut(duration: 0.08), value: isActive)

            padLabels
        }
    }

    // MARK: - Face stack (split so the type-checker finishes in reasonable time)

    private var padFaceStack: some View {
        ZStack {
            outerHitHalo
            beautyV2FaceWithHit
            ForceTouchPadRepresentable(onDown: onDown, onUp: onUp)
        }
    }

    /// Recipe A++ soft outer perimeter halo (behind face).
    /// Soft fill ring + lilac/white strokes on an expanded path so the gutter
    /// bloom reaches mock luminance; face drop shadow fades with `t`.
    @ViewBuilder
    private var outerHitHalo: some View {
        if isFlashing {
            let expand = PadHitLight.haloPathExpand
            let ring = PadHitLight.haloRingWidth
            // Annulus outer edge = path expand + half ring, so the band sits in the gutter.
            let ringOuter = expand + ring * 0.5
            let strokeShape = RoundedRectangle(
                cornerRadius: corner + expand,
                style: .continuous
            )
            let strokeW = padWidth + expand * 2
            let strokeH = padHeight + expand * 2

            // Primary luminance: lilac annulus in the gutter (not a full-pad bloom).
            softHaloFillRing(ringOuter: ringOuter)

            strokeShape
                .stroke(
                    PadHitLight.haloLilac.opacity(PadHitLight.haloLilacOpacity * Double(t)),
                    lineWidth: PadHitLight.haloLilacSpread * 2
                )
                .frame(width: strokeW, height: strokeH)
                .blur(radius: PadHitLight.haloLilacBlur)
                .allowsHitTesting(false)

            strokeShape
                .stroke(
                    Color.white.opacity(PadHitLight.haloWhiteOpacity * Double(t)),
                    lineWidth: PadHitLight.haloWhiteSpread * 2
                )
                .frame(width: strokeW, height: strokeH)
                .blur(radius: PadHitLight.haloWhiteBlur)
                .allowsHitTesting(false)
        }
    }

    /// Lilac soft fill ring punched out over the pad face, then blurred.
    /// Outer edge at `ringOuter`; hole matches the face so only the perimeter band glows.
    private func softHaloFillRing(ringOuter: CGFloat) -> some View {
        let outerW = padWidth + ringOuter * 2
        let outerH = padHeight + ringOuter * 2
        let outerCorner = corner + ringOuter

        return ZStack {
            RoundedRectangle(cornerRadius: outerCorner, style: .continuous)
                .fill(PadHitLight.haloLilac.opacity(PadHitLight.haloRingOpacity * Double(t)))
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .frame(width: padWidth, height: padHeight)
                .blendMode(.destinationOut)
        }
        .compositingGroup()
        .frame(width: outerW, height: outerH)
        .blur(radius: PadHitLight.haloRingBlur)
        .allowsHitTesting(false)
    }

    /// Beauty v2 idle materials + Recipe A++ hit overlays (same look as before; layered helpers).
    private var beautyV2FaceWithHit: some View {
        beautyV2IdleFace
            .overlay(hitLiftOverlay)
            .overlay(hitRimOverlay)
            .overlay(innerHighlightOverlay)
            .clipShape(shape)
            // Idle drop shadow; fades out on hit so it does not crush the outer halo.
            .shadow(
                color: Color.black.opacity(0.55 * (1.0 - Double(t))),
                radius: 2.5,
                x: 0,
                y: 2
            )
    }

    /// Idle: charcoal + purple halo ≈0.16 + sheen + wells (beauty v2 Must checklist).
    private var beautyV2IdleFace: some View {
        shape
            .fill(PadTheme.padFace)
            .overlay(idlePurpleHalo)
            .overlay(idleSheen)
            .overlay(idleTopBevel)
            .overlay(idleBottomShade)
            .overlay(shape.strokeBorder(PadTheme.padBorder, lineWidth: 1.0))
            .overlay(shape.strokeBorder(PadTheme.padWell, lineWidth: 1.5))
            .overlay(idleMicroRim)
    }

    private var idlePurpleHalo: some View {
        shape.fill(
            RadialGradient(
                stops: [
                    .init(color: PadTheme.padHalo, location: 0.0),
                    .init(color: PadTheme.padHaloMid, location: 0.42),
                    .init(color: Color.clear, location: 0.72),
                ],
                center: UnitPoint(x: 0.5, y: 0.40),
                startRadius: 0,
                endRadius: maxDim * 0.55
            )
        )
    }

    private var idleSheen: some View {
        shape
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: Color.white.opacity(0.055), location: 0.0),
                        .init(color: Color.white.opacity(0.01), location: 0.28),
                        .init(color: Color.black.opacity(0.35), location: 1.0),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .opacity(sheenOpacity)
    }

    private var idleTopBevel: some View {
        shape
            .stroke(Color.white.opacity(0.07), lineWidth: 1.0)
            .offset(y: 0.5)
            .blur(radius: 0.3)
            .mask(
                shape.fill(
                    LinearGradient(
                        colors: [.black, .clear],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.22)
                    )
                )
            )
    }

    private var idleBottomShade: some View {
        shape
            .stroke(Color.black.opacity(0.72), lineWidth: 3.0)
            .offset(y: -1.5)
            .blur(radius: 1.5)
            .mask(
                shape.fill(
                    LinearGradient(
                        colors: [.black, .clear],
                        startPoint: .bottom,
                        endPoint: UnitPoint(x: 0.5, y: 0.68)
                    )
                )
            )
    }

    private var idleMicroRim: some View {
        shape
            .stroke(Color.white.opacity(0.04), lineWidth: 1.0)
            .offset(y: 1.0)
            .mask(
                shape.fill(
                    LinearGradient(
                        colors: [.black, .clear],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.35)
                    )
                )
            )
    }

    /// Recipe A++ lilac/white face lift (charcoal → lilac peak).
    @ViewBuilder
    private var hitLiftOverlay: some View {
        if isFlashing {
            shape
                .fill(
                    RadialGradient(
                        stops: [
                            .init(color: PadTheme.padHitRadialCenter, location: 0.0),
                            .init(color: PadTheme.padHitRadialMid, location: 0.45),
                            .init(color: PadTheme.padHitRadialEdge, location: 1.0),
                        ],
                        center: UnitPoint(x: 0.5, y: 0.42),
                        startRadius: 0,
                        endRadius: maxDim * 0.70
                    )
                )
                .opacity(hitLiftOpacity)
        }
    }

    /// Recipe A++ hit / held outer rim (white ~3pt at peak).
    @ViewBuilder
    private var hitRimOverlay: some View {
        if showHitRim {
            shape.strokeBorder(rimColor, lineWidth: rimWidth)
        }
    }

    /// Recipe A++ inset white highlight α≈0.55 at peak.
    private var innerHighlightOverlay: some View {
        shape
            .strokeBorder(Color.white.opacity(innerRimOpacity), lineWidth: PadHitLight.innerStrokeWidth)
            .padding(PadHitLight.innerStrokeInset)
    }

    /// Silkscreen labels — `#8E8E98` / `#71717A`.
    private var padLabels: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: max(9, min(13, padHeight * 0.14)), weight: .medium, design: .rounded))
                .foregroundStyle(PadTheme.padLabel)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
            Spacer(minLength: 2)
            Text(subtitle)
                .font(.system(size: max(8, min(11, padHeight * 0.11)), weight: .regular, design: .rounded))
                .foregroundStyle(PadTheme.padLabelSub)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(width: padWidth, height: labelHeight, alignment: .top)
        .allowsHitTesting(false)
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
/// Tiny harness: idle / peak / held flash intensities (beauty v2 + Recipe A++).
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
