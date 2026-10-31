import SwiftUI

/// Hardware-inspired left cluster with locked faceplate metrics (ACCEPT-P0-and-next).
/// Brand + status → knobs 2×2 → function 2×3 → transport 2×3 → Settings (col 1).
/// Language lives in Settings sheet (ZH default). No purple neon on chrome.
struct ControlClusterView: View {
    @EnvironmentObject private var controller: PadController
    @EnvironmentObject private var engine: DrumEngine
    @EnvironmentObject private var settings: AppSettings

    @State private var showSettings = false

    private var knobLabels: [String] {
        [
            settings.t("knob.volume"),
            settings.t("knob.reverb"),
            settings.t("knob.tone"),
            settings.t("knob.pitch"),
        ]
    }

    var body: some View {
        GeometryReader { geo in
            let m = LeftChromeMetrics(width: geo.size.width, height: geo.size.height)

            VStack(alignment: .leading, spacing: 0) {
                brandBlock(m)
                    .padding(.bottom, m.brandBottom)

                knobsBlock(m)
                    .frame(width: m.threeColWidth)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, m.blockGutter)

                buttonGrid(m) {
                    funcBtn(settings.t("btn.kit"), diameter: m.buttonDiameter) {
                        controller.pressPadBank()
                    }
                    funcBtn(settings.t("btn.velocity"), diameter: m.buttonDiameter) {
                        controller.pressVelocityType()
                    }
                    funcBtn(
                        settings.t("btn.metronome"),
                        diameter: m.buttonDiameter,
                        active: engine.metronomeOn
                    ) {
                        controller.pressMode()
                    }
                    funcBtn(
                        settings.t("btn.tap"),
                        diameter: m.buttonDiameter,
                        pulse: engine.tapFlash
                    ) {
                        controller.pressTapTempo()
                    }
                    funcBtn(
                        settings.t("btn.repeat"),
                        diameter: m.buttonDiameter,
                        accent: PadTheme.accentRed,
                        active: controller.noteRepeatOn
                    ) {
                        controller.pressNoteRepeat()
                    }
                    funcBtn(settings.t("btn.clear"), diameter: m.buttonDiameter) {
                        engine.clearPattern()
                    }
                }
                .frame(width: m.threeColWidth)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, m.blockGutter)

                buttonGrid(m) {
                    transport(icon: "backward.end.fill", key: "tr.rewind", diameter: m.buttonDiameter) {
                        controller.pressRewind()
                    }
                    transport(icon: "stop.fill", key: "tr.stop", diameter: m.buttonDiameter) {
                        controller.pressStop()
                    }
                    transport(icon: "forward.end.fill", key: "tr.forward", diameter: m.buttonDiameter) {
                        controller.pressFastForward()
                    }
                    transport(
                        icon: "circle.fill",
                        key: "tr.record",
                        diameter: m.buttonDiameter,
                        accent: PadTheme.accentRed,
                        active: controller.transportRecord
                    ) { controller.pressRecord() }
                    transport(
                        icon: "play.fill",
                        key: "tr.play",
                        diameter: m.buttonDiameter,
                        active: controller.transportPlay
                    ) { controller.pressPlay() }
                    transport(
                        icon: "repeat",
                        key: "tr.loop",
                        diameter: m.buttonDiameter,
                        active: controller.transportLoop
                    ) { controller.pressLoop() }
                }
                .frame(width: m.threeColWidth)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, m.settingsGutter)

                settingsRow(m)
                    .frame(width: m.threeColWidth, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer(minLength: 0)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheetView()
                .environmentObject(settings)
        }
    }

    // MARK: - Sections

    private func brandBlock(_ m: LeftChromeMetrics) -> some View {
        VStack(alignment: .leading, spacing: max(2, 4 * m.scale)) {
            Text("PadPlay")
                .font(.system(size: m.titleSize, weight: .bold, design: .rounded))
                .foregroundStyle(PadTheme.brand)

            HStack(spacing: 6) {
                Text(settings.tf("status.bpm", Int(engine.bpm.rounded())))
                    .font(.system(size: m.statusSize, weight: .medium, design: .rounded))
                    .foregroundStyle(PadTheme.dimLabel)
                Text("·")
                    .foregroundStyle(PadTheme.dimLabel.opacity(0.6))
                Text(settings.tf("status.kit", settings.t(controller.padBank.titleKey)))
                    .font(.system(size: m.statusSize, weight: .medium, design: .rounded))
                    .foregroundStyle(PadTheme.dimLabel)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func knobsBlock(_ m: LeftChromeMetrics) -> some View {
        // 2×2 knobs, overall centered on the shared three-column width.
        VStack(spacing: m.knobRowGap) {
            HStack(spacing: m.knobColGap) {
                knob(2, diameter: m.knobDiameter)
                knob(3, diameter: m.knobDiameter)
            }
            HStack(spacing: m.knobColGap) {
                knob(0, diameter: m.knobDiameter)
                knob(1, diameter: m.knobDiameter)
            }
        }
        .frame(width: m.knobGridWidth)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    /// Strict 2×3 using shared buttonDiameter / colGap / rowGap (function + transport).
    private func buttonGrid<Content: View>(
        _ m: LeftChromeMetrics,
        @ViewBuilder content: () -> Content
    ) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.fixed(m.buttonSlot), spacing: m.colGap),
                GridItem(.fixed(m.buttonSlot), spacing: m.colGap),
                GridItem(.fixed(m.buttonSlot), spacing: m.colGap),
            ],
            alignment: .center,
            spacing: m.rowGap
        ) {
            content()
        }
        .frame(width: m.threeColWidth)
    }

    private func settingsRow(_ m: LeftChromeMetrics) -> some View {
        // Settings ⌀44, left-aligned to column 1 center of the shared 3-col grid.
        HStack(spacing: 0) {
            RoundButtonView(
                title: nil,
                systemImage: "gearshape.fill",
                diameter: m.settingsDiameter
            ) {
                showSettings = true
            }
            .accessibilityLabel(settings.t("settings.title"))
            .frame(width: m.buttonSlot, height: m.settingsDiameter + 4)

            Spacer(minLength: 0)
        }
    }

    // MARK: - Pieces

    private func knob(_ i: Int, diameter: CGFloat) -> some View {
        KnobView(
            index: i,
            value: Binding(
                get: { controller.knobs[i] },
                set: { controller.setKnob(index: i, value: $0) }
            ),
            title: knobLabels[i],
            diameter: diameter
        )
    }

    private func funcBtn(
        _ label: String,
        diameter: CGFloat,
        accent: Color? = nil,
        active: Bool = false,
        pulse: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        LabeledRoundButton(
            label: label,
            accent: accent,
            isActive: active,
            pulse: pulse,
            diameter: diameter,
            action: action
        )
        .frame(width: diameter + 4, height: diameter + 4)
    }

    private func transport(
        icon: String,
        key: String,
        diameter: CGFloat,
        accent: Color? = nil,
        active: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        RoundButtonView(
            title: nil,
            systemImage: icon,
            accent: accent,
            isActive: active,
            diameter: diameter,
            action: action
        )
        .accessibilityLabel(settings.t(key))
        .frame(width: diameter + 4, height: diameter + 4)
    }
}

// MARK: - Locked metrics (ACCEPT-P0-and-next, ref width 340pt)

private struct LeftChromeMetrics {
    /// Designer reference content width.
    static let refWidth: CGFloat = 340
    /// Approximate stacked height at scale 1.0 (brand→settings).
    static let refHeight: CGFloat = 560

    let width: CGFloat
    let height: CGFloat

    var scale: CGFloat {
        let byWidth = width / Self.refWidth
        let byHeight = height / Self.refHeight
        // Keep proportions; phone landscape shrinks, iPad can sit near 1.0.
        return min(1.05, max(0.58, min(byWidth, byHeight)))
    }

    // Brand
    var titleSize: CGFloat { 22 * scale }
    var statusSize: CGFloat { 13 * scale }
    var brandBottom: CGFloat { 16 * scale }

    // Knobs ⌀72, col 20 / row 12
    var knobDiameter: CGFloat { 72 * scale }
    var knobColGap: CGFloat { 20 * scale }
    var knobRowGap: CGFloat { 12 * scale }
    var knobGridWidth: CGFloat { knobDiameter * 2 + knobColGap }

    // Function + transport share ⌀52, colGap 16 / rowGap 14
    var buttonDiameter: CGFloat { 52 * scale }
    var colGap: CGFloat { 16 * scale }
    var rowGap: CGFloat { 14 * scale }
    /// Slot includes recessed mount (+4) so columns stay centered on the face.
    var buttonSlot: CGFloat { buttonDiameter + 4 }
    var threeColWidth: CGFloat { buttonSlot * 3 + colGap * 2 }

    // Gutters
    var blockGutter: CGFloat { 20 * scale }
    var settingsGutter: CGFloat { 16 * scale }

    // Settings ⌀44 — aligned to column 1
    var settingsDiameter: CGFloat { 44 * scale }
}
