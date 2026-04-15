import SwiftUI

@main
struct White_Noise___Sleep_SoundsApp: App {
    @State private var storeManager = StoreManager()
    @State private var settings = SettingsManager()
    @AppStorage("has_seen_onboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            RootView(
                hasSeenOnboarding: $hasSeenOnboarding,
                storeManager: storeManager,
                settings: settings
            )
        }
    }
}

struct RootView: View {
    @Binding var hasSeenOnboarding: Bool
    var storeManager: StoreManager
    var settings: SettingsManager

    var body: some View {
        if hasSeenOnboarding {
            ContentView(storeManager: storeManager, settings: settings)
        } else {
            OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
        }
    }
}
