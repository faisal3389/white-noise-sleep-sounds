import SwiftUI
import FirebaseCore

@main
struct White_Noise___Sleep_SoundsApp: App {
    @State private var storeManager = StoreManager()
    @State private var settings = SettingsManager()
    @AppStorage("has_seen_onboarding") private var hasSeenOnboarding = false
    @State private var showSplash = true

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView(
                    hasSeenOnboarding: $hasSeenOnboarding,
                    storeManager: storeManager,
                    settings: settings
                )
                .onAppear {
                    AnalyticsManager.shared.track(.appLaunched, properties: [
                        "is_premium": storeManager.isPremium,
                        "has_seen_onboarding": hasSeenOnboarding
                    ])
                }

                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                                withAnimation(.easeOut(duration: 0.6)) {
                                    showSplash = false
                                }
                            }
                        }
                }
            }
        }
    }
}

struct RootView: View {
    @Binding var hasSeenOnboarding: Bool
    var storeManager: StoreManager
    var settings: SettingsManager
    @State private var deepLinkSoundId: String?
    @State private var deepLinkAction: DeepLinkAction?

    enum DeepLinkAction: Equatable {
        case nowPlaying
        case toggle
        case playSound(String)
    }

    var body: some View {
        if hasSeenOnboarding {
            ContentView(
                storeManager: storeManager,
                settings: settings,
                deepLinkSoundId: $deepLinkSoundId,
                deepLinkAction: $deepLinkAction
            )
            .onOpenURL { url in
                handleDeepLink(url)
            }
        } else {
            OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "whitenoise" else { return }

        switch url.host {
        case "nowplaying":
            deepLinkAction = .nowPlaying
        case "toggle":
            deepLinkAction = .toggle
        case "play":
            // whitenoise://play/sound_id
            let soundId = url.pathComponents.dropFirst().first ?? ""
            if !soundId.isEmpty {
                deepLinkAction = .playSound(soundId)
            }
        default:
            break
        }
    }
}
