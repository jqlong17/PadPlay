import SwiftUI

/// Wireframe-only calibration HUD — replaces real knobs/pads/chrome when mode is ON.
/// Shares `LeftChromeMetrics` + `PadGridView.layout` so reported frames match live layout.
struct CalibrationWireframeView: View {
    let leftWidth: CGFloat
    let padWidth: CGFloat
    let padHeight: CGFloat
    let columnGap: CGFloat
    let metrics: LeftChromeMetrics
    @Binding var showSettings: Bool

    @EnvironmentObject private var calibration: CalibrationLayoutStore
    @EnvironmentObject private var settings: AppSettings

    private let rootSpace = "padplay.root"

    var body: some View {
        HStack(alignment: .center, spacing: columnGap) {
            leftChrome
                .frame(width: leftWidth, alignment: .top)
                .frame(maxHeight: .infinity, alignment: .top)
                .calibrationAnchor("left", in: .named(rootSpace))

            padStage
                .frame(width: padWidth, height: padHeight)
        }
        .coordinateSpace(name: rootSpace)
        .onPreferenceChange(CalibrationFrameKey.self) { frames in
            let padLayout = PadGridView.layout(in: CGSize(
                width: padWidth,
                height: max(0, padHeight - LeftChromeMetrics.gearTopReserve)
            ))
            // padGapV fallback = label band + row spacing; update() prefers frame-derived face gap.
            let padGapVFallback = (padLayout.cellH - padLayout.padH) + padLayout.vGap
            let gaps = CalibrationGaps(
                sectionGap: metrics.sectionGap,
                knobCol: metrics.knobColGap,
                knobRow: metrics.knobRowGap,
                btnCol: metrics.colGap,
                padGapH: padLayout.hGap,
                padGapV: padGapVFallback
            )
            // Keep window screenSize from ContentView; only refresh frames + gaps here.
            calibration.update(frames: frames, gaps: gaps, screen: calibration.screenSize)
        }
        .background(Color.black.opacity(0.55))
    }

    // MARK: - Left chrome wireframe

    private var leftChrome: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            VStack(alignment: .leading, spacing: 0) {
                brandStub
                    .padding(.bottom, metrics.brandBottom)

                knobsBlock
                    .padding(.bottom, metrics.sectionGap)
                    .overlay(alignment: .bottom) {
                        marginLabel(metrics.sectionGap, yOffset: metrics.sectionGap * 0.5)
                    }

                buttonsBlock(prefix: "btn", count: 6)
                    .padding(.bottom, metrics.sectionGap)
                    .overlay(alignment: .bottom) {
                        marginLabel(metrics.sectionGap, yOffset: metrics.sectionGap * 0.5)
                    }

                buttonsBlock(prefix: "transport", count: 6)

                Spacer(minLength: 0)
            }
            .frame(width: metrics.clusterWidth, alignment: .topLeading)
            .calibrationAnchor("cluster", in: .named(rootSpace))
            Spacer(minLength: 0)
        }
        .padding(.top, metrics.leftTopPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var brandStub: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("CAL")
                .font(.system(size: metrics.titleSize, weight: .bold, design: .monospaced))
                .foregroundStyle(Wire.stroke)
            Text("矫正 / Calibration")
                .font(.system(size: metrics.statusSize, weight: .regular, design: .monospaced))
                .foregroundStyle(Wire.dim)
        }
        .frame(width: metrics.clusterWidth, alignment: .leading)
        .allowsHitTesting(false)
    }

    private var knobsBlock: some View {
        VStack(spacing: metrics.knobRowGap) {
            HStack(spacing: metrics.knobColGap) {
                wireCircle(id: "knob1", diameter: metrics.knobDiameter)
                wireCircle(id: "knob2", diameter: metrics.knobDiameter)
            }
            .overlay(alignment: .center) {
                // Col gap label between top knobs
                Text(gapText(metrics.knobColGap))
                    .font(Wire.marginFont)
                    .foregroundStyle(Wire.margin)
            }
            HStack(spacing: metrics.knobColGap) {
                wireCircle(id: "knob3", diameter: metrics.knobDiameter)
                wireCircle(id: "knob4", diameter: metrics.knobDiameter)
            }
        }
        .overlay(alignment: .leading) {
            Text(gapText(metrics.knobRowGap))
                .font(Wire.marginFont)
                .foregroundStyle(Wire.margin)
                .rotationEffect(.degrees(-90))
                .offset(x: -14)
        }
        .frame(width: metrics.knobGridWidth)
    }

    private func buttonsBlock(prefix: String, count: Int) -> some View {
        let ids = (1...count).map { "\(prefix)\($0)" }
        return LazyVGrid(
            columns: [
                GridItem(.fixed(metrics.buttonSlot), spacing: metrics.colGap),
                GridItem(.fixed(metrics.buttonSlot), spacing: metrics.colGap),
                GridItem(.fixed(metrics.buttonSlot), spacing: metrics.colGap),
            ],
            alignment: .center,
            spacing: metrics.rowGap
        ) {
            ForEach(ids, id: \.self) { id in
                wireCircle(id: id, diameter: metrics.buttonDiameter)
            }
        }
        .frame(width: metrics.threeColWidth)
        .overlay(alignment: .top) {
            Text(gapText(metrics.colGap))
                .font(Wire.marginFont)
                .foregroundStyle(Wire.margin)
                .offset(y: -12)
        }
    }

    // MARK: - Pad stage wireframe

    private var padStage: some View {
        let gearD = metrics.gearDiameter
        let gearInset = LeftChromeMetrics.gearInset
        let topReserve = LeftChromeMetrics.gearTopReserve

        return ZStack(alignment: .topTrailing) {
            padGridWireframe
                .padding(.top, topReserve)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button {
                showSettings = true
            } label: {
                wireCircle(id: "gear", diameter: gearD)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(settings.t("settings.title"))
            .padding(.top, gearInset)
            .padding(.trailing, gearInset)
            .popover(isPresented: $showSettings, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
                SettingsSheetView()
                    .environmentObject(settings)
                    .environmentObject(calibration)
                    .frame(minWidth: 280, idealWidth: 300, minHeight: 280, idealHeight: 360)
                    .presentationCompactAdaptation(.popover)
            }
        }
    }

    private var padGridWireframe: some View {
        GeometryReader { geo in
            let layout = PadGridView.layout(in: geo.size)
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(Wire.dim, lineWidth: 1)
                    .background(Color.black.opacity(0.25))

                VStack(spacing: layout.vGap) {
                    // Match PadController.gridRowsTopFirst: top row = pad13–16, bottom = pad1–4.
                    ForEach(0..<4, id: \.self) { visualRow in
                        let hardwareRow = 3 - visualRow
                        HStack(spacing: layout.hGap) {
                            ForEach(0..<4, id: \.self) { col in
                                let padId = hardwareRow * 4 + col + 1
                                wirePad(id: "pad\(padId)", width: layout.padW, height: layout.padH)
                                    .frame(width: layout.padW, height: layout.cellH, alignment: .top)
                            }
                        }
                    }
                }
                .padding(layout.inset)
                .overlay(alignment: .topTrailing) {
                    // h = HStack spacing; v = face-to-face row gutter (label band + row spacing).
                    let faceGapV = (layout.cellH - layout.padH) + layout.vGap
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("h \(gapText(layout.hGap))")
                        Text("v \(gapText(faceGapV))")
                    }
                    .font(Wire.marginFont)
                    .foregroundStyle(Wire.margin)
                    .padding(6)
                }
            }
            .frame(width: layout.gridW, height: layout.gridH)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    // MARK: - Primitives

    private func wireCircle(id: String, diameter: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(Wire.stroke, lineWidth: 1.25)
            crosshair()
            Text(shortId(id))
                .font(.system(size: max(8, diameter * 0.22), weight: .semibold, design: .monospaced))
                .foregroundStyle(Wire.label)
        }
        .frame(width: diameter, height: diameter)
        .calibrationAnchor(id, in: .named(rootSpace))
    }

    private func wirePad(id: String, width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: PadTheme.padCornerRadius, style: .continuous)
                .stroke(Wire.stroke, lineWidth: 1.25)
            crosshair()
            Text(shortId(id))
                .font(.system(size: max(9, min(14, height * 0.16)), weight: .semibold, design: .monospaced))
                .foregroundStyle(Wire.label)
        }
        .frame(width: width, height: height)
        .calibrationAnchor(id, in: .named(rootSpace))
    }

    private func crosshair() -> some View {
        ZStack {
            Rectangle().fill(Wire.cross).frame(width: 1, height: 12)
            Rectangle().fill(Wire.cross).frame(width: 12, height: 1)
        }
        .allowsHitTesting(false)
    }

    private func marginLabel(_ value: CGFloat, yOffset: CGFloat) -> some View {
        Text(gapText(value))
            .font(Wire.marginFont)
            .foregroundStyle(Wire.margin)
            .offset(y: yOffset)
            .allowsHitTesting(false)
    }

    private func gapText(_ v: CGFloat) -> String {
        String(format: "%.0f", Double(v))
    }

    private func shortId(_ id: String) -> String {
        id
    }

    private enum Wire {
        static let stroke = Color(red: 0.45, green: 0.92, blue: 0.72) // mint debug, not purple
        static let cross = Color(red: 0.95, green: 0.85, blue: 0.35).opacity(0.85)
        static let label = Color.white.opacity(0.9)
        static let dim = Color.white.opacity(0.35)
        static let margin = Color(red: 1.0, green: 0.72, blue: 0.28)
        static let marginFont = Font.system(size: 9, weight: .medium, design: .monospaced)
    }
}
