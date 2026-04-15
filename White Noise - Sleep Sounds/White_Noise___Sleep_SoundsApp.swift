import SwiftUI

@main
struct White_Noise___Sleep_SoundsApp: App {
    @State private var storeManager = StoreManager()
    @State private var settings = SettingsManager()

    var body: some Scene {
        WindowGroup {
            ContentView(storeManager: storeManager, settings: settings)
        }
    }
}
