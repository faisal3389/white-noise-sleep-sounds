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
    @State private var showShareSheet = false
    @State private var showNotificationDeniedAlert = false
    private let analytics = AnalyticsManager.shared
    private let notifications = NotificationManager.shared

    private let appStoreURL = URL(string: "https://apps.apple.com/us/app/white-noise-sleep-sounds/id6762322017")!
    private let rateURL = URL(string: "https://apps.apple.com/us/app/white-noise-sleep-sounds/id6762322017?action=write-review")!
    private let privacyURL = URL(string: "https://www.privacypolicies.com/live/151d345f-90aa-4907-86fc-86bf638dd911")!

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

                    if storeManager.isPremium {
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
                    } else {
                        Button { showPremiumSheet = true } label: {
                            Label {
                                HStack {
                                    Text("Playlist")
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                            } icon: {
                                Image(systemName: "list.bullet.rectangle.portrait")
                                    .foregroundStyle(Color.appAccent)
                            }
                        }
                        .listRowBackground(Color.appSurface)
                    }

                    if storeManager.isPremium {
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
                    } else {
                        Button { showPremiumSheet = true } label: {
                            Label {
                                HStack {
                                    Text("Sleep Log")
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                            } icon: {
                                Image(systemName: "bed.double.fill")
                                    .foregroundStyle(Color.appAccent)
                            }
                        }
                        .listRowBackground(Color.appSurface)
                    }

                    if storeManager.isPremium {
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
                    } else {
                        Button { showPremiumSheet = true } label: {
                            Label {
                                HStack {
                                    Text("My Sounds")
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                            } icon: {
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundStyle(Color.appAccent)
                            }
                        }
                        .listRowBackground(Color.appSurface)
                    }
                }

                // MARK: - Premium Section
                Section("Premium") {
                    Button {
                        if !storeManager.isPremium {
                            analytics.track(.premiumSheetViewed, properties: ["source": "more_tab"])
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
                                Text(storeManager.priceString.isEmpty ? "Premium" : storeManager.priceString)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                    }
                    .listRowBackground(Color.appSurface)

                    Button {
                        analytics.track(.restorePurchasesTapped)
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

                // MARK: - Lock Screen Section
                Section {
                    Toggle(isOn: Binding(
                        get: { settings.liveActivitiesEnabled },
                        set: { newValue in
                            settings.liveActivitiesEnabled = newValue
                            analytics.track(.liveActivityToggled, properties: ["enabled": newValue])
                        }
                    )) {
                        Label("Live Activity", systemImage: "rectangle.badge.person.crop")
                            .foregroundStyle(.white)
                    }
                    .tint(Color.appAccent)
                    .listRowBackground(Color.appSurface)

                    Text("Shows the current sound and sleep timer on your Lock Screen and Dynamic Island.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                        .listRowBackground(Color.appSurface)
                } header: {
                    Text("Lock Screen")
                }

                // MARK: - Bedtime Reminder Section
                Section {
                    Toggle(isOn: Binding(
                        get: { notifications.isEnabled },
                        set: { newValue in
                            if newValue {
                                Task {
                                    let granted = await notifications.enable()
                                    analytics.track(.bedtimeReminderToggled, properties: ["enabled": granted])
                                    if !granted { showNotificationDeniedAlert = true }
                                }
                            } else {
                                notifications.disable()
                                analytics.track(.bedtimeReminderToggled, properties: ["enabled": false])
                            }
                        }
                    )) {
                        Label("Bedtime Reminder", systemImage: "bell.badge")
                            .foregroundStyle(.white)
                    }
                    .tint(Color.appAccent)
                    .listRowBackground(Color.appSurface)

                    if notifications.isEnabled {
                        DatePicker(
                            selection: Binding(
                                get: { notifications.reminderDate },
                                set: { newDate in
                                    notifications.reminderDate = newDate
                                    let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                    analytics.track(.bedtimeReminderTimeChanged, properties: [
                                        "hour": comps.hour ?? 0,
                                        "minute": comps.minute ?? 0
                                    ])
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        ) {
                            Label("Remind Me At", systemImage: "clock")
                                .foregroundStyle(.white)
                        }
                        .tint(Color.appAccent)
                        .listRowBackground(Color.appSurface)
                    }

                    Text("A quiet nudge each night to wind down. No sound — just a notification.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                        .listRowBackground(Color.appSurface)
                } header: {
                    Text("Bedtime Reminder")
                }

                // MARK: - Siri Section
                Section {
                    Button {
                        analytics.track(.siriSettingsOpened)
                        if let url = URL(string: "shortcuts://") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label {
                            HStack {
                                Text("Set Up Siri Shortcuts")
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                        } icon: {
                            Image(systemName: "mic.fill")
                                .foregroundStyle(Color.appAccent)
                        }
                    }
                    .listRowBackground(Color.appSurface)

                    Text("Try \"Hey Siri, play white noise\", \"start sleep timer\", or \"open sleep clock\".")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                        .listRowBackground(Color.appSurface)
                } header: {
                    Text("Siri")
                }

                // MARK: - Playback Section
                Section("Playback") {
                    HStack {
                        Label("Fade Duration", systemImage: "waveform.path")
                            .foregroundStyle(.white)
                        Spacer()
                        Picker("", selection: Binding(
                            get: { settings.fadeDuration },
                            set: { newValue in
                                settings.fadeDuration = newValue
                                analytics.track(.fadeDurationChanged, properties: ["duration": newValue])
                            }
                        )) {
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
                    Button {
                        analytics.track(.rateAppTapped)
                        UIApplication.shared.open(rateURL)
                    } label: {
                        Label("Rate on App Store", systemImage: "star.bubble")
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.appSurface)

                    Button {
                        analytics.track(.shareAppTapped)
                        showShareSheet = true
                    } label: {
                        Label("Share with Friends", systemImage: "square.and.arrow.up")
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.appSurface)

                    Button {
                        analytics.track(.privacyPolicyTapped)
                        UIApplication.shared.open(privacyURL)
                    } label: {
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
            .contentMargins(.bottom, player.currentSound != nil || player.currentMix != nil ? 70 : 0, for: .scrollContent)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("More")
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showPremiumSheet) {
                PremiumUpgradeView(storeManager: storeManager)
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityView(activityItems: [
                    "I've been falling asleep to this — give it a try.",
                    appStoreURL
                ])
            }
            .alert("Notifications Off", isPresented: $showNotificationDeniedAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Not Now", role: .cancel) {}
            } message: {
                Text("Enable notifications for White Noise in Settings to use bedtime reminders.")
            }
        }
    }
}

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
