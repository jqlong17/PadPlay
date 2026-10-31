import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var controller: PadController
    @EnvironmentObject private var engine: DrumEngine
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var calibration: CalibrationLayoutStore

    @State private var showSettings = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                background
                landscapeLayout(size: geo.size)
                    .padding(edgePadding(for: geo.size))
            }
        }
        .ignoresSafeArea()
    }

    private var background: some View {
        PadTheme.chassis
    }

    /// LEFT compact chrome | RIGHT top-bar gear + 4×4 pad stage (vision A).
    private func landscapeLayout(size: CGSize) -> some View {
        let inset = edgePadding(for: size)
        let innerH = size.height - inset * 2
        let innerW = size.width - inset * 2
        let narrow = innerW < 700
        let chassisPad: CGFloat = narrow ? 8 : 12
        let gap: CGFloat = narrow ? 10 : 14

        let usableH = max(0, innerH - chassisPad * 2)
        let usableW = max(0, innerW - chassisPad * 2)

        // Left chrome targets ~340pt content width (vision A `--left-w`); scale down on phone.
        let minLeft: CGFloat = narrow ? 168 : 220
        let maxLeft: CGFloat = narrow ? usableW * 0.38 : min(360, usableW * 0.34)
        var leftWidth = min(max(minLeft, usableW * 0.30), maxLeft)
        var padWidth = max(0, usableW - leftWidth - gap)
        let padHeight = usableH

        // If pad stage would be too narrow for 4 horizontal pads, shrink left further.
        if padWidth < usableH * 0.95 {
            leftWidth = min(leftWidth, max(148, usableW * 0.28))
            padWidth = max(0, usableW - leftWidth - gap)
        }

        let chromeMetrics = LeftChromeMetrics(width: leftWidth, height: usableH)

        return deviceChassis {
            Group {
                if settings.calibrationMode {
                    // Wireframe HUD only — no real knobs/pads; same column metrics as live layout.
                    CalibrationWireframeView(
                        leftWidth: leftWidth,
                        padWidth: padWidth,
                        padHeight: padHeight,
                        columnGap: gap,
                        metrics: chromeMetrics,
                        showSettings: $showSettings
                    )
                } else {
                    HStack(alignment: .center, spacing: gap) {
                        ControlClusterView()
                            .frame(width: leftWidth, alignment: .top)
                            .frame(maxHeight: .infinity, alignment: .top)

                        padStageColumn(width: padWidth, height: padHeight, metrics: chromeMetrics)
                    }
                }
            }
            .padding(chassisPad)
        }
        .frame(width: innerW, height: innerH)
        .onAppear {
            calibration.screenSize = size
        }
        .onChange(of: size) { _, new in
            calibration.screenSize = new
        }
    }

    /// Pad stage: slim top strip with settings gear (far right) + pad grid below.
    private func padStageColumn(width: CGFloat, height: CGFloat, metrics: LeftChromeMetrics) -> some View {
        let topBarH: CGFloat = max(28, 36 * metrics.scale)
        let topBarBottom: CGFloat = max(4, 8 * metrics.scale)
        let gearD = metrics.gearDiameter

        return VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                settingsGearButton(diameter: gearD)
            }
            .frame(height: topBarH)
            .padding(.bottom, topBarBottom)

            PadGridView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: width, height: height)
    }

    /// Quiet gear — ⌀34, faint stroke rgba(255,255,255,0.18), near-transparent fill.
    /// Sheet / popover anchors from this top-right control.
    private func settingsGearButton(diameter: CGFloat) -> some View {
        Button {
            showSettings = true
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: max(12, diameter * 0.44), weight: .regular))
                .foregroundStyle(Color.white.opacity(0.65))
                .frame(width: diameter, height: diameter)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.03))
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(settings.t("settings.title"))
        .popover(isPresented: $showSettings, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
            settingsPopover
        }
    }

    private var settingsPopover: some View {
        SettingsSheetView()
            .environmentObject(settings)
            .environmentObject(calibration)
            .frame(minWidth: 280, idealWidth: 300, minHeight: 280, idealHeight: 360)
            .presentationCompactAdaptation(.popover)
    }

    private func deviceChassis<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(PadTheme.chassis)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.45), radius: 14, y: 6)

            content()
        }
    }

    private func edgePadding(for size: CGSize) -> CGFloat {
        size.width < 700 ? 8 : 14
    }
}

#Preview {
    ContentView()
        .environmentObject(DrumEngine())
        .environmentObject(PadController())
        .environmentObject(AppSettings())
        .environmentObject(CalibrationLayoutStore())
        .preferredColorScheme(.dark)
}
