import SwiftUI

/// Hardware-inspired left cluster — vision A / C locked metrics (geometry frozen).
/// Brand + status above; knobs 2×2 → function 2×3 → transport 2×3 on shared face-top axis.
/// Top-aligned fixed section gaps (no space-between). Settings gear lives on chassis top-right.
/// Language lives in Settings sheet (ZH default). Materials: beauty v2 (no outer purple fog).
struct ControlClusterView: View {
    @EnvironmentObject private var controller: PadController
    @EnvironmentObject private var engine: DrumEngine
    @EnvironmentObject private var settings: AppSettings

    /// Column-local Y where knob faces start (matches pad13 via ContentView sharedFaceTop).
    var faceTopInColumn: CGFloat = LeftChromeMetrics.sharedFaceTop

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

            // Horizontally center `--cluster-w` island inside ~340 left column.
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                ZStack(alignment: .topLeading) {
                    // Brand sits in the header band above the shared face-top axis.
                    brandBlock(m)
                        .padding(.top, m.leftTopPadding)

                    VStack(alignment: .leading, spacing: 0) {
                        // Pin knob faces to shared axis (pad13 uses the same column-local Y).
                        Color.clear.frame(height: faceTopInColumn)

                        knobsBlock(m)
                            .padding(.bottom, m.sectionGap)

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
                        .padding(.bottom, m.sectionGap)

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

                        // flex-start: leftover height stays below transport (no space-between stretch).
                        Spacer(minLength: 0)
                    }
                }
                .frame(width: m.clusterWidth, alignment: .topLeading)
                .frame(maxHeight: .infinity, alignment: .top)
                Spacer(minLength: 0)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
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
                    .font(.system(size: m.statusSize, weight: .regular, design: .rounded))
                    .foregroundStyle(PadTheme.status)
                Text("·")
                    .foregroundStyle(PadTheme.status.opacity(0.7))
                Text(settings.tf("status.kit", settings.t(controller.padBank.titleKey)))
                    .font(.system(size: m.statusSize, weight: .regular, design: .rounded))
                    .foregroundStyle(PadTheme.status)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 0)
            }
        }
        .frame(width: m.clusterWidth, alignment: .leading)
    }

    private func knobsBlock(_ m: LeftChromeMetrics) -> some View {
        // 2×2 knobs — outer width 84×2+32 = clusterWidth.
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
        .frame(width: diameter, height: diameter)
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
        .frame(width: diameter, height: diameter)
    }
}
