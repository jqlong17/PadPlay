import SwiftUI

enum PadTheme {
    // Chassis — matte plastic hardware body
    static let chassis = Color(red: 0.06, green: 0.055, blue: 0.07)
    static let chassisEdge = Color(red: 0.16, green: 0.14, blue: 0.18)
    static let chassisWell = Color(red: 0.035, green: 0.03, blue: 0.04)
    static let metal = Color(red: 0.22, green: 0.21, blue: 0.24)
    static let metalHighlight = Color(red: 0.38, green: 0.37, blue: 0.40)

    static let label = Color(red: 0.90, green: 0.90, blue: 0.92)
    static let dimLabel = Color(red: 0.52, green: 0.50, blue: 0.56)

    // Silicone-lit purple — matches pad-ref (#D8B4FF core → saturated edge)
    static let purple = Color(red: 0.55, green: 0.22, blue: 0.95)
    static let purpleGlow = Color(red: 0.82, green: 0.58, blue: 1.0)
    static let purpleCore = Color(red: 0.85, green: 0.71, blue: 1.0) // ~#D8B4FF
    static let purpleEdge = Color(red: 0.28, green: 0.08, blue: 0.55)
    static let purpleHit = Color(red: 0.96, green: 0.90, blue: 1.0)

    static let accentRed = Color(red: 0.92, green: 0.22, blue: 0.28)
    static let knobCap = Color(red: 0.11, green: 0.10, blue: 0.12)
    static let brand = Color.white.opacity(0.95)
}
