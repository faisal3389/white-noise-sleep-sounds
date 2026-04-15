import SwiftUI

struct ContentView: View {
    @State private var player = AudioPlayerViewModel()
    @State private var favorites = FavoritesManager()
    @State private var mixesManager = MixesManager()
    @State private var timerManager = TimerManager()
    @State private var selectedTab = 0
    var storeManager: StoreManager
    var settings: SettingsManager

    var body: some View {
        TabView(selection: $selectedTab) {
            SoundsListView(
                player: player,
                favorites: favorites,
                storeManager: storeManager,
                selectedTab: $selectedTab
            )
            .tabItem {
                Label("Sounds", systemImage: "waveform")
            }
            .tag(0)

            NowPlayingView(
                player: player,
                favorites: favorites,
                timerManager: timerManager,
                mixesManager: mixesManager
            )
            .tabItem {
                Label("Now Playing", systemImage: "play.circle.fill")
            }
            .tag(1)

            MixesView(
                player: player,
                mixesManager: mixesManager
            )
            .tabItem {
                Label("Mixes", systemImage: "square.stack.3d.up.fill")
            }
            .tag(2)

            FavoritesView(
                player: player,
                favorites: favorites,
                storeManager: storeManager,
                selectedTab: $selectedTab
            )
            .tabItem {
                Label("Favorites", systemImage: "heart.fill")
            }
            .tag(3)

            SettingsView(
                storeManager: storeManager,
                settings: settings
            )
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(4)
        }
        .tint(Color.appAccent)
        .preferredColorScheme(.dark)
        .onAppear {
            // Style the tab bar
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.appSurface)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance

            timerManager.onTimerComplete = {
                player.stop()
            }
            timerManager.onFadeOut = { volume in
                player.setVolume(volume * player.volume)
            }
        }
    }
}
