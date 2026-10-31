import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case zh
    case en

    var id: String { rawValue }

    var toggleLabel: String {
        switch self {
        case .zh: return "中"
        case .en: return "EN"
        }
    }

    var next: AppLanguage { self == .zh ? .en : .zh }
}

/// Tiny in-app dictionary — default Chinese, switchable to English.
enum L10n {
    static func t(_ key: String, _ lang: AppLanguage) -> String {
        table[key]?[lang] ?? key
    }

    private static let table: [String: [AppLanguage: String]] = [
        // Brand / chrome
        "app.subtitle": [.zh: "打击垫", .en: "Drum Pads"],
        "hint.tap": [.zh: "点垫就能出声", .en: "Tap a pad to play"],

        // Knobs
        "knob.volume": [.zh: "音量", .en: "Volume"],
        "knob.reverb": [.zh: "回响", .en: "Reverb"],
        "knob.tone": [.zh: "音色", .en: "Tone"],
        "knob.pitch": [.zh: "音调", .en: "Pitch"],

        // Function buttons
        "btn.kit": [.zh: "鼓组", .en: "Kit"],
        "btn.velocity": [.zh: "力度", .en: "Touch"],
        "btn.metronome": [.zh: "节拍器", .en: "Click"],
        "btn.tap": [.zh: "打拍子", .en: "Tap Beat"],
        "btn.repeat": [.zh: "连击", .en: "Hold-Repeat"],
        "btn.clear": [.zh: "清轨", .en: "Clear"],

        // Settings sheet
        "settings.title": [.zh: "设置", .en: "Settings"],
        "settings.done": [.zh: "完成", .en: "Done"],
        "settings.language": [.zh: "语言", .en: "Language"],
        "settings.language.label": [.zh: "界面语言", .en: "App language"],
        "settings.footer": [
            .zh: "后续更多低频选项也会放在这里，避免挤乱左栏 2×3。",
            .en: "More low-frequency options will land here so the 2×3 grids stay clean.",
        ],
        "settings.debug": [.zh: "调试", .en: "Debug"],
        "settings.calibration": [.zh: "矫正模式", .en: "Calibration mode"],
        "settings.calibration.help": [
            .zh: "打开后主界面只显示线框：矩形、十字、编号和间距，方便对照布局。默认关闭。",
            .en: "When on, the stage shows a wireframe only (rects, crosses, ids, gaps) for layout checks. Off by default.",
        ],
        "settings.calibration.copy": [.zh: "复制布局报告", .en: "Copy layout report"],
        "settings.calibration.copied": [.zh: "已复制到剪贴板", .en: "Copied to clipboard"],
        "settings.calibration.copy.needOn": [
            .zh: "请先打开矫正模式，再复制报告。",
            .en: "Turn on Calibration mode first, then copy the report.",
        ],

        // Transport
        "tr.rewind": [.zh: "开头", .en: "Start"],
        "tr.stop": [.zh: "停止", .en: "Stop"],
        "tr.forward": [.zh: "快进", .en: "Skip"],
        "tr.record": [.zh: "录音", .en: "Record"],
        "tr.play": [.zh: "播放", .en: "Play"],
        "tr.loop": [.zh: "循环", .en: "Loop"],

        // Status
        "status.bpm": [.zh: "%d 拍/分", .en: "%d BPM"],
        "status.kit": [.zh: "鼓组：%@", .en: "Kit: %@"],
        "status.velocity": [.zh: "力度：%@", .en: "Touch: %@"],
        "status.repeat.on": [.zh: "连击开", .en: "Repeat On"],
        "status.repeat.off": [.zh: "连击关", .en: "Repeat Off"],
        "status.click.on": [.zh: "节拍器开", .en: "Click On"],
        "status.click.off": [.zh: "节拍器关", .en: "Click Off"],

        // Velocity
        "vel.soft": [.zh: "轻", .en: "Soft"],
        "vel.medium": [.zh: "中", .en: "Medium"],
        "vel.hard": [.zh: "重", .en: "Hard"],
        "vel.fixed": [.zh: "固定", .en: "Fixed"],

        // Kits
        "kit.acoustic": [.zh: "原声鼓", .en: "Acoustic"],
        "kit.electronic": [.zh: "电子鼓", .en: "Electronic"],
        "kit.percussion": [.zh: "打击乐", .en: "Percussion"],

        // Acoustic pad names
        "pad.kick": [.zh: "底鼓", .en: "Kick"],
        "pad.snare": [.zh: "军鼓", .en: "Snare"],
        "pad.hat": [.zh: "踩镲", .en: "Hi-Hat"],
        "pad.openhat": [.zh: "开镲", .en: "Open Hat"],
        "pad.toml": [.zh: "低通鼓", .en: "Low Tom"],
        "pad.tomm": [.zh: "中通鼓", .en: "Mid Tom"],
        "pad.tomh": [.zh: "高通鼓", .en: "High Tom"],
        "pad.clap": [.zh: "拍手", .en: "Clap"],
        "pad.rim": [.zh: "边击", .en: "Rim"],
        "pad.cowbell": [.zh: "牛铃", .en: "Cowbell"],
        "pad.ride": [.zh: "叮叮镲", .en: "Ride"],
        "pad.crash": [.zh: "吊镲", .en: "Crash"],
        "pad.perc1": [.zh: "打击1", .en: "Perc 1"],
        "pad.perc2": [.zh: "打击2", .en: "Perc 2"],
        "pad.shaker": [.zh: "沙锤", .en: "Shaker"],
        "pad.snap": [.zh: "响指", .en: "Snap"],

        // Electronic extras
        "pad.kick_e": [.zh: "电底鼓", .en: "E-Kick"],
        "pad.snare_e": [.zh: "电军鼓", .en: "E-Snare"],
        "pad.blip": [.zh: "哔声", .en: "Blip"],
        "pad.sub": [.zh: "低频", .en: "Sub"],
        "pad.bell": [.zh: "铃声", .en: "Bell"],
        "pad.zap": [.zh: "电击", .en: "Zap"],
        "pad.boom": [.zh: "重击", .en: "Boom"],

        // Percussion extras
        "pad.congal": [.zh: "康加低", .en: "Conga L"],
        "pad.congah": [.zh: "康加高", .en: "Conga H"],
        "pad.wood": [.zh: "木块", .en: "Wood"],
        "pad.block": [.zh: "梆子", .en: "Block"],
        "pad.tick": [.zh: "滴答", .en: "Tick"],
        "pad.swish": [.zh: "刷音", .en: "Swish"],
        "pad.crack": [.zh: "脆响", .en: "Crack"],

        // Categories on pads (short hint, not pro note values)
        "cat.drum": [.zh: "鼓", .en: "Drum"],
        "cat.cymbal": [.zh: "镲", .en: "Cymbal"],
        "cat.hand": [.zh: "手势", .en: "Hand"],
        "cat.perc": [.zh: "打击", .en: "Perc"],
    ]
}

@MainActor
final class AppSettings: ObservableObject {
    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Self.languageKey) }
    }

    /// Debug: replace live chrome/pads with a wireframe calibration HUD. Default OFF.
    @Published var calibrationMode: Bool {
        didSet { UserDefaults.standard.set(calibrationMode, forKey: Self.calibrationKey) }
    }

    private static let languageKey = "padplay.language"
    private static let calibrationKey = "padplay.calibrationMode"

    init() {
        if let raw = UserDefaults.standard.string(forKey: Self.languageKey),
           let lang = AppLanguage(rawValue: raw) {
            language = lang
        } else {
            language = .zh
        }
        calibrationMode = UserDefaults.standard.bool(forKey: Self.calibrationKey)
    }

    func t(_ key: String) -> String { L10n.t(key, language) }

    func tf(_ key: String, _ args: CVarArg...) -> String {
        String(format: t(key), arguments: args)
    }

    func toggleLanguage() {
        language = language.next
    }
}
