import SwiftUI

struct MoreView: View {
    @Bindable var player: AudioPlayerViewModel
    @Bindable var favorites: FavoritesManager
    var storeManager: StoreManager
    @Bindable var settings: SettingsManager
    @Bindable var playlistManager: PlaylistManager
    @Bindable var sleepLog: SleepLogManager
    @Bindable var customSoundsManager: CustomSoundsManager
    @Binding var selectedTab: Int

    @State private var showPremiumSheet = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Features
                Section("Features") {
                    NavigationLink {
                        FavoritesView(
                            player: player,
                            favorites: favorites,
                            storeManager: storeManager,
                            selectedTab: $selectedTab
                        )
                    } label: {
                        Label {
                            HStack {
                                Text("Favorites")
                                    .foregroundStyle(.white)
                                Spacer()
                                let count = favorites.favoritedIDs.count
                                if count > 0 {
                                    Text("\(count)")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                            }
                        } icon: {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(Color.appAccent)
                        }
                    }
                    .listRowBackground(Color.appSurface)

                    NavigationLink {
                        PlaylistView(
                            playlistManager: playlistManager,
                            player: player,
                            favorites: favorites,
                            storeManager: storeManager,
                            selectedTab: $selectedTab
                        )
                    } label: {
                        Label {
                            HStack {
                                Text("Playlist")
                                    .foregroundStyle(.white)
                                Spacer()
                                if playlistManager.isActive {
                                    Text("Playing")
                                        .font(.caption)
                                        .foregroundStyle(Color.appAccent)
                                } else if playlistManager.hasItems {
                                    Text("\(playlistManager.items.count)")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                            }
                        } icon: {
                            Image(systemName: "list.bullet.rectangle.portrait")
                                .foregroundStyle(Color.appAccent)
                        }
                    }
                    .listRowBackground(Color.appSurface)

                    NavigationLink {
                        SleepLogView(sleepLog: sleepLog)
                    } label: {
                        Label {
                            HStack {
                                Text("Sleep Log")
                                    .foregroundStyle(.white)
                                Spacer()
                                if !sleepLog.entries.isEmpty {
                                    Text("\(sleepLog.entries.count) sessions")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                            }
                        } icon: {
                            Image(systemName: "bed.double.fill")
                                .foregroundStyle(Color.appAccent)
                        }
                    }
                    .listRowBackground(Color.appSurface)

                    NavigationLink {
                        ImportSoundView(
                            customSoundsManager: customSoundsManager,
                            player: player,
                            selectedTab: $selectedTab
                        )
                    } label: {
                        Label {
                            HStack {
                                Text("My Sounds")
                                    .foregroundStyle(.white)
                                Spacer()
                                if !customSoundsManager.sounds.isEmpty {
                                    Text("\(customSoundsManager.sounds.count)")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                            }
                        } icon: {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundStyle(Color.appAccent)
                        }
                    }
                    .listRowBackground(Color.appSurface)
                }

                // MARK: - Premium Section
                Section("Premium") {
                    Button {
                        if !storeManager.isPremium {
                            showPremiumSheet = true
                        }
                    } label: {
                        HStack {
                            Label("Upgrade to Premium", systemImage: "star.fill")
                                .foregroundStyle(.white)
                            Spacer()
                            if storeManager.isPremium {
                                Text("Active")
                                    .foregroundStyle(.green)
                            } else {
                                Text("$3.99")
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                    }
                    .listRowBackground(Color.appSurface)

                    Button {
                        Task { await storeManager.restorePurchases() }
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.appSurface)
                }

                // MARK: - Appearance Section
                Section("App Icon") {
                    AppIconPicker()
                }

                // MARK: - Playback Section
                Section("Playback") {
                    HStack {
                        Label("Fade Duration", systemImage: "waveform.path")
                            .foregroundStyle(.white)
                        Spacer()
                        Picker("", selection: $settings.fadeDuration) {
                            Text("0s").tag(0.0)
                            Text("2s").tag(2.0)
                            Text("5s").tag(5.0)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                    }
                    .listRowBackground(Color.appSurface)
                }

                // MARK: - About Section
                Section("About") {
                    Link(destination: URL(string: "https://apps.apple.com/app/id0000000000")!) {
                        Label("Rate on App Store", systemImage: "star.bubble")
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.appSurface)

                    ShareLink(item: URL(string: "https://apps.apple.com/app/id0000000000")!) {
                        Label("Share with Friends", systemImage: "square.and.arrow.up")
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.appSurface)

                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.appSurface)

                    HStack {
                        Label("Version", systemImage: "info.circle")
                            .foregroundStyle(.white)
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .listRowBackground(Color.appSurface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("More")
            .sheet(isPresented: $showPremiumSheet) {
                PremiumUpgradeView(storeManager: storeManager)
            }
        }
    }
}
