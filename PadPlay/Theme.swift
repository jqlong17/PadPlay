import SwiftUI
import UIKit

extension Color {
    /// Designer hex helper — beauty v2 / VISUAL-P0 / vision tokens (`#RRGGBB`).
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

/// Visual tokens — layout geometry locked (TOKEN-MAP / LeftChromeMetrics).
/// Face materials: **beauty v2** (supersedes VISUAL-P0 candy pad / outer-fog LED).
/// Hit flash stays Recipe A++ via `PadHitLight`.
enum PadTheme {
    // MARK: Chassis — beauty v2 deeper gradient `#121214 → #0E0E11 → #0A0A0C`

    static let chassisTop = Color(hex: 0x121214)
    static let chassisMid = Color(hex: 0x0E0E11)
    static let chassisBottom = Color(hex: 0x0A0A0C)
    /// Flat fallback / preview fill (mid band).
    static let chassis = chassisMid
    static let chassisEdge = Color(hex: 0x0A0A0C)
    /// Pad-stage well behind the 4×4 — near chassis mid.
    static let chassisWell = Color(hex: 0x0E0E11)
    static let metal = Color(red: 0.22, green: 0.21, blue: 0.24)
    static let metalHighlight = Color(red: 0.38, green: 0.37, blue: 0.40)

    // MARK: Silkscreen labels — `#8E8E98` / `#71717A`; active `#F2ECFF`

    static let label = Color(hex: 0xE4E4E7)
    static let dimLabel = Color(hex: 0x71717A)
    /// Knob / pad caption — silkscreen `#8E8E98`.
    static let chromeCaption = Color(hex: 0x8E8E98)
    static let padLabel = Color(hex: 0x8E8E98)
    static let padLabelSub = Color(hex: 0x71717A)
    /// Active chrome caption (selected round btn).
    static let chromeCaptionActive = Color(hex: 0xF2ECFF)
    /// Brand wordmark — `#E4E4E7`.
    static let brand = Color(hex: 0xE4E4E7)
    /// Status line under brand — `#71717A`.
    static let status = Color(hex: 0x71717A)

    // MARK: Beauty v2 pad face (idle — charcoal + purple halo ≈0.16)

    /// Idle face base — `#1C1C22`.
    static let padFace = Color(hex: 0x1C1C22)
    /// Purple halo center — `#7C3AED` @ 0.16 (ellipse soft matte).
    static let padHalo = Color(hex: 0x7C3AED, alpha: 0.16)
    /// Purple halo mid falloff — `#7C3AED` @ 0.08.
    static let padHaloMid = Color(hex: 0x7C3AED, alpha: 0.08)
    /// Well / embedded ring — `#070709` 1.5pt.
    static let padWell = Color(hex: 0x070709)
    /// Thin face border — `#0A0A0C`.
    static let padBorder = Color(hex: 0x0A0A0C)
    /// Embedded groove stroke alias (well).
    static let padGrooveStroke = padWell

    // Legacy aliases — map away from P0 candy radial so leftover refs stay charcoal.
    static let padCenter = padFace
    static let padRadialMid = padFace
    static let padEdge = padFace
    static let padFill = padFace
    static let padRadialCenter = padFace
    static let padRadialEdge = padFace
    /// Legacy alias — hit look is rim-first via `PadHitLight`.
    static let padHit = Color(hex: 0xD2A0F4)

    // Hit radial lift (Recipe A++ face lift layered on beauty-v2 charcoal)
    static let padHitRadialCenter = Color(hex: 0xF5E8FF)
    static let padHitRadialMid = Color(hex: 0xD2A0F4)
    static let padHitRadialEdge = Color(hex: 0xA855F7, alpha: 0.55)

    // Legacy aliases used by leftover chrome; keep non-neon.
    static let purple = padFill
    static let purpleGlow = Color.white.opacity(0.85)
    static let purpleCore = padFill
    static let purpleEdge = padEdge
    static let purpleHit = padHit

    /// Roll / record accent — beauty v2 quieter danger `#D9534F`.
    static let accentRed = Color(hex: 0xD9534F)
    static let knobCap = Color(hex: 0x141416)
    /// Knob track groove — `#0A0A0D`.
    static let knobTrackGroove = Color(hex: 0x0A0A0D)
    /// Knob value arc — quieter `#6D28D9`.
    static let knobArc = Color(hex: 0x6D28D9)
    /// Knob cap top / bottom gradient.
    static let knobCapTop = Color(hex: 0x2A2A2E)
    static let knobCapBottom = Color(hex: 0x141416)

    /// Pad face width ÷ height from mock (~191×138).
    static let padAspect: CGFloat = 1.384

    /// Vision A hard hardware corner — CSS `border-radius: 4px` (geometry lock — do not change).
    static let padCornerRadius: CGFloat = 4

    /// Recessed ring / chrome face colors (beauty v2).
    static let recessDark = Color(hex: 0x0F0F12)
    static let recessButtonDark = Color(hex: 0x0E0E11)
    /// Round idle face — `#18181D`.
    static let roundButtonFace = Color(hex: 0x18181D)
    /// Round selected face — `#1A1A20`.
    static let roundButtonFaceActive = Color(hex: 0x1A1A20)
    /// Round danger selected face — `#1A1416`.
    static let roundButtonFaceDangerActive = Color(hex: 0x1A1416)
    /// Inset light-guide purple — `#8F5BFF`.
    static let roundButtonGuidePurple = Color(hex: 0x8F5BFF)
    /// Inset light-guide danger — `#D9534F`.
    static let roundButtonGuideRed = Color(hex: 0xD9534F)
    static let roundButtonIdleRing = Color.white.opacity(0.035)
    /// Well ring shared by pads / round btns / gear.
    static let wellRing = Color(hex: 0x070709)
}

/// Transport caption tokens (LED cavity for buttons lives in RoundButtonView / beauty v2).
enum ChromeRing {
    static let idleWidth: CGFloat = 1.0
    static let activeWidth: CGFloat = 1.5
    static let idleColor = PadTheme.roundButtonIdleRing
    /// Selected guide (inset) — beauty v2 `#8F5BFF` (not outer fog).
    static let activeColor = PadTheme.roundButtonGuidePurple
    /// Transport caption under icon, if ever shown (≤10pt gray).
    static let transportCaptionSize: CGFloat = 10
    static let transportCaptionColor = PadTheme.dimLabel
}

/// Vision A left-chrome metrics — CSS vars at scale 1 map 1:1 to pt.
/// `--cluster-w` 200 = knobs `84×2+32` = buttons `56×3+16×2`.
/// Geometry frozen — beauty v2 does not touch these sizes/gaps/alignment.
struct LeftChromeMetrics {
    /// Designer reference left column width (`--left-w`).
    static let refWidth: CGFloat = 340
    /// Approximate stacked height at scale 1.0 (brand→transport, top-aligned).
    static let refHeight: CGFloat = 560
    /// `--cluster-w`.
    static let clusterWidthBase: CGFloat = 200
    /// `--gear-d` (chassis top-trailing overlay, not left chrome).
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

    // Knobs — `--knob-d` 84, `--knob-col` 32, `--knob-row` 10
    var knobDiameter: CGFloat { 84 * scale }
    var knobColGap: CGFloat { 32 * scale }
    var knobRowGap: CGFloat { 10 * scale }
    var knobGridWidth: CGFloat { knobDiameter * 2 + knobColGap }

    // Function + transport — `--btn-d` 56, `--btn-col` 16, `--btn-row` 10, `--btn-slot` 56
    var buttonDiameter: CGFloat { 56 * scale }
    var colGap: CGFloat { 16 * scale }
    var rowGap: CGFloat { 10 * scale }
    /// Slot equals face diameter (recessed ring is inset, not an outer mount).
    var buttonSlot: CGFloat { buttonDiameter }
    /// Shared island width — `--cluster-w`.
    var clusterWidth: CGFloat { buttonSlot * 3 + colGap * 2 }
    var threeColWidth: CGFloat { clusterWidth }

    /// Fixed section gap knobs→grids→transport — `--section-gap` 18.
    /// No `space-between` stretch.
    var sectionGap: CGFloat { 18 * scale }

    // Settings gear on chassis top-right — `--gear-d` 34 (fixed, not scaled)
    var gearDiameter: CGFloat { Self.gearDiameterBase }
    /// Design inset from chassis top / trailing edges (not pad-stage).
    static let gearInset: CGFloat = 18

    /// Shared top axis for knob1 face and pad13 face in chassis-root coordinates (pt).
    /// Locked to y≈100–107 so left chrome and pads sink together; Δ(knobTop, padTop) ≤ 3.
    static let sharedFaceTop: CGFloat = 104

    /// Left column top inset (CSS `.left { padding-top: 8px }`) — brand only;
    /// knobs lock to `sharedFaceTop` instead of stacking tightly under brand.
    var leftTopPadding: CGFloat { 8 * scale }
}

/// Pad strike rim flash — PAD-HIT-LIGHT **v2.2 Recipe A++** (install default).
/// Layers on beauty-v2 charcoal idle face. A+ rim + inset + soft outer halo.
/// Eye cue is bright rim + tight halo; fill lifts charcoal → lilac.
/// Animate via published flash intensity 0…1 (exponential decay). Easy to retune here.
enum PadHitLight {
    // MARK: Fill (secondary — charcoal idle; lilac lift on hit)

    /// Idle — beauty v2 charcoal face.
    static let idleFill = PadTheme.padFace
    /// Hit peak fill nudge — #D2A0F4.
    static let hitFill = Color(hex: 0xD2A0F4)
    /// Held fill (finger only) — #D0A0F3.
    static let heldFill = Color(hex: 0xD0A0F3)

    // MARK: Stroke / rim (primary) — Recipe A+ on beauty-v2 well

    /// Idle well stroke — `#070709` 1.5pt (face always draws well; flash mixes toward white).
    static let idleStroke = PadTheme.padWell
    /// Hit peak outer stroke — pure #FFFFFF 3.0pt.
    static let hitStroke = Color.white
    /// Held outer stroke — #F5E8FF ~2.5pt.
    static let heldStroke = Color(hex: 0xF5E8FF)

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
    static let haloLilac = Color(hex: 0xF5E8FF)
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
