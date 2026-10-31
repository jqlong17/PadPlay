import SwiftUI
import UIKit

/// Visual tokens locked from preview mock + vision patch A CSS (`patch-vision-A.css`).
/// Source of truth is the designer web baseline — not the App Icon column gradient.
enum PadTheme {
    // Chassis
    static let chassis = Color(red: 31 / 255, green: 31 / 255, blue: 33 / 255) // #1F1F21
    static let chassisEdge = Color(red: 0.16, green: 0.15, blue: 0.17)
    static let chassisWell = Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255) // #1C1C1E gap
    static let metal = Color(red: 0.22, green: 0.21, blue: 0.24)
    static let metalHighlight = Color(red: 0.38, green: 0.37, blue: 0.40)

    static let label = Color.white
    static let dimLabel = Color.white.opacity(0.55)
    /// Knob / pad caption — CSS `#e0e0e5` / `#dcdce2`.
    static let chromeCaption = Color(red: 224 / 255, green: 224 / 255, blue: 229 / 255)
    static let padLabel = Color(red: 220 / 255, green: 220 / 255, blue: 226 / 255) // #dcdce2

    /// Uniform pad face base — #CB85F3 (NOT left→right columns). Idle face uses radial backlight.
    static let padFill = Color(red: 203 / 255, green: 133 / 255, blue: 243 / 255)
    /// Vision A idle edge — #9B3FE0.
    static let padEdge = Color(red: 155 / 255, green: 63 / 255, blue: 224 / 255)
    /// Legacy alias — hit look is rim-first via `PadHitLight`.
    static let padHit = Color(red: 210 / 255, green: 160 / 255, blue: 244 / 255)

    // Idle radial backlight — CSS `radial-gradient(circle at 50% 52%, #e5aaff, #b24bf7, #8d27d9)`
    static let padRadialCenter = Color(red: 229 / 255, green: 170 / 255, blue: 255 / 255)
    static let padRadialMid = Color(red: 178 / 255, green: 75 / 255, blue: 247 / 255)
    static let padRadialEdge = Color(red: 141 / 255, green: 39 / 255, blue: 217 / 255)

    // Hit radial lift — CSS `#f0d0ff → #c56af8 → #a03ae8`
    static let padHitRadialCenter = Color(red: 240 / 255, green: 208 / 255, blue: 255 / 255)
    static let padHitRadialMid = Color(red: 197 / 255, green: 106 / 255, blue: 248 / 255)
    static let padHitRadialEdge = Color(red: 160 / 255, green: 58 / 255, blue: 232 / 255)

    // Legacy aliases used by leftover chrome; keep non-neon.
    static let purple = padFill
    static let purpleGlow = Color.white.opacity(0.85)
    static let purpleCore = padFill
    static let purpleEdge = padEdge
    static let purpleHit = padHit

    static let accentRed = Color(red: 1.0, green: 59 / 255, blue: 48 / 255) // ~#FF3B30
    static let knobCap = Color(red: 0.11, green: 0.10, blue: 0.12)
    static let brand = Color.white.opacity(0.95)

    /// Pad face width ÷ height from mock (~191×138).
    static let padAspect: CGFloat = 1.384

    /// Vision A hard hardware corner — CSS `border-radius: 4px` (was 8.5% soft).
    static let padCornerRadius: CGFloat = 4

    /// Recessed ring / chrome face colors (vision A inset shadows).
    static let recessDark = Color(red: 15 / 255, green: 15 / 255, blue: 18 / 255) // #0f0f12
    static let recessButtonDark = Color(red: 14 / 255, green: 14 / 255, blue: 17 / 255) // #0e0e11
    static let roundButtonFace = Color(red: 28 / 255, green: 28 / 255, blue: 32 / 255) // #1c1c20
    static let roundButtonFaceActive = Color(red: 40 / 255, green: 40 / 255, blue: 46 / 255) // #28282e
    static let roundButtonIdleRing = Color(red: 69 / 255, green: 69 / 255, blue: 74 / 255) // #45454a
}

/// Left-chrome selected / idle ring — white stroke only when active, no fill-white face.
enum ChromeRing {
    /// CSS round-btn border 1.5px.
    static let idleWidth: CGFloat = 1.5
    /// Selected keeps same stroke weight — brighter white ring only.
    static let activeWidth: CGFloat = 1.5
    static let idleColor = PadTheme.roundButtonIdleRing
    static let activeColor = Color.white.opacity(0.75)
    /// Transport caption under icon, if ever shown (≤10pt gray).
    static let transportCaptionSize: CGFloat = 10
    static let transportCaptionColor = Color.white.opacity(0.45)
}

/// Vision A left-chrome metrics — CSS vars at scale 1 map 1:1 to pt.
/// `--cluster-w` 200 = knobs `84×2+32` = buttons `56×3+16×2`.
struct LeftChromeMetrics {
    /// Designer reference left column width (`--left-w`).
    static let refWidth: CGFloat = 340
    /// Approximate stacked height at scale 1.0 (brand→transport, top-aligned).
    static let refHeight: CGFloat = 560
    /// `--cluster-w`.
    static let clusterWidthBase: CGFloat = 200
    /// `--gear-d` (lives on pad-stage top bar, not left chrome).
    static let gearDiameterBase: CGFloat = 34

    let width: CGFloat
    let height: CGFloat

    var scale: CGFloat {
        let byWidth = width / Self.refWidth
        let byHeight = height / Self.refHeight
        // Keep proportions; phone landscape shrinks, iPad can sit near 1.0.
        return min(1.05, max(0.58, min(byWidth, byHeight)))
    }

    // Brand — `--title-size` 22 / `--status-size` 12 / `--brand-bottom` 20
    var titleSize: CGFloat { 22 * scale }
    var statusSize: CGFloat { 12 * scale }
    var brandBottom: CGFloat { 20 * scale }

    // Knobs — `--knob-d` 84, `--knob-col` 32, `--knob-row` 14
    var knobDiameter: CGFloat { 84 * scale }
    var knobColGap: CGFloat { 32 * scale }
    var knobRowGap: CGFloat { 14 * scale }
    var knobGridWidth: CGFloat { knobDiameter * 2 + knobColGap }

    // Function + transport — `--btn-d` 56, `--btn-col` 16, `--btn-row` 14, `--btn-slot` 56
    var buttonDiameter: CGFloat { 56 * scale }
    var colGap: CGFloat { 16 * scale }
    var rowGap: CGFloat { 14 * scale }
    /// Slot equals face diameter (recessed ring is inset, not an outer mount).
    var buttonSlot: CGFloat { buttonDiameter }
    /// Shared island width — `--cluster-w`.
    var clusterWidth: CGFloat { buttonSlot * 3 + colGap * 2 }
    var threeColWidth: CGFloat { clusterWidth }

    /// Fixed section gap brand→knobs→grids→transport — `--section-gap` 26.
    /// No `space-between` stretch.
    var sectionGap: CGFloat { 26 * scale }

    // Settings gear on pad-stage top-right — `--gear-d` 34
    var gearDiameter: CGFloat { Self.gearDiameterBase * scale }

    /// Left column top inset (CSS `.left { padding-top: 8px }`).
    var leftTopPadding: CGFloat { 8 * scale }
}

/// Pad strike rim flash — PAD-HIT-LIGHT **v2.2 Recipe A++** (install default).
/// A+ rim + inset, plus soft outer perimeter halo (CSS box-shadow parity).
/// Eye cue is bright rim + tight halo; fill only a slight lift.
/// Animate via published flash intensity 0…1 (exponential decay). Easy to retune here.
enum PadHitLight {
    // MARK: Fill (secondary — slight lift only; face uses radial backlight in PadGridView)

    /// Idle — #CB85F3.
    static let idleFill = PadTheme.padFill
    /// Hit peak fill nudge — #D2A0F4.
    static let hitFill = Color(red: 210 / 255, green: 160 / 255, blue: 244 / 255)
    /// Held fill (finger only) — #D0A0F3.
    static let heldFill = Color(red: 208 / 255, green: 160 / 255, blue: 243 / 255)

    // MARK: Stroke / rim (primary) — Recipe A+

    /// Idle thin stroke — vision A `#9B3FE0` via `PadTheme.padEdge`.
    static let idleStroke = PadTheme.padEdge
    /// Hit peak outer stroke — pure #FFFFFF 3.0pt.
    static let hitStroke = Color.white
    /// Held outer stroke — #F5E8FF ~2.5pt.
    static let heldStroke = Color(red: 245 / 255, green: 232 / 255, blue: 255 / 255)

    static let idleStrokeWidth: CGFloat = 1.5
    static let hitStrokeWidth: CGFloat = 3.0
    static let heldStrokeWidth: CGFloat = 2.5

    /// Inset white ring at hit peak (α ≈ 0.55).
    static let innerHighlightOpacity: Double = 0.55
    /// Inset white ring while held (α ≈ 0.35).
    static let heldInnerHighlightOpacity: Double = 0.35
    /// Inset ring stroke ~1.75pt, clipped inside pad.
    static let innerStrokeWidth: CGFloat = 1.75
    static let innerStrokeInset: CGFloat = 2.0

    // MARK: Soft outer halo — Recipe A++ (CSS box-shadow parity)
    //
    // Peak CSS:
    //   0 0 6px 2px rgba(245,232,255,0.50)
    //   0 0 10px 3px rgba(255,255,255,0.28)
    // Drawn as stroked rings + blur (perimeter only — not a filled pad bloom).

    /// Lilac halo — #F5E8FF.
    static let haloLilac = Color(red: 245 / 255, green: 232 / 255, blue: 255 / 255)
    /// CSS layer 1 peak α.
    static let haloLilacOpacity: Double = 0.50
    /// CSS blur ≈ 6px.
    static let haloLilacBlur: CGFloat = 6
    /// CSS spread ≈ 2px → stroke half-width each side.
    static let haloLilacSpread: CGFloat = 2

    /// CSS layer 2 peak α (white).
    static let haloWhiteOpacity: Double = 0.28
    /// CSS blur ≈ 10px.
    static let haloWhiteBlur: CGFloat = 10
    /// CSS spread ≈ 3px.
    static let haloWhiteSpread: CGFloat = 3

    /// Clip expanded bounds so halo does not smear into neighbor pads.
    static let haloClipExpand: CGFloat = 8

    // MARK: Intensity / timing

    /// Finger-held floor on the 0…1 flash scalar (after peak settles).
    static let heldIntensity: CGFloat = 0.55
    /// Attack snap window (visual easeOut on rising edge if needed).
    static let attackDuration: TimeInterval = 0.10
    /// Target decay window ~250ms (within 220–300ms).
    static let decayDuration: TimeInterval = 0.25
    /// Exponential decay rate: intensity *= exp(-dt * decayRate).
    /// Chosen so ~250ms lands near ~0.02 (reads as idle).
    static let decayRate: Double = 15.6
    /// Drop keys below this.
    static let intensityEpsilon: CGFloat = 0.02

    /// Linear mix in sRGB for stroke/fill interpolation by flash intensity.
    static func mix(_ a: Color, _ b: Color, _ t: CGFloat) -> Color {
        let t = min(1, max(0, t))
        let ua = UIColor(a)
        let ub = UIColor(b)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        ua.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        ub.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red: r1 + (r2 - r1) * t,
            green: g1 + (g2 - g1) * t,
            blue: b1 + (b2 - b1) * t,
            opacity: a1 + (a2 - a1) * t
        )
    }
}
