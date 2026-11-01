import SwiftUI

@main
struct PadPlayApp: App {
    @StateObject private var engine = DrumEngine()
    @StateObject private var controller = PadController()
    @StateObject private var settings = AppSettings()
    @StateObject private var calibration = CalibrationLayoutStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(engine)
                .environmentObject(controller)
                .environmentObject(settings)
                .environmentObject(calibration)
                .preferredColorScheme(.dark)
                .statusBarHidden(true)
                .onAppear {
                    controller.bind(engine: engine)
                    // Start after the first frame so audio RPC cannot abort launch.
                    Task { @MainActor in
                        _ = engine.start()
                    }
                }
        }
    }
}
