import SwiftUI

struct FavoritesView: View {
    @Bindable var player: AudioPlayerViewModel
    @Bindable var favorites: FavoritesManager
    var storeManager: StoreManager
    @Binding var selectedTab: Int
    @State private var showPremiumSheet = false

    private var favoriteSounds: [Sound] {
        SoundLibrary.allSounds.filter { favorites.isFavorite($0) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Group {
                    if favoriteSounds.isEmpty {
                        emptyState
                    } else {
                        List {
                            ForEach(favoriteSounds) { sound in
                                Button {
                                    if sound.isPremium && !storeManager.isPremium {
                                        showPremiumSheet = true
                                    } else {
                                        player.play(sound: sound)
                                        selectedTab = 1
                                    }
                                } label: {
                                    SoundRowView(
                                        sound: sound,
                                        isFavorite: true,
                                        onFavoriteToggle: { favorites.toggle(sound) }
                                    )
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color.appSurface.opacity(0.5))
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
                .frame(maxHeight: .infinity)

                AdBannerContainer(isPremium: storeManager.isPremium)
            }
            .background(Color.appBackground)
            .navigationTitle("Favorites")
            .sheet(isPresented: $showPremiumSheet) {
                PremiumUpgradeView(storeManager: storeManager)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "heart.slash")
                .font(.system(size: 50))
                .foregroundStyle(.white.opacity(0.3))

            Text("No favorites yet")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.5))

            Text("Tap the heart on any sound")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
