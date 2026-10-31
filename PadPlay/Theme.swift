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
    /// Hit face — mirrors `PadHitLight.hitFill` (#F2DEFF).
    static let padHit = Color(red: 242 / 255, green: 222 / 255, blue: 255 / 255)

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

/// Pad strike flash — colors/timing from `Docs/PAD-HIT-LIGHT.md` (source of truth).
/// Single place to retune. Shared by finger + Play/Loop note-on. No outer purple bloom.
enum PadHitLight {
    // MARK: Fill

    /// Idle — #CB85F3.
    static let idleFill = PadTheme.padFill
    /// Hit peak — #F2DEFF.
    static let hitFill = Color(red: 242 / 255, green: 222 / 255, blue: 255 / 255)
    /// Held (finger down) — #E8C8FC.
    static let heldFill = Color(red: 232 / 255, green: 200 / 255, blue: 252 / 255)

    // MARK: Edge

    /// Idle edge — #B15EEC.
    static let idleStroke = PadTheme.padEdge
    /// Hit peak edge — #E8C4FF.
    static let hitStroke = Color(red: 232 / 255, green: 196 / 255, blue: 255 / 255)
    /// Held edge — #D9A8F5.
    static let heldStroke = Color(red: 217 / 255, green: 168 / 255, blue: 245 / 255)

    /// Idle / hit / held stroke widths (spec does not lock pt; keep modest, no outer bloom).
    static let idleStrokeWidth: CGFloat = 1.5
    static let hitStrokeWidth: CGFloat = 2.5
    static let heldStrokeWidth: CGFloat = 2.0

    /// Optional center highlight at hit peak (white 18% → 0).
    static let centerHighlightOpacity: Double = 0.18

    // MARK: Timing (spec: attack ~90–120ms, decay ~220–300ms)

    static let attackDuration: TimeInterval = 0.10
    static let decayDuration: TimeInterval = 0.25
}
