import SwiftUI

struct DiscoverView: View {
    @Bindable var player: AudioPlayerViewModel
    @Bindable var favorites: FavoritesManager
    var storeManager: StoreManager
    @Binding var selectedTab: Int
    @Binding var discoverCategory: SoundCategory?

    @State private var searchText = ""
    @State private var selectedCategory: SoundCategory? = nil
    @State private var showPremiumSheet = false
    @State private var appearedCards: Set<String> = []

    private var filteredSounds: [Sound] {
        var sounds = SoundLibrary.allSounds

        if let category = selectedCategory {
            sounds = sounds.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            sounds = sounds.filter { $0.name.lowercased().contains(query) }
        }

        return sounds
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            VStack(alignment: .leading, spacing: 16) {
                Text("Discover")
                    .font(DS.Typography.displayLg)
                    .foregroundStyle(.white)
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.top, DS.Spacing.lg)

                // Search bar
                searchBar

                // Category pills
                categoryPills
            }

            // MARK: - Results
            ScrollView(.vertical, showsIndicators: false) {
                // Results count
                HStack {
                    Text("\(filteredSounds.count) sounds")
                        .font(DS.Typography.bodySm)
                        .foregroundStyle(.white.opacity(0.4))
                    Spacer()
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.top, 12)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(filteredSounds.enumerated()), id: \.element.id) { index, sound in
                        SoundCardView(
                            sound: sound,
                            style: .portrait,
                            isFavorite: favorites.isFavorite(sound),
                            isPlaying: player.currentSound?.id == sound.id && player.isPlaying,
                            isLocked: sound.isPremium && !storeManager.isPremium,
                            onTap: {
                                if sound.isPremium && !storeManager.isPremium {
                                    AnalyticsManager.shared.track(.premiumLockedContentTapped, properties: ["sound_id": sound.id, "source": "discover"])
                                    showPremiumSheet = true
                                } else {
                                    player.play(sound: sound)
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    selectedTab = 2
                                }
                            },
                            onFavorite: {
                                let wasFavorite = favorites.isFavorite(sound)
                                favorites.toggle(sound)
                                AnalyticsManager.shared.track(wasFavorite ? .soundUnfavorited : .soundFavorited, properties: ["sound_id": sound.id, "sound_name": sound.name, "source": "discover"])
                            }
                        )
                        .frame(height: 180)
                        .staggeredAppear(index: index, appearedCards: $appearedCards, id: "disc_\(sound.id)")
                    }
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.bottom, 120)
            }

            AdBannerContainer(isPremium: storeManager.isPremium)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .sheet(isPresented: $showPremiumSheet) {
            PremiumUpgradeView(storeManager: storeManager)
        }
        .onChange(of: selectedCategory) { _, newCat in
            // Reset appeared cards when category changes for fresh animations
            appearedCards.removeAll()
            if let cat = newCat {
                AnalyticsManager.shared.track(.categorySelected, properties: ["category": cat.rawValue, "source": "discover"])
            }
        }
        .onChange(of: searchText) { _, newText in
            if !newText.isEmpty && newText.count >= 3 {
                AnalyticsManager.shared.track(.searchPerformed, properties: ["query": newText, "results_count": filteredSounds.count])
            }
        }
        .onAppear {
            if let category = discoverCategory {
                selectedCategory = category
                discoverCategory = nil
            }
        }
        .onChange(of: discoverCategory) { _, newCategory in
            if let category = newCategory {
                selectedCategory = category
                discoverCategory = nil
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.4))

            TextField("Search sounds...", text: $searchText)
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.vertical, DS.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .fill(Color.surfaceContainerLow)
        )
        .padding(.horizontal, DS.Spacing.lg)
    }

    // MARK: - Category Pills

    private var categoryPills: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // "All" pill
                    categoryPill(title: "All", icon: "square.grid.2x2", isSelected: selectedCategory == nil) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = nil
                        }
                    }
                    .id("category_all")

                    ForEach(SoundCategory.allCases) { category in
                        categoryPill(
                            title: category.rawValue,
                            icon: category.iconName,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        }
                        .id("category_\(category.rawValue)")
                    }
                }
                .padding(.horizontal, DS.Spacing.lg)
            }
            .onChange(of: selectedCategory) { _, newCategory in
                withAnimation {
                    if let category = newCategory {
                        proxy.scrollTo("category_\(category.rawValue)", anchor: .center)
                    } else {
                        proxy.scrollTo("category_all", anchor: .center)
                    }
                }
            }
            .onAppear {
                if let category = selectedCategory {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo("category_\(category.rawValue)", anchor: .center)
                        }
                    }
                }
            }
        }
    }

    private func categoryPill(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))

                Text(title)
                    .font(DS.Typography.labelMd)
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.vertical, DS.Spacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? Color.appAccent : Color.surfaceContainerHigh)
            )
            .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
        }
        .buttonStyle(.plain)
    }
}
