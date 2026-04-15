import SwiftUI

struct NowPlayingView: View {
    @Bindable var player: AudioPlayerViewModel
    @Bindable var favorites: FavoritesManager
    @Bindable var timerManager: TimerManager
    var mixesManager: MixesManager?

    @State private var showMixerSheet = false
    @State private var showTimerSheet = false
    @State private var showSleepClock = false

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
                }
            )
            .presentationDetents([.large])
        }
        .fullScreenCover(isPresented: $showSleepClock) {
            SleepClockView(player: player, timerManager: timerManager)
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
                #if os(iOS)
                AirPlayButton()
                    .frame(width: 36, height: 36)
                #endif

                Spacer()

                // Sleep clock button
                Button {
                    showSleepClock = true
                } label: {
                    Image(systemName: "clock.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.8))
                }

                // Timer button
                Button {
                    showTimerSheet = true
                } label: {
                    Image(systemName: "moon.fill")
                        .font(.title2)
                        .foregroundStyle(timerManager.isTimerActive ? Color.appAccent : .white.opacity(0.8))
                }

                // Mixer button (active when mix is playing)
                if player.currentMix != nil {
                    Button {
                        showMixerSheet = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title2)
                            .foregroundStyle(player.isMixPlaying ? Color.appAccent : .white)
                    }
                }

                if let sound = player.currentSound {
                    Button {
                        favorites.toggle(sound)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: favorites.isFavorite(sound) ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundStyle(favorites.isFavorite(sound) ? Color.appAccent : .white)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            VStack(spacing: 8) {
                Text(player.displayTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 4, y: 2)

                Text(player.displaySubtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))

                if timerManager.isTimerActive {
                    Text("Sleep timer: \(timerManager.remainingFormatted)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.appAccent)
                        .padding(.top, 4)
                }
            }

            Spacer()

            // Transport controls
            HStack(spacing: 28) {
                // Shuffle
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
                    if let mix = player.currentMix, let manager = mixesManager {
                        player.previousMix(in: manager.mixes)
                    } else {
                        player.previous()
                    }
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(.white)
                }

                Button {
                    player.togglePlayPause()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.white)
                }

                Button {
                    if let mix = player.currentMix, let manager = mixesManager {
                        player.nextMix(in: manager.mixes)
                    } else {
                        player.next()
                    }
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(.white)
                }

                // Loop
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
                .tint(.white)
                .frame(width: 200)

                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.top, 32)
            .padding(.bottom, 60)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.appAccent.opacity(0.6))

            Text("Pick a sound to begin")
                .font(.title2.weight(.medium))
                .foregroundStyle(.white.opacity(0.7))

            Text("Go to the Sounds tab to choose a sound")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
        }
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
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.onSurface)
                                .padding(.top, 8)

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
            .toolbarBackground(Color.appSurface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }

    private func mixerRow(sound: Sound, component: MixComponent) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appSurface)
                    .frame(width: 40, height: 40)

                Image(sound.backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .opacity(0.6)
            }

            Text(sound.name)
                .font(.system(size: 14, weight: .medium))
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
                .font(.system(size: 12))
                .foregroundStyle(Color.onSurfaceVariant)
                .frame(width: 36)
        }
        .padding(12)
        .background(Color.appSurface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
