import SwiftUI

enum PadTheme {
    static let chassis = Color(red: 0.07, green: 0.07, blue: 0.08)
    static let chassisEdge = Color(red: 0.14, green: 0.12, blue: 0.16)
    static let metal = Color(red: 0.18, green: 0.17, blue: 0.19)
    static let label = Color(red: 0.78, green: 0.78, blue: 0.80)
    static let dimLabel = Color(red: 0.45, green: 0.45, blue: 0.48)
    static let purple = Color(red: 0.55, green: 0.28, blue: 0.85)
    static let purpleGlow = Color(red: 0.72, green: 0.42, blue: 1.0)
    static let accentRed = Color(red: 0.92, green: 0.22, blue: 0.28)
    static let padIdle = Color(red: 0.88, green: 0.88, blue: 0.90).opacity(0.22)
    static let padLit = Color(red: 0.78, green: 0.55, blue: 1.0)
    static let knobCap = Color(red: 0.12, green: 0.12, blue: 0.13)
    static let brand = Color.white.opacity(0.92)
}
