import SwiftUI
import UIKit

/// Visual tokens locked from preview mock `ref-mock.jpg` (TOKENS-from-mock).
/// Source of truth is the in-app preview — not the App Icon column gradient.
enum PadTheme {
    // Chassis
    static let chassis = Color(red: 31 / 255, green: 31 / 255, blue: 33 / 255) // #1F1F21
    static let chassisEdge = Color(red: 0.16, green: 0.15, blue: 0.17)
    static let chassisWell = Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255) // #1C1C1E gap
    static let metal = Color(red: 0.22, green: 0.21, blue: 0.24)
    static let metalHighlight = Color(red: 0.38, green: 0.37, blue: 0.40)

    static let label = Color.white
    static let dimLabel = Color.white.opacity(0.55)

    /// Uniform pad face — #CB85F3 (NOT left→right columns).
    static let padFill = Color(red: 203 / 255, green: 133 / 255, blue: 243 / 255)
    /// Optional soft edge — #B15EEC; no neon glow.
    static let padEdge = Color(red: 177 / 255, green: 94 / 255, blue: 236 / 255)
    /// Legacy alias — hit look is rim-first via `PadHitLight`.
    static let padHit = Color(red: 210 / 255, green: 160 / 255, blue: 244 / 255)

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
}

/// Pad strike rim flash — rim-first (MPC / Launchpad style).
/// Colors/timing aligned with `Docs/PAD-HIT-LIGHT.md` + research: eye cue is bright rim,
/// fill only a slight lift. No outer bloom / large shadowRadius.
/// Animate via published flash intensity 0…1 (exponential decay). Easy to retune here.
enum PadHitLight {
    // MARK: Fill (secondary — slight lift only)

    /// Idle — #CB85F3.
    static let idleFill = PadTheme.padFill
    /// Peak fill nudge — slight lift only (not whole-pad bleach).
    static let hitFill = Color(red: 210 / 255, green: 160 / 255, blue: 244 / 255) // #D2A0F4
    /// Held fill while finger down — #E8C8FC (PAD-HIT-LIGHT).
    static let heldFill = Color(red: 232 / 255, green: 200 / 255, blue: 252 / 255)

    // MARK: Stroke / rim (primary)

    /// Idle thin stroke — #B15EEC.
    static let idleStroke = PadTheme.padEdge
    /// Hit thick near-white stroke.
    static let hitStroke = Color(red: 245 / 255, green: 232 / 255, blue: 255 / 255) // #F5E8FF
    /// Held edge — #D9A8F5.
    static let heldStroke = Color(red: 217 / 255, green: 168 / 255, blue: 245 / 255)

    static let idleStrokeWidth: CGFloat = 1.5
    static let hitStrokeWidth: CGFloat = 3.0
    static let heldStrokeWidth: CGFloat = 2.25

    /// Optional inner white stroke at peak (α ≈ 0.35).
    static let innerHighlightOpacity: Double = 0.35
    static let innerStrokeWidth: CGFloat = 1.5
    static let innerStrokeInset: CGFloat = 1.75

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
