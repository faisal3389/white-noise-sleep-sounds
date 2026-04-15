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
    @State private var discoverCategory: SoundCategory? = nil
    @State private var showSleepClock = false
    var storeManager: StoreManager
    var settings: SettingsManager
    @Binding var deepLinkSoundId: String?
    @Binding var deepLinkAction: RootView.DeepLinkAction?

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
            miniPlayerOverlay
        }
        .onAppear {
            // Glass morphism tab bar
            configureGlassTabBar()

            timerManager.onTimerComplete = {
                sleepLog.endSession()
                player.stop()
                playlistManager.stopPlaylist()
            }
            timerManager.onFadeOut = { volume in
                player.setVolume(volume * player.volume)
            }

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
        .onChange(of: deepLinkAction) { _, action in
            guard let action else { return }
            handleDeepLinkAction(action)
            deepLinkAction = nil
        }
        .onChange(of: favorites.favoritedIDs) { _, ids in
            SharedPlaybackState.updateFavorites(Array(ids))
        }
        .onChange(of: AppShortcutAction.shared.pendingAction) { _, action in
            guard let action else { return }
            handleShortcutAction(action)
            AppShortcutAction.shared.pendingAction = nil
        }
        .fullScreenCover(isPresented: $showSleepClock) {
            SleepClockView(player: player, timerManager: timerManager)
        }
    }

    // MARK: - Tab Content

    private var tabContent: some View {
        TabView(selection: $selectedTab) {
            homeTab
            discoverTab
            nowPlayingTab
            mixesTab
            moreTab
        }
        .tint(Color.appAccent)
        .preferredColorScheme(.dark)
    }

    private var homeTab: some View {
        HomeView(
            player: player,
            favorites: favorites,
            storeManager: storeManager,
            selectedTab: $selectedTab,
            discoverCategory: $discoverCategory
        )
        .tabItem { Label("Home", systemImage: "house.fill") }
        .tag(0)
    }

    private var discoverTab: some View {
        DiscoverView(
            player: player,
            favorites: favorites,
            storeManager: storeManager,
            selectedTab: $selectedTab,
            discoverCategory: $discoverCategory
        )
        .tabItem { Label("Discover", systemImage: "magnifyingglass") }
        .tag(1)
    }

    private var nowPlayingTab: some View {
        NowPlayingView(
            player: player,
            favorites: favorites,
            timerManager: timerManager,
            mixesManager: mixesManager
        )
        .tabItem { Label("Now Playing", systemImage: "play.circle.fill") }
        .tag(2)
    }

    private var mixesTab: some View {
        MixesView(
            player: player,
            mixesManager: mixesManager,
            storeManager: storeManager
        )
        .tabItem { Label("Mixes", systemImage: "square.stack.3d.up.fill") }
        .tag(3)
    }

    private var moreTab: some View {
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
        .tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
        .tag(4)
    }

    // MARK: - Mini Player

    @ViewBuilder
    private var miniPlayerOverlay: some View {
        if selectedTab != 2 {
            MiniPlayerView(player: player) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    selectedTab = 2
                }
            }
            .padding(.bottom, 58)
        }
    }

    // MARK: - Glass Tab Bar

    private func configureGlassTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        appearance.backgroundColor = UIColor(Color.appSurface.opacity(0.3))

        // Active tab color
        let activeColor = UIColor(Color.appAccent)
        let inactiveColor = UIColor(Color.white.opacity(0.4))

        let normalAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: inactiveColor]
        let selectedAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: activeColor]

        appearance.stackedLayoutAppearance.normal.iconColor = inactiveColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.selected.iconColor = activeColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    // MARK: - Navigation

    private func handleShortcutAction(_ action: AppShortcutAction.Action) {
        switch action {
        case .playSound(let soundId):
            if let sound = SoundLibrary.allSounds.first(where: { $0.id == soundId }) {
                player.play(sound: sound)
                selectedTab = 2
            }
        case .startTimer(let minutes):
            timerManager.startTimer(minutes: minutes)
            selectedTab = 2
        case .openSleepClock:
            showSleepClock = true
        case .toggle:
            player.togglePlayPause()
            selectedTab = 2
        }
    }

    private func handleDeepLinkAction(_ action: RootView.DeepLinkAction) {
        switch action {
        case .nowPlaying:
            selectedTab = 2
        case .toggle:
            player.togglePlayPause()
            selectedTab = 2
        case .playSound(let soundId):
            if let sound = SoundLibrary.allSounds.first(where: { $0.id == soundId }) {
                player.play(sound: sound)
                selectedTab = 2
            }
        }
    }
}
