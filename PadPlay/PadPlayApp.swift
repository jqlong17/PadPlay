import SwiftUI

@main
struct PadPlayApp: App {
    @StateObject private var engine = DrumEngine()
    @StateObject private var controller = PadController()
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(engine)
                .environmentObject(controller)
                .environmentObject(settings)
                .preferredColorScheme(.dark)
                .statusBarHidden(true)
                .onAppear {
                    controller.bind(engine: engine)
                    engine.start()
                }
        }
    }
}
