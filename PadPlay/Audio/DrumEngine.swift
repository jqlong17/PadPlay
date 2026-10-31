import AVFoundation
import Combine
import Foundation

/// Local drum sampler built on AVAudioEngine. No external MIDI host required.
@MainActor
final class DrumEngine: ObservableObject {
    @Published var isRunning = false
    @Published var volume: Float = 0.85
    @Published var reverbWet: Float = 0.22
    @Published var filterCutoff: Float = 0.85
    @Published var pitchSemitones: Float = 0

    @Published var bpm: Double = 120
    @Published var isPlaying = false
    @Published var isRecording = false
    @Published var isLooping = true
    @Published var metronomeOn = true
    @Published var tapFlash = false

    private let engine = AVAudioEngine()
    private let playerMixer = AVAudioMixerNode()
    private let reverb = AVAudioUnitReverb()
    private let eq = AVAudioUnitEQ(numberOfBands: 1)
    private var timePitch: AVAudioUnitTimePitch?

    private var buffers: [String: AVAudioPCMBuffer] = [:]
    private var players: [AVAudioPlayerNode] = []
    private var playerIndex = 0
    private let playerPoolSize = 24

    private var metronomeTimer: Timer?
    private var beatIndex = 0
    private var tapTimes: [Date] = []
    private var recordedEvents: [(beat: Double, pad: Int, velocity: Double, bank: Int)] = []
    private var playbackStartDate: Date?
    private var loopLengthBeats: Double = 4
    private var transportTimer: Timer?
    private var lastPlayedKeys = Set<String>()

    init() {
        configureSession()
        configureGraph()
        loadBundledSamples()
    }

    func start() {
        guard !isRunning else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
            isRunning = true
            applyEffects()
        } catch {
            print("DrumEngine start failed: \(error)")
        }
    }

    // MARK: - Playback

    func play(sampleName: String, velocity: Double, pitchOverride: Float? = nil) {
        if !isRunning { start() }
        guard let buffer = buffers[sampleName] else { return }

        let player = players[playerIndex]
        playerIndex = (playerIndex + 1) % players.count

        if let pitchOverride, let timePitch {
            timePitch.pitch = pitchOverride * 100
        } else if let timePitch {
            timePitch.pitch = pitchSemitones * 100
        }

        player.stop()
        player.volume = Float(min(1, max(0.05, velocity)))
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()
    }

    func triggerPad(padId: Int, sampleName: String, velocity: Double, bank: Int) {
        play(sampleName: sampleName, velocity: velocity)
        if isRecording, isPlaying, let start = playbackStartDate {
            let elapsed = Date().timeIntervalSince(start)
            let beat = elapsed * bpm / 60.0
            let wrapped = beat.truncatingRemainder(dividingBy: loopLengthBeats)
            recordedEvents.append((wrapped, padId, velocity, bank))
        }
    }

    // MARK: - Transport / metronome

    func setBPM(_ value: Double) {
        bpm = min(240, max(40, value))
        if isPlaying { restartTransportClock() }
    }

    func tapTempo() {
        let now = Date()
        tapTimes.append(now)
        tapTimes = tapTimes.filter { now.timeIntervalSince($0) < 3.0 }
        if tapTimes.count >= 2 {
            var intervals: [TimeInterval] = []
            for i in 1..<tapTimes.count {
                intervals.append(tapTimes[i].timeIntervalSince(tapTimes[i - 1]))
            }
            let avg = intervals.reduce(0, +) / Double(intervals.count)
            if avg > 0 {
                setBPM(60.0 / avg)
            }
        }
        flashTap()
        play(sampleName: "tick_accent", velocity: 0.7)
    }

    func togglePlay() {
        if isPlaying { stopTransport() } else { startTransport() }
    }

    func stopTransport() {
        isPlaying = false
        isRecording = false
        metronomeTimer?.invalidate()
        metronomeTimer = nil
        transportTimer?.invalidate()
        transportTimer = nil
        playbackStartDate = nil
        beatIndex = 0
        lastPlayedKeys.removeAll()
    }

    func startTransport() {
        guard !isPlaying else { return }
        isPlaying = true
        playbackStartDate = Date()
        beatIndex = 0
        restartTransportClock()
    }

    func toggleRecord() {
        isRecording.toggle()
        if isRecording {
            recordedEvents.removeAll()
            lastPlayedKeys.removeAll()
            if !isPlaying { startTransport() }
        }
    }

    func toggleLoop() { isLooping.toggle() }

    func rewind() {
        playbackStartDate = Date()
        beatIndex = 0
        lastPlayedKeys.removeAll()
    }

    func fastForward() {
        guard let start = playbackStartDate else { return }
        playbackStartDate = start.addingTimeInterval(-2.0)
    }

    func clearPattern() { recordedEvents.removeAll() }

    // MARK: - Effects knobs

    func applyEffects() {
        engine.mainMixerNode.outputVolume = volume
        reverb.wetDryMix = max(0, min(100, reverbWet * 100))
        let minHz: Float = 400
        let maxHz: Float = 18000
        let hz = minHz * pow(maxHz / minHz, max(0.001, min(1, filterCutoff)))
        eq.bands[0].frequency = hz
        eq.bands[0].bypass = filterCutoff > 0.98
        timePitch?.pitch = pitchSemitones * 100
    }

    // MARK: - Private

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setPreferredIOBufferDuration(0.005)
            try session.setActive(true)
        } catch {
            print("AVAudioSession error: \(error)")
        }
    }

    private func configureGraph() {
        reverb.loadFactoryPreset(.mediumHall)
        reverb.wetDryMix = 22

        eq.bands[0].filterType = .lowPass
        eq.bands[0].frequency = 12000
        eq.bands[0].bandwidth = 1.0
        eq.bands[0].bypass = false

        let pitch = AVAudioUnitTimePitch()
        pitch.pitch = 0
        timePitch = pitch

        engine.attach(playerMixer)
        engine.attach(eq)
        engine.attach(pitch)
        engine.attach(reverb)

        for _ in 0..<playerPoolSize {
            let node = AVAudioPlayerNode()
            engine.attach(node)
            players.append(node)
        }

        // Connect after engine is prepared; use nil format to let engine negotiate
        for player in players {
            engine.connect(player, to: playerMixer, format: nil)
        }
        engine.connect(playerMixer, to: eq, format: nil)
        engine.connect(eq, to: pitch, format: nil)
        engine.connect(pitch, to: reverb, format: nil)
        engine.connect(reverb, to: engine.mainMixerNode, format: nil)
    }

    private func loadBundledSamples() {
        let names = [
            "kick", "snare", "closed_hat", "open_hat",
            "tom_low", "tom_mid", "tom_high", "clap",
            "rim", "cowbell", "ride", "crash",
            "perc1", "perc2", "shaker", "snap",
            "tick", "tick_accent", "kick_e", "snare_e",
        ]
        for name in names {
            let url = Bundle.main.url(forResource: name, withExtension: "wav", subdirectory: "Samples")
                ?? Bundle.main.url(forResource: name, withExtension: "wav")
            guard let url else {
                print("Missing sample: \(name)")
                continue
            }
            do {
                let file = try AVAudioFile(forReading: url)
                let frameCount = AVAudioFrameCount(file.length)
                guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount) else { continue }
                try file.read(into: buffer)
                buffers[name] = buffer
            } catch {
                print("Failed loading \(name): \(error)")
            }
        }
    }

    private func restartTransportClock() {
        metronomeTimer?.invalidate()
        transportTimer?.invalidate()

        let interval = 60.0 / bpm
        beatIndex = 0
        playbackStartDate = Date()
        lastPlayedKeys.removeAll()

        metronomeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.onBeat() }
        }
        if let metronomeTimer {
            RunLoop.main.add(metronomeTimer, forMode: .common)
        }

        transportTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tickPlayback() }
        }
        if let transportTimer {
            RunLoop.main.add(transportTimer, forMode: .common)
        }

        onBeat()
    }

    private func onBeat() {
        flashTap()
        if metronomeOn {
            let name = (beatIndex % 4 == 0) ? "tick_accent" : "tick"
            play(sampleName: name, velocity: beatIndex % 4 == 0 ? 0.75 : 0.45)
        }
        beatIndex += 1
    }

    private func tickPlayback() {
        guard isPlaying, let start = playbackStartDate else { return }
        guard !recordedEvents.isEmpty else { return }

        let elapsed = Date().timeIntervalSince(start)
        var beat = elapsed * bpm / 60.0
        if isLooping, beat >= loopLengthBeats {
            playbackStartDate = Date()
            lastPlayedKeys.removeAll()
            beat = 0
        }
        let window: Double = 1.0 / 60.0 * bpm / 60.0 + 0.02
        for event in recordedEvents {
            let key = String(format: "%.4f-%d-%d", event.beat, event.pad, event.bank)
            if abs(event.beat - beat) < window, !lastPlayedKeys.contains(key) {
                lastPlayedKeys.insert(key)
                let bank = DrumKitBank(rawValue: event.bank) ?? .acoustic
                if let pad = bank.pads.first(where: { $0.id == event.pad }) {
                    play(sampleName: pad.sampleName, velocity: event.velocity)
                }
            }
        }
        if beat < 0.05 { lastPlayedKeys.removeAll() }
    }

    private func flashTap() {
        tapFlash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            self?.tapFlash = false
        }
    }
}
