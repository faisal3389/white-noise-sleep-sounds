import SwiftUI

struct ContentView: View {
    @State private var player = AudioPlayerViewModel()
    @State private var favorites = FavoritesManager()
    @State private var mixesManager = MixesManager()
    @State private var timerManager = TimerManager()
    @State private var playlistManager = PlaylistManager()
    @State private var sleepLog = SleepLogManager()
    @State private var customSoundsManager = CustomSoundsManager()
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

            ScenesView(
                player: player,
                favorites: favorites,
                storeManager: storeManager,
                selectedTab: $selectedTab
            )
            .tabItem {
                Label("Scenes", systemImage: "sparkles.rectangle.stack")
            }
            .tag(1)

            NowPlayingView(
                player: player,
                favorites: favorites,
                timerManager: timerManager,
                mixesManager: mixesManager
            )
            .tabItem {
                Label("Now Playing", systemImage: "play.circle.fill")
            }
            .tag(2)

            MixesView(
                player: player,
                mixesManager: mixesManager
            )
            .tabItem {
                Label("Mixes", systemImage: "square.stack.3d.up.fill")
            }
            .tag(3)

            MoreView(
                player: player,
                favorites: favorites,
                storeManager: storeManager,
                settings: settings,
                playlistManager: playlistManager,
                sleepLog: sleepLog,
                customSoundsManager: customSoundsManager,
                selectedTab: $selectedTab
            )
            .tabItem {
                Label("More", systemImage: "ellipsis.circle.fill")
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
                // Log the sleep session before stopping
                sleepLog.endSession()
                player.stop()
                playlistManager.stopPlaylist()
            }
            timerManager.onFadeOut = { volume in
                player.setVolume(volume * player.volume)
            }

            // Wire playlist playback
            playlistManager.onPlaySound = { sound in
                player.play(sound: sound)
            }
            playlistManager.onPlaylistFinished = {
                player.stop()
            }
        }
        .onChange(of: player.isPlaying) { _, isPlaying in
            if isPlaying {
                let soundName = player.displayTitle
                let soundId = player.currentSound?.id
                let mixName = player.currentMix?.name
                sleepLog.startSession(soundName: soundName, soundId: soundId, mixName: mixName)
            } else if !isPlaying && player.currentSound == nil && player.currentMix == nil {
                sleepLog.endSession()
            }
        }
    }
}
