import SwiftUI

struct NowPlayingView: View {
    @Bindable var player: AudioPlayerViewModel
    @Bindable var favorites: FavoritesManager
    @Bindable var timerManager: TimerManager
    var storeManager: StoreManager
    var mixesManager: MixesManager?
    @Binding var selectedTab: Int

    @State private var showMixerSheet = false
    @State private var showTimerSheet = false
    @State private var showSleepClock = false
    @State private var showPremiumSheet = false
    @State private var sharingPayload: SharedMixPayload?
    private let analytics = AnalyticsManager.shared

    var body: some View {
        ZStack {
            backgroundLayer

            if player.currentSound != nil || player.currentMix != nil {
                playingContent
            } else {
                emptyState
            }
        }
        .sheet(isPresented: $showMixerSheet) {
            mixerSheet
        }
        .sheet(isPresented: $showTimerSheet) {
            SleepTimerView(
                timerManager: timerManager,
                onStart: {
                    timerManager.startTimer(minutes: timerManager.selectedMinutes)
                },
                onCancel: {
                    timerManager.stopTimer()
                    player.resetFadeGain()
                }
            )
            .presentationDetents([.large])
        }
        .fullScreenCover(isPresented: $showSleepClock) {
            SleepClockView(player: player, timerManager: timerManager)
        }
        .sheet(isPresented: $showPremiumSheet) {
            PremiumUpgradeView(storeManager: storeManager)
        }
        .sheet(item: $sharingPayload) { payload in
            MixShareSheet(payload: payload) { completed in
                analytics.track(
                    completed ? .mixShared : .mixShareCancelled,
                    properties: [
                        "mix_name": payload.name,
                        "component_count": payload.components.count
                    ]
                )
                sharingPayload = nil
            }
        }
        .onAppear {
            analytics.track(.nowPlayingViewed, properties: [
                "has_content": player.currentSound != nil || player.currentMix != nil,
                "is_mix": player.currentMix != nil
            ])
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            let bgImage = player.displayBackgroundImage
            if !bgImage.isEmpty {
                Image(bgImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            }

            Color.appBackground.opacity(player.currentSound != nil || player.currentMix != nil ? 0.5 : 1.0)
                .ignoresSafeArea()

            LinearGradient(
                colors: [.clear, Color.appBackground.opacity(0.9)],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    private var playingContent: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Spacer()

                if let sound = player.currentSound {
                    Button {
                        let wasFavorite = favorites.isFavorite(sound)
                        favorites.toggle(sound)
                        analytics.track(wasFavorite ? .soundUnfavorited : .soundFavorited, properties: ["sound_id": sound.id, "sound_name": sound.name, "source": "now_playing"])
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: favorites.isFavorite(sound) ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundStyle(favorites.isFavorite(sound) ? Color.appAccent : .white.opacity(0.8))
                    }
                } else if let mix = player.currentMix, let manager = mixesManager {
                    Button {
                        let wasFavorite = mix.isFavorite
                        manager.toggleFavorite(mix)
                        analytics.track(wasFavorite ? .soundUnfavorited : .soundFavorited, properties: ["mix_id": mix.id.uuidString, "mix_name": mix.name, "source": "now_playing"])
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: mix.isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundStyle(mix.isFavorite ? Color.appAccent : .white.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, DS.Spacing.xl)
            .padding(.top, DS.Spacing.lg)

            Spacer()

            // Title + subtitle
            VStack(spacing: DS.Spacing.sm) {
                Text(player.displayTitle)
                    .font(DS.Typography.displayHero)
                    .foregroundStyle(.white)
                    .dsShadow(DS.ShadowToken.ambient)
                    .multilineTextAlignment(.center)

                Text(player.displaySubtitle)
                    .font(DS.Typography.bodyMd)
                    .foregroundStyle(Color.appSecondary)

                if timerManager.isTimerActive {
                    Text("Sleep timer: \(timerManager.remainingFormatted)")
                        .font(DS.Typography.labelMd)
                        .foregroundStyle(Color.appAccent)
                        .padding(.top, DS.Spacing.xs)
                }
            }
            .padding(.horizontal, DS.Spacing.xl)

            // Gradient progress bar
            progressBar
                .padding(.top, 28)
                .padding(.horizontal, 32)

            Spacer()

            // Transport controls
            HStack(spacing: 28) {
                Button {
                    player.toggleShuffle()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "shuffle")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(player.isShuffleOn ? Color.appAccent : .white.opacity(0.5))
                }
                .frame(width: 36, height: 36)

                Button {
                    if player.currentMix != nil, let manager = mixesManager {
                        player.previousMix(in: manager.mixes)
                    } else {
                        player.previous()
                    }
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(.white)
                }

                // Play/pause button with gradient
                Button {
                    player.togglePlayPause()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    ZStack {
                        Circle()
                            .fill(LinearGradient.jewelButton)
                            .frame(width: 72, height: 72)
                            .dsShadow(DS.ShadowToken.playButton)

                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color.onPrimary)
                    }
                }

                Button {
                    if player.currentMix != nil, let manager = mixesManager {
                        player.nextMix(in: manager.mixes)
                    } else {
                        player.next()
                    }
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(.white)
                }

                Button {
                    player.cycleLoopMode()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: loopIconName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(player.loopMode != .off ? Color.appAccent : .white.opacity(0.5))
                }
                .frame(width: 36, height: 36)
            }

            // Volume slider
            HStack(spacing: 12) {
                Image(systemName: "speaker.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))

                Slider(value: Binding(
                    get: { player.volume },
                    set: { player.setVolume($0) }
                ), in: 0...1)
                .tint(Color.appAccent)
                .frame(width: 200)

                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.top, 28)

            // Floating action bar
            floatingActionBar
                .padding(.top, 20)
                .padding(.bottom, 40)
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 4)

                // Filled gradient bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [Color.appAccent, Color.appSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: player.isPlaying ? geo.size.width : 0, height: 4)
                    .shadow(color: Color.appAccent.opacity(0.10), radius: 32, y: 0)
                    .animation(.easeInOut(duration: 0.5), value: player.isPlaying)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Floating Action Bar

    private var floatingActionBar: some View {
        HStack(spacing: 28) {
            // Timer (premium)
            actionBarButton(
                icon: "moon.zzz.fill",
                label: "Timer",
                isActive: timerManager.isTimerActive
            ) {
                if storeManager.isPremium {
                    analytics.track(.screenViewed, properties: ["screen": "sleep_timer"])
                    showTimerSheet = true
                } else {
                    showPremiumSheet = true
                }
            }

            // Audio / AirPlay (free for all)
            airPlayActionBarButton

            // Sleep Clock (premium)
            actionBarButton(
                icon: "clock.fill",
                label: "Clock"
            ) {
                if storeManager.isPremium {
                    analytics.track(.sleepClockOpened)
                    showSleepClock = true
                } else {
                    showPremiumSheet = true
                }
            }

            // Mixer (show when mix is playing)
            if player.currentMix != nil {
                actionBarButton(
                    icon: "slider.horizontal.3",
                    label: "Mixer",
                    isActive: player.isMixPlaying
                ) {
                    analytics.track(.mixerSheetOpened, properties: ["mix_name": player.currentMix?.name ?? ""])
                    showMixerSheet = true
                }

                actionBarButton(
                    icon: "square.and.arrow.up",
                    label: "Share"
                ) {
                    guard let mix = player.currentMix,
                          let payload = SharedMixPayload(mix: mix) else { return }
                    analytics.track(.mixShareTapped, properties: [
                        "mix_name": mix.name,
                        "component_count": mix.components.count,
                        "source": "now_playing"
                    ])
                    sharingPayload = payload
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
            Capsule()
                .fill(Color.appBackground.opacity(0.7))
            Capsule()
                .strokeBorder(Color.white.opacity(0.05), lineWidth: 0.5)
        }
        .dsShadow(DS.ShadowToken.floating)
        .padding(.horizontal, DS.Spacing.lg)
    }

    private var airPlayActionBarButton: some View {
        VStack(spacing: 4) {
            #if os(iOS)
            AirPlayButton()
                .frame(width: 24, height: 24)
            #else
            Image(systemName: "airplayaudio")
                .font(.system(size: 18))
                .foregroundStyle(.white.opacity(0.7))
            #endif

            Text("Audio")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(width: 52)
    }

    private func actionBarButton(icon: String, label: String, isActive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(isActive ? Color.appAccent : .white.opacity(0.7))

                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isActive ? Color.appAccent : .white.opacity(0.5))
            }
            .frame(width: 52)
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        Button {
            selectedTab = 0
        } label: {
            VStack(spacing: 20) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.appAccent.opacity(0.6))

                Text("Pick a sound to begin")
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))

                Text("Go to the Home tab to choose a sound")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .buttonStyle(.plain)
    }

    private var loopIconName: String {
        switch player.loopMode {
        case .off: return "repeat"
        case .all: return "repeat"
        case .one: return "repeat.1"
        }
    }

    // MARK: - Mixer Sheet

    private var mixerSheet: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        if let mix = player.currentMix {
                            Text(mix.name)
                                .font(DS.Typography.headlineMd)
                                .foregroundStyle(Color.onSurface)
                                .padding(.top, DS.Spacing.sm)

                            ForEach(player.activeComponents) { component in
                                if let sound = component.sound {
                                    mixerRow(sound: sound, component: component)
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Mixer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showMixerSheet = false
                    }
                    .foregroundStyle(Color.appAccent)
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }

    private func mixerRow(sound: Sound, component: MixComponent) -> some View {
        HStack(spacing: DS.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .fill(Color.appSurface)
                    .frame(width: 40, height: 40)

                Image(sound.thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    .opacity(0.6)
            }

            Text(sound.name)
                .font(DS.Typography.bodyMd.weight(.medium))
                .foregroundStyle(Color.onSurface)
                .frame(width: 80, alignment: .leading)

            Slider(
                value: Binding(
                    get: { component.volume },
                    set: { player.adjustComponentVolume(soundId: component.soundId, volume: $0) }
                ),
                in: 0...1
            )
            .tint(Color.appAccent)

            Text("\(Int(component.volume * 100))%")
                .font(DS.Typography.labelMd)
                .foregroundStyle(Color.onSurfaceVariant)
                .frame(width: 36)
        }
        .padding(DS.Spacing.md)
        .background(Color.appSurface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
    }
}
