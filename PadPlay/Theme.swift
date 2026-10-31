import SwiftUI

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
    /// Legacy whole-face brighten — kept for aliases; hit look is rim-first via `PadHitLight`.
    static let padHit = Color(red: 220 / 255, green: 170 / 255, blue: 250 / 255)

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

/// Pad strike rim flash — PAD-HIT-LIGHT **v2.1 Recipe A+** (install default).
/// Single place to retune hex / widths / timing. Stroke/rim-first; fill secondary.
/// No outer bloom shadow. Shared by finger + Play/Loop note-on.
enum PadHitLight {
    // MARK: Fill (secondary — never the hero cue)

    /// Idle face — #CB85F3.
    static let idleFill = PadTheme.padFill
    /// Hit peak fill nudge — #D2A0F4 (restrained; rim stays primary).
    static let hitFill = Color(red: 210 / 255, green: 160 / 255, blue: 244 / 255)
    /// Finger-held fill — #D0A0F3.
    static let heldFill = Color(red: 208 / 255, green: 160 / 255, blue: 243 / 255)

    // MARK: Stroke / rim (primary strike cue) — Recipe A+

    /// Idle rim — #B15EEC.
    static let idleStroke = PadTheme.padEdge
    /// Hit peak outer rim — #FFFFFF.
    static let hitStroke = Color.white
    /// Held outer rim — #F5E8FF.
    static let heldStroke = Color(red: 245 / 255, green: 232 / 255, blue: 255 / 255)

    /// Idle stroke width — 1.5pt.
    static let idleStrokeWidth: CGFloat = 1.5
    /// Hit peak outer stroke — 3.0pt.
    static let hitStrokeWidth: CGFloat = 3.0
    /// Held outer stroke — ~2.5pt.
    static let heldStrokeWidth: CGFloat = 2.5

    /// Inset white ring at hit peak (α ≈ 0.55).
    static let innerHighlightOpacity: Double = 0.55
    /// Inset white ring while held (α ≈ 0.35).
    static let heldInnerHighlightOpacity: Double = 0.35
    /// Inset ring stroke width (~1.75pt).
    static let innerStrokeWidth: CGFloat = 1.75
    /// Inset from pad edge before drawing the inner ring (~2pt).
    static let innerStrokeInset: CGFloat = 2.0

    // MARK: Timing

    /// Attack 0→peak (~100ms) easeOut — edge arrives first.
    static let attackDuration: TimeInterval = 0.10
    /// Decay peak→idle (~250ms) easeOut.
    static let decayDuration: TimeInterval = 0.25
}
