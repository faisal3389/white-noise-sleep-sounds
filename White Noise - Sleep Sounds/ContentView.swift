import SwiftUI

struct ContentView: View {
    @State private var player = AudioPlayerViewModel()
    @State private var favorites = FavoritesManager()
    @State private var mixesManager = MixesManager()
    @State private var selectedTab = 0
    var storeManager: StoreManager
    var settings: SettingsManager

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Sounds", systemImage: "waveform", value: 0) {
                SoundsListView(
                    player: player,
                    favorites: favorites,
                    storeManager: storeManager,
                    selectedTab: $selectedTab
                )
            }

            Tab("Now Playing", systemImage: "play.circle.fill", value: 1) {
                NowPlayingView(
                    player: player,
                    favorites: favorites,
                    mixesManager: mixesManager
                )
            }

            Tab("Mixes", systemImage: "square.stack.3d.up.fill", value: 2) {
                MixesView(
                    player: player,
                    mixesManager: mixesManager
                )
            }

            Tab("Favorites", systemImage: "heart.fill", value: 3) {
                FavoritesView(
                    player: player,
                    favorites: favorites,
                    storeManager: storeManager,
                    selectedTab: $selectedTab
                )
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 4) {
                SettingsView(
                    storeManager: storeManager,
                    settings: settings
                )
            }
        }
        .tint(Color.appAccent)
        .preferredColorScheme(.dark)
    }
}
