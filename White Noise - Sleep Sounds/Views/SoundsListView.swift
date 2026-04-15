import SwiftUI

struct SoundsListView: View {
    @Bindable var player: AudioPlayerViewModel
    @Bindable var favorites: FavoritesManager
    var storeManager: StoreManager
    @Binding var selectedTab: Int
    @State private var searchText = ""
    @State private var showPremiumSheet = false

    private var filteredGroups: [(category: SoundCategory, sounds: [Sound])] {
        if searchText.isEmpty {
            return SoundLibrary.groupedByCategory
        }
        let query = searchText.lowercased()
        return SoundLibrary.groupedByCategory.compactMap { group in
            let filtered = group.sounds.filter { $0.name.lowercased().contains(query) }
            return filtered.isEmpty ? nil : (group.category, filtered)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    ForEach(filteredGroups, id: \.category) { group in
                        Section {
                            ForEach(group.sounds) { sound in
                                SoundRowView(
                                    sound: sound,
                                    isFavorite: favorites.isFavorite(sound),
                                    onFavoriteToggle: { favorites.toggle(sound) }
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if sound.isPremium && !storeManager.isPremium {
                                        showPremiumSheet = true
                                    } else {
                                        player.play(sound: sound)
                                        selectedTab = 1
                                    }
                                }
                                .listRowBackground(Color.appBackground)
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

                AdBannerContainer(isPremium: storeManager.isPremium)
            }
            .background(Color.appBackground)
            .navigationTitle("Sounds")
            .searchable(text: $searchText, prompt: "Search sounds")
            .sheet(isPresented: $showPremiumSheet) {
                PremiumUpgradeView(storeManager: storeManager)
            }
        }
    }
}
