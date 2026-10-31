import SwiftUI

/// Hardware-inspired left cluster: 4 knobs + 2×3 round buttons + 2×3 circular transport.
/// Labels/capabilities are beginner-friendly (ZH default, EN via toggle).
struct ControlClusterView: View {
    @EnvironmentObject private var controller: PadController
    @EnvironmentObject private var engine: DrumEngine
    @EnvironmentObject private var settings: AppSettings

    private var knobLabels: [String] {
        [
            settings.t("knob.volume"),
            settings.t("knob.reverb"),
            settings.t("knob.tone"),
            settings.t("knob.pitch"),
        ]
    }

    var body: some View {
        VStack(spacing: 8) {
            // Brand row — hardware faceplate, not an app header stack
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("PadPlay")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(PadTheme.brand)
                Text(settings.t("app.subtitle"))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(PadTheme.dimLabel)
                Spacer(minLength: 4)
                languageToggle
            }

            // Compact status under brand (not a chip sidebar panel)
            HStack(spacing: 8) {
                Text(settings.tf("status.bpm", Int(engine.bpm.rounded())))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(PadTheme.purpleGlow)
                Text("·")
                    .foregroundStyle(PadTheme.dimLabel)
                Text(settings.tf("status.kit", settings.t(controller.padBank.titleKey)))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(PadTheme.label)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 0)
            }

            // 4 rotary knobs (2×2)
            VStack(spacing: 6) {
                HStack(spacing: 10) {
                    knob(2)
                    knob(3)
                }
                HStack(spacing: 10) {
                    knob(0)
                    knob(1)
                }
            }
            .padding(.top, 2)

            // 2×3 function buttons
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    funcBtn(settings.t("btn.kit")) { controller.pressPadBank() }
                    funcBtn(settings.t("btn.velocity")) { controller.pressVelocityType() }
                    funcBtn(settings.t("btn.metronome"), active: engine.metronomeOn) {
                        controller.pressMode()
                    }
                }
                HStack(spacing: 6) {
                    funcBtn(
                        settings.t("btn.tap"),
                        accent: PadTheme.purpleGlow,
                        active: true,
                        pulse: engine.tapFlash
                    ) {
                        controller.pressTapTempo()
                    }
                    funcBtn(
                        settings.t("btn.repeat"),
                        accent: PadTheme.accentRed,
                        active: controller.noteRepeatOn
                    ) {
                        controller.pressNoteRepeat()
                    }
                    funcBtn(settings.t("btn.clear")) {
                        engine.clearPattern()
                    }
                }
            }

            // Circular transport as 2×3 (preview silhouette), not a single long toolbar
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    transport(icon: "backward.end.fill", key: "tr.rewind") { controller.pressRewind() }
                    transport(icon: "stop.fill", key: "tr.stop") { controller.pressStop() }
                    transport(icon: "forward.end.fill", key: "tr.forward") { controller.pressFastForward() }
                }
                HStack(spacing: 6) {
                    transport(
                        icon: "circle.fill",
                        key: "tr.record",
                        accent: PadTheme.accentRed,
                        active: controller.transportRecord
                    ) { controller.pressRecord() }
                    transport(
                        icon: "play.fill",
                        key: "tr.play",
                        accent: PadTheme.purpleGlow,
                        active: controller.transportPlay
                    ) { controller.pressPlay() }
                    transport(
                        icon: "repeat",
                        key: "tr.loop",
                        active: controller.transportLoop
                    ) { controller.pressLoop() }
                }
            }
            .padding(.top, 2)

            Spacer(minLength: 0)
        }
    }

    // MARK: - Pieces

    private var languageToggle: some View {
        Button {
            settings.toggleLanguage()
        } label: {
            HStack(spacing: 0) {
                Text("中")
                    .foregroundStyle(settings.language == .zh ? Color.white : PadTheme.dimLabel)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(settings.language == .zh ? PadTheme.purple : Color.clear)
                Text("EN")
                    .foregroundStyle(settings.language == .en ? Color.white : PadTheme.dimLabel)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(settings.language == .en ? PadTheme.purple : Color.clear)
            }
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .background(Capsule().fill(Color.white.opacity(0.08)))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Language")
    }

    private func knob(_ i: Int) -> some View {
        KnobView(
            index: i,
            value: Binding(
                get: { controller.knobs[i] },
                set: { controller.setKnob(index: i, value: $0) }
            ),
            title: knobLabels[i]
        )
        .frame(maxWidth: .infinity)
    }

    private func funcBtn(
        _ label: String,
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
            action: action
        )
    }

    private func transport(
        icon: String,
        key: String,
        accent: Color? = nil,
        active: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 3) {
            RoundButtonView(
                title: nil,
                systemImage: icon,
                accent: accent,
                isActive: active,
                compact: true,
                action: action
            )
            Text(settings.t(key))
                .font(.system(size: 8, weight: .semibold, design: .rounded))
                .foregroundStyle(PadTheme.dimLabel)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}
