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
    /// Finger currently down (held look).
    @Published var activePads: Set<Int> = []
    /// Pads showing strike rim (finger flash and/or Play/Loop note-on).
    @Published var litPads: Set<Int> = []
    @Published var selectingRepeatParams = false

    @Published var transportPlay = false
    @Published var transportRecord = false
    @Published var transportLoop = true

    private weak var engine: DrumEngine?
    private var repeatTimers: [Int: Timer] = [:]
    private var repeatCounters: [Int: Int] = [:]
    private var flashDecayWork: [Int: DispatchWorkItem] = [:]
    private var cancellables = Set<AnyCancellable>()

    func bind(engine: DrumEngine) {
        self.engine = engine
        syncKnobsToEngine()

        // Sequencer note-ons share the same rim flash as finger taps.
        engine.onPadTriggered = { [weak self] padId in
            self?.flashPad(id: padId)
        }
        engine.onTransportStopped = { [weak self] in
            self?.clearPadFlashes()
        }

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

    // MARK: - Shared hit light (finger + Play/Loop)

    /// Brief rim flash for a pad id on the current grid. Used by Play/Loop note-ons
    /// and other non-touch triggers. One-shot Attack→Decay (no held). Retrigger restarts Attack.
    func flashPad(id: Int) {
        cancelFlashDecay(id)
        pulseLit(id)
        // Playback: peak then Decay — never stays in held.
        scheduleFlashDecay(id: id, after: PadHitLight.attackDuration)
    }

    /// Stop / stop-record: drop every strike flash back to idle.
    func clearPadFlashes() {
        for work in flashDecayWork.values { work.cancel() }
        flashDecayWork.removeAll()
        var t = Transaction()
        t.disablesAnimations = true
        withTransaction(t) {
            litPads.removeAll()
        }
    }

    private func pulseLit(_ id: Int) {
        // Snap off first so a rapid retrigger restarts Attack even if already lit.
        if litPads.contains(id) {
            var t = Transaction()
            t.disablesAnimations = true
            withTransaction(t) { litPads.remove(id) }
        }
        withAnimation(.easeOut(duration: PadHitLight.attackDuration)) {
            litPads.insert(id)
        }
    }

    private func cancelFlashDecay(_ id: Int) {
        flashDecayWork[id]?.cancel()
        flashDecayWork[id] = nil
    }

    private func scheduleFlashDecay(id: Int, after delay: TimeInterval) {
        cancelFlashDecay(id)
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            // Finger still down → leave peak and settle to held (activePads only).
            if self.activePads.contains(id) {
                withAnimation(.easeOut(duration: PadHitLight.decayDuration * 0.5)) {
                    self.litPads.remove(id)
                }
                self.flashDecayWork[id] = nil
                return
            }
            withAnimation(.easeOut(duration: PadHitLight.decayDuration)) {
                self.litPads.remove(id)
            }
            self.flashDecayWork[id] = nil
        }
        flashDecayWork[id] = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }

    // MARK: - Pads

    func padTouchDown(pad: PadInfo, force: CGFloat?) {
        // Beginner mode: pads always play drums (no hidden "param edit" pad mode).
        selectingRepeatParams = false
        let velocity = resolveVelocity(force: force)
        hit(pad: pad, velocity: velocity, sustained: true)

        if noteRepeatOn {
            startNoteRepeat(pad: pad, velocity: velocity)
        }
    }

    func padTouchUp(pad: PadInfo) {
        activePads.remove(pad.id)
        stopNoteRepeat(padId: pad.id)
        // Release → Decay (same path as playback flash end).
        scheduleFlashDecay(id: pad.id, after: 0)
    }

    private func hit(pad: PadInfo, velocity: Double, sustained: Bool) {
        if sustained {
            activePads.insert(pad.id)
            cancelFlashDecay(pad.id)
            // Finger: Attack to hit peak, then settle to held while still down.
            pulseLit(pad.id)
            scheduleFlashDecay(id: pad.id, after: PadHitLight.attackDuration)
        } else {
            flashPad(id: pad.id)
        }
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
                // Retrigger rim while finger stays held.
                self.hit(pad: pad, velocity: velocity * 0.92, sustained: true)
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
        flashPad(id: pad.id)
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
        clearPadFlashes()
    }
    func pressFastForward() { engine?.fastForward() }
    func pressRecord() {
        engine?.toggleRecord()
        // Stop-record → idle flashes (playback note-ons will re-flash if still playing).
        if engine?.isRecording == false {
            clearPadFlashes()
        }
    }
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
