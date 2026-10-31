import Combine
import Foundation
import SwiftUI

@MainActor
final class PadController: ObservableObject {
    @Published var knobBank: Int = 0 // 0 or 1
    @Published var padBank: DrumKitBank = .acoustic
    @Published var modeIndex: Int = 0 // 0 pad / 1 kit preview label
    @Published var velocityType: VelocityCurve = .medium
    @Published var noteRepeatOn = false
    @Published var noteRepeatDivision: NoteDivision = .q16
    @Published var swing: SwingAmount = .off50
    @Published var octaveShift: Int = 0 // -1...1 mapped to pitch

    @Published var knobs: [Float] = [0.85, 0.22, 0.85, 0.5] // vol, reverb, filter, pitch(0.5=0)
    @Published var activePads: Set<Int> = []
    @Published var litPads: Set<Int> = []
    @Published var selectingRepeatParams = false

    @Published var transportPlay = false
    @Published var transportRecord = false
    @Published var transportLoop = true

    private weak var engine: DrumEngine?
    private var repeatTimers: [Int: Timer] = [:]
    private var repeatCounters: [Int: Int] = [:]
    private var cancellables = Set<AnyCancellable>()

    func bind(engine: DrumEngine) {
        self.engine = engine
        syncKnobsToEngine()

        engine.$isPlaying
            .receive(on: RunLoop.main)
            .sink { [weak self] v in self?.transportPlay = v }
            .store(in: &cancellables)
        engine.$isRecording
            .receive(on: RunLoop.main)
            .sink { [weak self] v in self?.transportRecord = v }
            .store(in: &cancellables)
        engine.$isLooping
            .receive(on: RunLoop.main)
            .sink { [weak self] v in self?.transportLoop = v }
            .store(in: &cancellables)
    }

    var pads: [PadInfo] { padBank.pads }

    /// Visual grid: top row first for SwiftUI (PAD13-16 ... PAD1-4).
    var gridRowsTopFirst: [[PadInfo]] {
        let all = pads
        return (0..<4).reversed().map { row in
            Array(all[(row * 4)..<(row * 4 + 4)])
        }
    }

    // MARK: - Pads

    func padTouchDown(pad: PadInfo, force: CGFloat?) {
        // Beginner mode: pads always play drums (no hidden "param edit" pad mode).
        selectingRepeatParams = false
        let velocity = resolveVelocity(force: force)
        hit(pad: pad, velocity: velocity)

        if noteRepeatOn {
            startNoteRepeat(pad: pad, velocity: velocity)
        }
    }

    func padTouchUp(pad: PadInfo) {
        activePads.remove(pad.id)
        stopNoteRepeat(padId: pad.id)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            self?.litPads.remove(pad.id)
        }
    }

    private func hit(pad: PadInfo, velocity: Double) {
        activePads.insert(pad.id)
        litPads.insert(pad.id)
        let pitch = Float(octaveShift * 12) + ((knobs[3] - 0.5) * 24)
        engine?.pitchSemitones = pitch
        engine?.triggerPad(padId: pad.id, sampleName: pad.sampleName, velocity: velocity, bank: padBank.rawValue)
    }

    private func resolveVelocity(force: CGFloat?) -> Double {
        if let force, force > 0 {
            // Approximate 3D Touch / Apple Pencil force into 0...1
            let raw = min(1.0, Double(force) / 3.5)
            return velocityType.map(raw)
        }
        // Finger without force: use medium default intensity with curve
        return velocityType.map(0.78)
    }

    // MARK: - Note repeat

    private func startNoteRepeat(pad: PadInfo, velocity: Double) {
        stopNoteRepeat(padId: pad.id)
        repeatCounters[pad.id] = 0
        scheduleNextRepeat(pad: pad, velocity: velocity)
    }

    private func scheduleNextRepeat(pad: PadInfo, velocity: Double) {
        guard let engine else { return }
        let beats = noteRepeatDivision.beats
        let base = beats * 60.0 / engine.bpm
        let count = repeatCounters[pad.id] ?? 0
        var delay = base
        if count % 2 == 1 {
            delay += base * swing.delayFraction
        }
        let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.activePads.contains(pad.id), self.noteRepeatOn else { return }
                self.hit(pad: pad, velocity: velocity * 0.92)
                self.repeatCounters[pad.id] = count + 1
                self.scheduleNextRepeat(pad: pad, velocity: velocity)
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        repeatTimers[pad.id] = timer
    }

    private func stopNoteRepeat(padId: Int) {
        repeatTimers[padId]?.invalidate()
        repeatTimers[padId] = nil
        repeatCounters[padId] = nil
    }

    private func applyRepeatParam(from pad: PadInfo) {
        litPads.insert(pad.id)
        switch pad.id {
        case 1: noteRepeatDivision = .q4
        case 2: noteRepeatDivision = .q8
        case 3: noteRepeatDivision = .q16
        case 4: noteRepeatDivision = .q32
        case 5: noteRepeatDivision = .q4t
        case 6: noteRepeatDivision = .q8t
        case 7: noteRepeatDivision = .q16t
        case 8: noteRepeatDivision = .q32t
        case 9: swing = .off50
        case 10: swing = .s55
        case 11: swing = .s57
        case 12: swing = .s59
        case 13: swing = .s61
        case 14: swing = .s64
        case 15: octaveShift = max(-1, octaveShift - 1)
        case 16: octaveShift = min(1, octaveShift + 1)
        default: break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.litPads.remove(pad.id)
        }
    }

    // MARK: - Buttons

    func pressKnobBank() {
        knobBank = (knobBank + 1) % 2
    }

    func pressMode() {
        guard let engine else { return }
        engine.metronomeOn.toggle()
        modeIndex = engine.metronomeOn ? 0 : 1
    }

    func pressTapTempo() {
        engine?.tapTempo()
    }

    func pressPadBank() {
        let all = DrumKitBank.allCases
        let idx = (padBank.rawValue + 1) % all.count
        padBank = all[idx]
    }

    func pressVelocityType() {
        let all = VelocityCurve.allCases
        let idx = (velocityType.rawValue + 1) % all.count
        velocityType = all[idx]
    }

    func pressNoteRepeat() {
        noteRepeatOn.toggle()
        if !noteRepeatOn {
            selectingRepeatParams = false
            for id in Array(repeatTimers.keys) { stopNoteRepeat(padId: id) }
        }
    }

    func longPressNoteRepeat() {
        noteRepeatOn = true
        selectingRepeatParams.toggle()
    }

    func pressRewind() { engine?.rewind() }
    func pressStop() {
        engine?.stopTransport()
        transportPlay = false
        transportRecord = false
    }
    func pressFastForward() { engine?.fastForward() }
    func pressRecord() { engine?.toggleRecord() }
    func pressPlay() { engine?.togglePlay() }
    func pressLoop() { engine?.toggleLoop() }

    // MARK: - Knobs

    func setKnob(index: Int, value: Float) {
        guard (0..<4).contains(index) else { return }
        knobs[index] = min(1, max(0, value))
        syncKnobsToEngine()
    }

    private func syncKnobsToEngine() {
        guard let engine else { return }
        if knobBank == 0 {
            engine.volume = knobs[0]
            engine.reverbWet = knobs[1]
            engine.filterCutoff = knobs[2]
            engine.pitchSemitones = (knobs[3] - 0.5) * 24 + Float(octaveShift * 12)
        } else {
            // Bank B: metronome level via vol, less reverb focus
            engine.volume = knobs[0]
            engine.reverbWet = knobs[1] * 0.5
            engine.filterCutoff = knobs[2]
            engine.pitchSemitones = (knobs[3] - 0.5) * 12
        }
        engine.applyEffects()
    }
}
