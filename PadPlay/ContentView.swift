import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var controller: PadController
    @EnvironmentObject private var engine: DrumEngine
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var calibration: CalibrationLayoutStore

    @State private var showSettings = false

    /// Chassis-root coordinate space — frames + screenSize share this box.
    private let rootSpace = "padplay.root"

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

    /// LEFT compact chrome | RIGHT 4×4 pad stage; gear overlays chassis top-trailing.
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
        let chassisSize = CGSize(width: innerW, height: innerH)
        // Column-local Y of shared faces = chassis sharedFaceTop − chassisPad.
        let faceTopInColumn = max(0, LeftChromeMetrics.sharedFaceTop - chassisPad)

        return deviceChassis {
            Group {
                if settings.calibrationMode {
                    // Wireframe HUD owns chassis root space + gear (for frame collection).
                    CalibrationWireframeView(
                        leftWidth: leftWidth,
                        padWidth: padWidth,
                        padHeight: padHeight,
                        columnGap: gap,
                        metrics: chromeMetrics,
                        faceTopInColumn: faceTopInColumn,
                        chassisPad: chassisPad,
                        chassisSize: chassisSize,
                        rootSpaceName: rootSpace,
                        showSettings: $showSettings
                    )
                } else {
                    ZStack(alignment: .topTrailing) {
                        HStack(alignment: .top, spacing: gap) {
                            ControlClusterView(faceTopInColumn: faceTopInColumn)
                                .frame(width: leftWidth, alignment: .top)
                                .frame(maxHeight: .infinity, alignment: .top)

                            padStageColumn(
                                width: padWidth,
                                height: padHeight,
                                faceTopInColumn: faceTopInColumn
                            )
                        }
                        .padding(chassisPad)

                        // Gear locks to chassis edges (not pad-stage), inset top/right 18.
                        settingsGearButton(diameter: chromeMetrics.gearDiameter)
                            .padding(.top, LeftChromeMetrics.gearInset)
                            .padding(.trailing, LeftChromeMetrics.gearInset)
                    }
                }
            }
        }
        .frame(width: innerW, height: innerH)
        .onAppear {
            // Report chassis box — same space as frame origins (not outer window).
            calibration.screenSize = chassisSize
        }
        .onChange(of: size) { _, new in
            let edge = edgePadding(for: new)
            calibration.screenSize = CGSize(
                width: new.width - edge * 2,
                height: new.height - edge * 2
            )
        }
    }

    /// Pad stage: top-aligned grid so pad13 face sits on the shared face-top axis.
    private func padStageColumn(
        width: CGFloat,
        height: CGFloat,
        faceTopInColumn: CGFloat
    ) -> some View {
        PadGridView(verticalAlignment: .top)
            .padding(.top, faceTopInColumn)
            .frame(width: width, height: height, alignment: .top)
    }

    /// Quiet gear — ⌀34, faint stroke rgba(255,255,255,0.18), near-transparent fill.
    /// Sheet / popover anchors from this chassis top-right control.
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
