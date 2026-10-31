import SwiftUI

/// Hardware-inspired left cluster: 4 knobs + 2×3 round buttons + 2×3 circular transport.
/// Labels/capabilities are beginner-friendly (ZH default, EN via toggle).
/// No purple neon on function / transport (TOKENS-from-mock).
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
            // Brand — PadPlay + optional 中/EN; drop subtitle stack to match mock height.
            HStack(alignment: .center, spacing: 6) {
                Text("PadPlay")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(PadTheme.brand)
                Spacer(minLength: 4)
                languageToggle
            }

            // Quiet single-line status (no purple BPM card).
            HStack(spacing: 6) {
                Text(settings.tf("status.bpm", Int(engine.bpm.rounded())))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(PadTheme.dimLabel)
                Text("·")
                    .foregroundStyle(PadTheme.dimLabel.opacity(0.6))
                Text(settings.tf("status.kit", settings.t(controller.padBank.titleKey)))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(PadTheme.dimLabel)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 0)
            }

            // 4 rotary knobs (2×2)
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    knob(2)
                    knob(3)
                }
                HStack(spacing: 8) {
                    knob(0)
                    knob(1)
                }
            }
            .padding(.top, 2)

            // 2×3 function buttons — face labels only; 连击 uses red ink when active.
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
                        active: false,
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

            // Transport 2×3 — white icons / white active ring; record stays red.
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
                    .background(settings.language == .zh ? Color.white.opacity(0.18) : Color.clear)
                Text("EN")
                    .foregroundStyle(settings.language == .en ? Color.white : PadTheme.dimLabel)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(settings.language == .en ? Color.white.opacity(0.18) : Color.clear)
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
        RoundButtonView(
            title: nil,
            systemImage: icon,
            accent: accent,
            isActive: active,
            compact: true,
            action: action
        )
        .accessibilityLabel(settings.t(key))
        .frame(maxWidth: .infinity)
    }
}
