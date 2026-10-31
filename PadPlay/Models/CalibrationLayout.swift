import Foundation
import SwiftUI
import UIKit

/// Vision A token targets for calibration deltas (Docs/vision-A/TOKEN-MAP.md).
enum CalibrationTokens {
    static let leftWidth: CGFloat = 340
    static let clusterWidth: CGFloat = 200
    static let knobDiameter: CGFloat = 84
    static let knobColGap: CGFloat = 32
    static let knobRowGap: CGFloat = 10
    static let sectionGap: CGFloat = 18
    static let buttonDiameter: CGFloat = 56
    static let buttonColGap: CGFloat = 16
    static let gearDiameter: CGFloat = 34
    static let gearInset: CGFloat = 18
    /// Shared knob1 / pad13 face top in chassis-root coordinates.
    static let sharedFaceTop: CGFloat = 104
}

/// Measured section / gutter gaps reported alongside frames.
/// `padGapH` / `padGapV` are face-to-face gutters between pad frames (not VStack row spacing alone).
struct CalibrationGaps: Equatable {
    var sectionGap: CGFloat = 0
    var knobCol: CGFloat = 0
    var knobRow: CGFloat = 0
    var btnCol: CGFloat = 0
    var padGapH: CGFloat = 0
    /// Vertical space between pad faces of adjacent rows (frame-based).
    var padGapV: CGFloat = 0
}

/// Collects wireframe frames (pt, origin = root chassis content top-left) for the paste report.
@MainActor
final class CalibrationLayoutStore: ObservableObject {
    @Published var frames: [String: CGRect] = [:]
    @Published var gaps: CalibrationGaps = CalibrationGaps()
    @Published var screenSize: CGSize = .zero
    @Published var lastCopiedAt: Date?

    /// Stable id order for the QA paste schema.
    static let itemOrder: [String] = {
        var ids = ["left", "cluster"]
        ids += (1...4).map { "knob\($0)" }
        ids += (1...6).map { "btn\($0)" }
        ids += (1...6).map { "transport\($0)" }
        ids += (1...16).map { "pad\($0)" }
        ids.append("gear")
        return ids
    }()

    func update(frames: [String: CGRect], gaps: CalibrationGaps, screen: CGSize) {
        self.frames = frames
        // Prefer frame-derived padGapV so the paste report matches QA face-to-face row gutters.
        var resolved = gaps
        if let v = Self.padGapV(from: frames) {
            resolved.padGapV = v
        }
        if let h = Self.padGapH(from: frames) {
            resolved.padGapH = h
        }
        self.gaps = resolved
        self.screenSize = screen
    }

    /// Face-to-face vertical gutter: next-row pad.minY − upper-row pad.maxY (top visual row = pad13–16).
    static func padGapV(from frames: [String: CGRect]) -> CGFloat? {
        gap(from: frames, upperId: "pad13", lowerId: "pad9", horizontal: false)
    }

    /// Face-to-face horizontal gutter between neighboring pads in a row.
    static func padGapH(from frames: [String: CGRect]) -> CGFloat? {
        gap(from: frames, upperId: "pad13", lowerId: "pad14", horizontal: true)
    }

    private static func gap(
        from frames: [String: CGRect],
        upperId: String,
        lowerId: String,
        horizontal: Bool
    ) -> CGFloat? {
        guard let a = frames[upperId], let b = frames[lowerId],
              !a.isNull, !b.isNull, !a.isInfinite, !b.isInfinite
        else { return nil }
        return horizontal ? (b.minX - a.maxX) : (b.minY - a.maxY)
    }

    func copyReportToPasteboard() {
        UIPasteboard.general.string = makeReport()
        lastCopiedAt = Date()
    }

    /// QA-locked plain-text layout report v0.
    func makeReport() -> String {
        let device = UIDevice.current.model
        let orient: String = {
            switch UIDevice.current.orientation {
            case .landscapeLeft: return "landscapeLeft"
            case .landscapeRight: return "landscapeRight"
            case .portrait: return "portrait"
            case .portraitUpsideDown: return "portraitUpsideDown"
            default: return "landscape"
            }
        }()
        // Prefer live window size from ContentView; fall back to main screen bounds.
        let reportSize: CGSize = {
            if screenSize.width > 1, screenSize.height > 1 { return screenSize }
            return UIScreen.main.bounds.size
        }()
        let w = Int(reportSize.width.rounded())
        let h = Int(reportSize.height.rounded())

        var lines: [String] = []
        lines.append("PadPlay layout report v0")
        lines.append("\(device) / \(orient) / \(w)×\(h)")
        lines.append("origin: root (chassis content top-left, pt)")
        lines.append("items: id | x y w h | token | delta")

        for id in Self.itemOrder {
            let rect = frames[id] ?? .null
            lines.append(itemLine(id: id, rect: rect))
        }

        lines.append("gaps: sectionGap | knobCol | knobRow | btnCol | padGapH | padGapV")
        lines.append(gapLine(name: "sectionGap", measured: gaps.sectionGap, token: CalibrationTokens.sectionGap))
        lines.append(gapLine(name: "knobCol", measured: gaps.knobCol, token: CalibrationTokens.knobColGap))
        lines.append(gapLine(name: "knobRow", measured: gaps.knobRow, token: CalibrationTokens.knobRowGap))
        lines.append(gapLine(name: "btnCol", measured: gaps.btnCol, token: CalibrationTokens.buttonColGap))
        lines.append(gapLine(name: "padGapH", measured: gaps.padGapH, token: nil))
        lines.append(gapLine(name: "padGapV", measured: gaps.padGapV, token: nil))
        // Alignment lock: knob1.y ≈ pad13.y within 3pt near sharedFaceTop.
        if let knob = frames["knob1"], let pad = frames["pad13"],
           !knob.isNull, !pad.isNull {
            let d = pad.minY - knob.minY
            lines.append(
                "align: knob1.y \(fmt(knob.minY)) pad13.y \(fmt(pad.minY)) Δ \(fmt(d)) targetFaceTop \(fmt(CalibrationTokens.sharedFaceTop))"
            )
        }
        lines.append(
            "Vision A token targets: left-w 340, cluster 200, knob⌀84, col32/row10, sectionGap18, btn⌀56, gear⌀34 inset18, sharedFaceTop104."
        )
        return lines.joined(separator: "\n")
    }

    private func itemLine(id: String, rect: CGRect) -> String {
        let xywh: String
        if rect.isNull || rect.isInfinite {
            xywh = "— — — —"
        } else {
            xywh = "\(fmt(rect.minX)) \(fmt(rect.minY)) \(fmt(rect.width)) \(fmt(rect.height))"
        }

        let (token, delta) = tokenAndDelta(id: id, rect: rect)
        return "\(id) | \(xywh) | \(token) | \(delta)"
    }

    private func tokenAndDelta(id: String, rect: CGRect) -> (String, String) {
        guard !rect.isNull, !rect.isInfinite else { return ("—", "—") }

        if id == "left" {
            let t = CalibrationTokens.leftWidth
            return ("left-w \(fmt(t))", "dw \(fmt(rect.width - t))")
        }
        if id == "cluster" {
            let t = CalibrationTokens.clusterWidth
            return ("cluster-w \(fmt(t))", "dw \(fmt(rect.width - t))")
        }
        if id.hasPrefix("knob") {
            let t = CalibrationTokens.knobDiameter
            var delta = "dw \(fmt(rect.width - t)) dh \(fmt(rect.height - t))"
            if id == "knob1" {
                delta += " dyFace \(fmt(rect.minY - CalibrationTokens.sharedFaceTop))"
            }
            return ("knob⌀\(fmt(t))", delta)
        }
        if id.hasPrefix("btn") || id.hasPrefix("transport") {
            let t = CalibrationTokens.buttonDiameter
            return ("btn⌀\(fmt(t))", "dw \(fmt(rect.width - t)) dh \(fmt(rect.height - t))")
        }
        if id == "gear" {
            let t = CalibrationTokens.gearDiameter
            let inset = CalibrationTokens.gearInset
            // Trailing gutter vs chassis screenWidth — target 18.
            let rightGutter: CGFloat = {
                guard screenSize.width > 1 else { return .nan }
                return screenSize.width - rect.maxX
            }()
            let topGutter = rect.minY
            return (
                "gear⌀\(fmt(t)) inset\(fmt(inset))",
                "dw \(fmt(rect.width - t)) dh \(fmt(rect.height - t)) top \(fmt(topGutter - inset)) right \(fmt(rightGutter - inset))"
            )
        }
        if id == "pad13" {
            let target = CalibrationTokens.sharedFaceTop
            return ("faceTop \(fmt(target))", "dyFace \(fmt(rect.minY - target))")
        }
        // Pads flex to stage — no fixed Vision A size token.
        return ("—", "—")
    }

    private func gapLine(name: String, measured: CGFloat, token: CGFloat?) -> String {
        if let token {
            return "\(name) | \(fmt(measured)) | \(fmt(token)) | \(fmt(measured - token))"
        }
        return "\(name) | \(fmt(measured)) | — | —"
    }

    private func fmt(_ v: CGFloat) -> String {
        String(format: "%.2f", Double(v))
    }
}

// MARK: - Preference / coordinate helpers

struct CalibrationFrameKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

extension View {
    /// Publish this view’s frame in the named coordinate space under `id`.
    func calibrationAnchor(_ id: String, in space: CoordinateSpace) -> some View {
        background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: CalibrationFrameKey.self,
                    value: [id: geo.frame(in: space)]
                )
            }
        )
    }
}
