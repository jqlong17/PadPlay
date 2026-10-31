import Foundation

enum VelocityCurve: Int, CaseIterable, Identifiable {
    case soft = 0
    case medium
    case hard
    case fixed

    var id: Int { rawValue }

    var titleKey: String {
        switch self {
        case .soft: return "vel.soft"
        case .medium: return "vel.medium"
        case .hard: return "vel.hard"
        case .fixed: return "vel.fixed"
        }
    }

    func map(_ raw: Double) -> Double {
        let x = min(1, max(0, raw))
        switch self {
        case .soft: return pow(x, 0.55)
        case .medium: return pow(x, 0.85)
        case .hard: return pow(x, 1.6)
        case .fixed: return 0.85
        }
    }
}

/// Internal repeat rate — not shown as pro note values to beginners.
enum NoteDivision: Int, CaseIterable, Identifiable {
    case q4 = 0, q8, q16, q32
    case q4t, q8t, q16t, q32t

    var id: Int { rawValue }

    var beats: Double {
        switch self {
        case .q4: return 1.0
        case .q8: return 0.5
        case .q16: return 0.25
        case .q32: return 0.125
        case .q4t: return 2.0 / 3.0
        case .q8t: return 1.0 / 3.0
        case .q16t: return 1.0 / 6.0
        case .q32t: return 1.0 / 12.0
        }
    }
}

enum SwingAmount: Int, CaseIterable, Identifiable {
    case off50 = 0, s55, s57, s59, s61, s64

    var id: Int { rawValue }

    var delayFraction: Double {
        switch self {
        case .off50: return 0
        case .s55: return 0.05
        case .s57: return 0.07
        case .s59: return 0.09
        case .s61: return 0.11
        case .s64: return 0.14
        }
    }
}

struct PadInfo: Identifiable, Equatable {
    let id: Int // 1...16
    let sampleName: String
    let nameKey: String
    let categoryKey: String

    var rowFromBottom: Int { (id - 1) / 4 }
    var column: Int { (id - 1) % 4 }
}

enum DrumKitBank: Int, CaseIterable, Identifiable {
    case acoustic = 0
    case electronic
    case percussion

    var id: Int { rawValue }

    var titleKey: String {
        switch self {
        case .acoustic: return "kit.acoustic"
        case .electronic: return "kit.electronic"
        case .percussion: return "kit.percussion"
        }
    }

    var pads: [PadInfo] {
        switch self {
        case .acoustic:
            return [
                PadInfo(id: 1, sampleName: "kick", nameKey: "pad.kick", categoryKey: "cat.drum"),
                PadInfo(id: 2, sampleName: "snare", nameKey: "pad.snare", categoryKey: "cat.drum"),
                PadInfo(id: 3, sampleName: "closed_hat", nameKey: "pad.hat", categoryKey: "cat.cymbal"),
                PadInfo(id: 4, sampleName: "open_hat", nameKey: "pad.openhat", categoryKey: "cat.cymbal"),
                PadInfo(id: 5, sampleName: "tom_low", nameKey: "pad.toml", categoryKey: "cat.drum"),
                PadInfo(id: 6, sampleName: "tom_mid", nameKey: "pad.tomm", categoryKey: "cat.drum"),
                PadInfo(id: 7, sampleName: "tom_high", nameKey: "pad.tomh", categoryKey: "cat.drum"),
                PadInfo(id: 8, sampleName: "clap", nameKey: "pad.clap", categoryKey: "cat.hand"),
                PadInfo(id: 9, sampleName: "rim", nameKey: "pad.rim", categoryKey: "cat.drum"),
                PadInfo(id: 10, sampleName: "cowbell", nameKey: "pad.cowbell", categoryKey: "cat.perc"),
                PadInfo(id: 11, sampleName: "ride", nameKey: "pad.ride", categoryKey: "cat.cymbal"),
                PadInfo(id: 12, sampleName: "crash", nameKey: "pad.crash", categoryKey: "cat.cymbal"),
                PadInfo(id: 13, sampleName: "perc1", nameKey: "pad.perc1", categoryKey: "cat.perc"),
                PadInfo(id: 14, sampleName: "perc2", nameKey: "pad.perc2", categoryKey: "cat.perc"),
                PadInfo(id: 15, sampleName: "shaker", nameKey: "pad.shaker", categoryKey: "cat.perc"),
                PadInfo(id: 16, sampleName: "snap", nameKey: "pad.snap", categoryKey: "cat.hand"),
            ]
        case .electronic:
            return [
                PadInfo(id: 1, sampleName: "kick_e", nameKey: "pad.kick_e", categoryKey: "cat.drum"),
                PadInfo(id: 2, sampleName: "snare_e", nameKey: "pad.snare_e", categoryKey: "cat.drum"),
                PadInfo(id: 3, sampleName: "closed_hat", nameKey: "pad.hat", categoryKey: "cat.cymbal"),
                PadInfo(id: 4, sampleName: "open_hat", nameKey: "pad.openhat", categoryKey: "cat.cymbal"),
                PadInfo(id: 5, sampleName: "clap", nameKey: "pad.clap", categoryKey: "cat.hand"),
                PadInfo(id: 6, sampleName: "snap", nameKey: "pad.snap", categoryKey: "cat.hand"),
                PadInfo(id: 7, sampleName: "rim", nameKey: "pad.rim", categoryKey: "cat.drum"),
                PadInfo(id: 8, sampleName: "perc1", nameKey: "pad.blip", categoryKey: "cat.perc"),
                PadInfo(id: 9, sampleName: "tom_low", nameKey: "pad.sub", categoryKey: "cat.drum"),
                PadInfo(id: 10, sampleName: "tom_mid", nameKey: "pad.tomm", categoryKey: "cat.drum"),
                PadInfo(id: 11, sampleName: "cowbell", nameKey: "pad.bell", categoryKey: "cat.perc"),
                PadInfo(id: 12, sampleName: "crash", nameKey: "pad.crash", categoryKey: "cat.cymbal"),
                PadInfo(id: 13, sampleName: "ride", nameKey: "pad.ride", categoryKey: "cat.cymbal"),
                PadInfo(id: 14, sampleName: "perc2", nameKey: "pad.zap", categoryKey: "cat.perc"),
                PadInfo(id: 15, sampleName: "shaker", nameKey: "pad.shaker", categoryKey: "cat.perc"),
                PadInfo(id: 16, sampleName: "kick", nameKey: "pad.boom", categoryKey: "cat.drum"),
            ]
        case .percussion:
            return [
                PadInfo(id: 1, sampleName: "tom_low", nameKey: "pad.congal", categoryKey: "cat.perc"),
                PadInfo(id: 2, sampleName: "tom_mid", nameKey: "pad.congah", categoryKey: "cat.perc"),
                PadInfo(id: 3, sampleName: "rim", nameKey: "pad.rim", categoryKey: "cat.drum"),
                PadInfo(id: 4, sampleName: "clap", nameKey: "pad.clap", categoryKey: "cat.hand"),
                PadInfo(id: 5, sampleName: "shaker", nameKey: "pad.shaker", categoryKey: "cat.perc"),
                PadInfo(id: 6, sampleName: "snap", nameKey: "pad.snap", categoryKey: "cat.hand"),
                PadInfo(id: 7, sampleName: "cowbell", nameKey: "pad.cowbell", categoryKey: "cat.perc"),
                PadInfo(id: 8, sampleName: "perc1", nameKey: "pad.wood", categoryKey: "cat.perc"),
                PadInfo(id: 9, sampleName: "perc2", nameKey: "pad.block", categoryKey: "cat.perc"),
                PadInfo(id: 10, sampleName: "closed_hat", nameKey: "pad.tick", categoryKey: "cat.cymbal"),
                PadInfo(id: 11, sampleName: "open_hat", nameKey: "pad.swish", categoryKey: "cat.cymbal"),
                PadInfo(id: 12, sampleName: "ride", nameKey: "pad.ride", categoryKey: "cat.cymbal"),
                PadInfo(id: 13, sampleName: "crash", nameKey: "pad.crash", categoryKey: "cat.cymbal"),
                PadInfo(id: 14, sampleName: "snare", nameKey: "pad.snare", categoryKey: "cat.drum"),
                PadInfo(id: 15, sampleName: "kick", nameKey: "pad.kick", categoryKey: "cat.drum"),
                PadInfo(id: 16, sampleName: "snare_e", nameKey: "pad.crack", categoryKey: "cat.drum"),
            ]
        }
    }
}
