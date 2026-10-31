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
    /// Brief hit brighten of the same flat purple (still flat).
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
