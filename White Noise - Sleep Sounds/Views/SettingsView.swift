// SettingsView is now replaced by MoreView which consolidates
// Favorites, Playlist, Sleep Log, Import Sounds, and Settings into one tab.
// This file is kept for backwards compatibility but MoreView is the active view.

import SwiftUI

struct SettingsView: View {
    var storeManager: StoreManager
    @Bindable var settings: SettingsManager
    @State private var showPremiumSheet = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            List {
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
                                Text("$0.99")
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
            .navigationTitle("Settings")
            .sheet(isPresented: $showPremiumSheet) {
                PremiumUpgradeView(storeManager: storeManager)
            }
        }
    }
}
