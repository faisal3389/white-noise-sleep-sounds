import SwiftUI

struct PlaylistView: View {
    @Bindable var playlistManager: PlaylistManager
    @Bindable var player: AudioPlayerViewModel
    @Bindable var favorites: FavoritesManager
    var storeManager: StoreManager
    @Binding var selectedTab: Int

    @State private var showAddSheet = false
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if playlistManager.items.isEmpty {
                    emptyState
                } else {
                    playlistContent
                }

                AdBannerContainer(isPremium: storeManager.isPremium)
            }
            .background(Color.appBackground)
            .navigationTitle("Playlist")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !playlistManager.items.isEmpty {
                        EditButton()
                            .foregroundStyle(Color.appAccent)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.appAccent)
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .sheet(isPresented: $showAddSheet) {
                AddToPlaylistSheet(
                    playlistManager: playlistManager,
                    storeManager: storeManager
                )
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "list.bullet.rectangle.portrait")
                .font(.system(size: 70))
                .foregroundStyle(Color.appAccent.opacity(0.5))

            Text("No Sounds in Queue")
                .font(.title2.weight(.medium))
                .foregroundStyle(.white.opacity(0.7))

            Text("Add sounds to build a playlist that plays in sequence.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                showAddSheet = true
            } label: {
                Label("Add Sounds", systemImage: "plus.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.appAccent)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var playlistContent: some View {
        VStack(spacing: 0) {
            // Playback controls
            if !playlistManager.items.isEmpty {
                HStack(spacing: 12) {
                    Button {
                        playlistManager.startPlaylist()
                        selectedTab = 2 // Switch to Now Playing
                    } label: {
                        Label(
                            playlistManager.isActive ? "Restart" : "Play All",
                            systemImage: "play.fill"
                        )
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.appAccent)
                        .clipShape(Capsule())
                    }

                    if playlistManager.isActive {
                        Button {
                            playlistManager.stopPlaylist()
                        } label: {
                            Label("Stop", systemImage: "stop.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.appSurface)
                                .clipShape(Capsule())
                        }
                    }

                    Spacer()

                    Button {
                        playlistManager.clearPlaylist()
                    } label: {
                        Text("Clear")
                            .font(.system(size: 14))
                            .foregroundStyle(.red.opacity(0.8))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

            List {
                ForEach(Array(playlistManager.items.enumerated()), id: \.element.id) { index, item in
                    if let sound = item.sound {
                        playlistRow(sound: sound, item: item, index: index)
                            .listRowBackground(
                                (playlistManager.isActive && playlistManager.currentIndex == index)
                                    ? Color.appAccent.opacity(0.15)
                                    : Color.appSurface.opacity(0.5)
                            )
                    }
                }
                .onDelete { offsets in
                    playlistManager.removeItem(at: offsets)
                }
                .onMove { source, destination in
                    playlistManager.moveItem(from: source, to: destination)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private func playlistRow(sound: Sound, item: PlaylistItem, index: Int) -> some View {
        Button {
            playlistManager.startPlaylist(from: index)
            selectedTab = 2
        } label: {
            HStack(spacing: 12) {
                // Playing indicator
                if playlistManager.isActive && playlistManager.currentIndex == index {
                    Image(systemName: player.isPlaying ? "speaker.wave.2.fill" : "speaker.fill")
                        .font(.caption)
                        .foregroundStyle(Color.appAccent)
                        .frame(width: 20)
                } else {
                    Text("\(index + 1)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(width: 20)
                }

                // Sound icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appSurface)
                        .frame(width: 44, height: 44)

                    Image(sound.backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .opacity(0.7)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(sound.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)

                    if let minutes = item.durationMinutes {
                        Text("\(minutes) min")
                            .font(.caption)
                            .foregroundStyle(Color.appAccent.opacity(0.8))
                    } else {
                        Text("Until next")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }

                Spacer()

                // Duration menu
                Menu {
                    Button("No limit") {
                        playlistManager.setDuration(for: item.id, minutes: nil)
                    }
                    ForEach([5, 10, 15, 30, 60], id: \.self) { mins in
                        Button("\(mins) minutes") {
                            playlistManager.setDuration(for: item.id, minutes: mins)
                        }
                    }
                } label: {
                    Image(systemName: "timer")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(width: 32, height: 32)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add to Playlist Sheet

struct AddToPlaylistSheet: View {
    var playlistManager: PlaylistManager
    var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                List {
                    ForEach(SoundLibrary.groupedByCategory, id: \.category) { group in
                        Section {
                            ForEach(group.sounds) { sound in
                                Button {
                                    if sound.isPremium && !storeManager.isPremium {
                                        // Skip premium sounds for free users
                                    } else {
                                        playlistManager.addSound(sound)
                                    }
                                } label: {
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
                                                .opacity(0.7)
                                        }

                                        Text(sound.name)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(.white)

                                        Spacer()

                                        if sound.isPremium && !storeManager.isPremium {
                                            Image(systemName: "lock.fill")
                                                .font(.caption)
                                                .foregroundStyle(.white.opacity(0.4))
                                        } else {
                                            Image(systemName: "plus.circle")
                                                .foregroundStyle(Color.appAccent)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color.appSurface.opacity(0.5))
                            }
                        } header: {
                            Text(group.category.rawValue)
                                .font(.headline)
                                .foregroundStyle(Color.appAccent)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add to Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.appAccent)
                }
            }
            .toolbarBackground(Color.appSurface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}
