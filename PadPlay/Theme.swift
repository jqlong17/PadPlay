import SwiftUI
import UIKit

enum PadTheme {
    // Chassis — matte plastic hardware body
    static let chassis = Color(red: 0.06, green: 0.055, blue: 0.07)
    static let chassisEdge = Color(red: 0.16, green: 0.14, blue: 0.18)
    static let chassisWell = Color(red: 0.04, green: 0.035, blue: 0.045)
    static let metal = Color(red: 0.22, green: 0.21, blue: 0.24)
    static let metalHighlight = Color(red: 0.38, green: 0.37, blue: 0.40)

    static let label = Color(red: 0.90, green: 0.90, blue: 0.92)
    static let dimLabel = Color(red: 0.52, green: 0.50, blue: 0.56)

    // Silicone-lit purple (preview / pad-ref)
    static let purple = Color(red: 0.52, green: 0.22, blue: 0.92)
    static let purpleGlow = Color(red: 0.78, green: 0.55, blue: 1.0)
    static let purpleCore = Color(red: 0.88, green: 0.78, blue: 1.0)
    static let purpleEdge = Color(red: 0.34, green: 0.10, blue: 0.62)
    static let purpleHit = Color(red: 0.95, green: 0.88, blue: 1.0)

    static let accentRed = Color(red: 0.92, green: 0.22, blue: 0.28)
    static let knobCap = Color(red: 0.11, green: 0.10, blue: 0.12)
    static let brand = Color.white.opacity(0.95)

    // UIKit counterparts for PadUIView gradient layers
    enum UI {
        static let purpleCore = UIColor(red: 0.88, green: 0.78, blue: 1.0, alpha: 1)
        static let purpleMid = UIColor(red: 0.62, green: 0.32, blue: 0.95, alpha: 1)
        static let purpleEdge = UIColor(red: 0.30, green: 0.08, blue: 0.55, alpha: 1)
        static let purpleHitCore = UIColor(red: 0.97, green: 0.92, blue: 1.0, alpha: 1)
        static let purpleHitMid = UIColor(red: 0.82, green: 0.58, blue: 1.0, alpha: 1)
        static let purpleHitEdge = UIColor(red: 0.48, green: 0.18, blue: 0.88, alpha: 1)
        static let padBezel = UIColor(red: 0.03, green: 0.02, blue: 0.04, alpha: 1)
        static let label = UIColor(white: 0.96, alpha: 1)
        static let dimLabel = UIColor(white: 0.82, alpha: 0.88)
    }
}
