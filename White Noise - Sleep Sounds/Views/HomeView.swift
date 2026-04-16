import SwiftUI

struct HomeView: View {
    @Bindable var player: AudioPlayerViewModel
    @Bindable var favorites: FavoritesManager
    var storeManager: StoreManager
    @Binding var selectedTab: Int
    @Binding var discoverCategory: SoundCategory?

    @State private var showPremiumSheet = false
    @State private var appearedCards: Set<String> = []

    // Featured sounds for the hero section
    private var featuredSounds: [Sound] {
        Array(SoundLibrary.allSounds.filter { !$0.isPremium }.prefix(5))
    }

    // Quick picks - one from each category
    private var quickPicks: [Sound] {
        var picks: [Sound] = []
        for category in SoundCategory.allCases where category != .premium {
            if let sound = SoundLibrary.sounds(for: category).first(where: { !$0.isPremium }) {
                picks.append(sound)
            }
        }
        return picks
    }

    // Recently popular (just a curated selection)
    private var trendingSounds: [Sound] {
        let ids = ["ocean_waves", "brown_noise", "campfire", "heavy_rain", "fan", "forest"]
        return ids.compactMap { id in SoundLibrary.allSounds.first(where: { $0.id == id }) }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: DS.Spacing.section) {
                // MARK: - Greeting Header
                greetingHeader

                // MARK: - Hero Bento Grid
                heroBentoGrid

                // MARK: - Quick Picks
                sectionHeader("Quick Picks", subtitle: "Jump right in")
                quickPicksRow

                // MARK: - Trending
                sectionHeader("Trending", subtitle: "Most popular sounds")
                trendingGrid

                // MARK: - Categories
                sectionHeader("Browse by Category", subtitle: nil)
                categoryGrid

                Spacer(minLength: 120)
            }
            .padding(.horizontal, DS.Spacing.xl)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .sheet(isPresented: $showPremiumSheet) {
            PremiumUpgradeView(storeManager: storeManager)
        }
    }

    // MARK: - Greeting

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Text(greetingText)
                .font(DS.Typography.bodyMd)
                .foregroundStyle(.white.opacity(0.5))

            Text("White Noise")
                .font(DS.Typography.displayLg)
                .foregroundStyle(.white)
        }
        .padding(.top, DS.Spacing.lg)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Sleep well"
        }
    }

    // MARK: - Hero Bento Grid

    private var heroBentoGrid: some View {
        let sounds = featuredSounds
        let spacing: CGFloat = 10
        return GeometryReader { geo in
            let totalWidth = geo.size.width
            let heroWidth = (totalWidth - spacing) * 0.62
            let sideWidth = totalWidth - heroWidth - spacing
            let row2CardWidth = (totalWidth - spacing * 2) / 3

            if sounds.count >= 5 {
                VStack(spacing: spacing) {
                    // Row 1: large hero + tall portrait
                    HStack(spacing: spacing) {
                        soundCard(sounds[0], style: .hero)
                            .frame(width: heroWidth, height: 220)
                            .clipped()

                        soundCard(sounds[1], style: .portrait)
                            .frame(width: sideWidth, height: 220)
                            .clipped()
                    }

                    // Row 2: 3 equal portrait cards
                    HStack(spacing: spacing) {
                        soundCard(sounds[2], style: .portrait)
                            .frame(width: row2CardWidth, height: 150)
                            .clipped()
                        soundCard(sounds[3], style: .portrait)
                            .frame(width: row2CardWidth, height: 150)
                            .clipped()
                        soundCard(sounds[4], style: .portrait)
                            .frame(width: row2CardWidth, height: 150)
                            .clipped()
                    }
                }
            }
        }
        .frame(height: 220 + 10 + 150) // total bento height
    }

    // MARK: - Quick Picks

    private var quickPicksRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.md) {
                ForEach(Array(quickPicks.enumerated()), id: \.element.id) { index, sound in
                    soundCard(sound, style: .portrait)
                        .frame(width: 140, height: 180)
                        .staggeredAppear(index: index, appearedCards: $appearedCards, id: "qp_\(sound.id)")
                }
            }
            .padding(.horizontal, 2)
        }
    }

    // MARK: - Trending Grid

    private var trendingGrid: some View {
        VStack(spacing: 10) {
            ForEach(Array(trendingSounds.enumerated()), id: \.element.id) { index, sound in
                soundCard(sound, style: .landscape)
                    .frame(height: 80)
                    .staggeredAppear(index: index, appearedCards: $appearedCards, id: "tr_\(sound.id)")
            }
        }
    }

    // MARK: - Category Grid

    private var categoryGrid: some View {
        let columns = [GridItem(.flexible(), spacing: DS.Spacing.md), GridItem(.flexible(), spacing: DS.Spacing.md)]
        return LazyVGrid(columns: columns, spacing: DS.Spacing.md) {
            ForEach(Array(SoundCategory.allCases.enumerated()), id: \.element) { index, category in
                categoryCard(category)
                    .staggeredAppear(index: index, appearedCards: $appearedCards, id: "cat_\(category.rawValue)")
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(DS.Typography.headlineLg)
                .foregroundStyle(.white)

            if let subtitle {
                Text(subtitle)
                    .font(DS.Typography.bodySm)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }

    private func soundCard(_ sound: Sound, style: SoundCardStyle) -> some View {
        SoundCardView(
            sound: sound,
            style: style,
            isFavorite: favorites.isFavorite(sound),
            isPlaying: player.currentSound?.id == sound.id && player.isPlaying,
            isLocked: sound.isPremium && !storeManager.isPremium,
            onTap: {
                if sound.isPremium && !storeManager.isPremium {
                    AnalyticsManager.shared.track(.premiumLockedContentTapped, properties: ["sound_id": sound.id, "source": "home"])
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
                AnalyticsManager.shared.track(wasFavorite ? .soundUnfavorited : .soundFavorited, properties: ["sound_id": sound.id, "sound_name": sound.name, "source": "home"])
            }
        )
    }

    private func categoryCard(_ category: SoundCategory) -> some View {
        let sounds = SoundLibrary.sounds(for: category)
        let bgImage = sounds.first?.backgroundImage ?? ""

        return Button {
            AnalyticsManager.shared.track(.categoryBrowsed, properties: ["category": category.rawValue, "source": "home"])
            discoverCategory = category
            selectedTab = 1
        } label: {
            ZStack(alignment: .bottomLeading) {
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.xl)
                        .fill(Color.appSurface)

                    if !bgImage.isEmpty {
                        Image(bgImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl))
                            .opacity(0.5)
                    }

                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl))
                }
                .frame(height: 100)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Image(systemName: category.iconName)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.appAccent)

                        Text(category.rawValue)
                            .font(DS.Typography.labelLg)
                            .foregroundStyle(.white)

                        Text("\(sounds.count) sounds")
                            .font(DS.Typography.labelSm)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Spacer()
                }
                .padding(DS.Spacing.lg)
            }
        }
        .buttonStyle(CardPressStyle())
    }
}

// MARK: - Staggered Appear Modifier

struct StaggeredAppearModifier: ViewModifier {
    let index: Int
    @Binding var appearedCards: Set<String>
    let id: String

    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .onAppear {
                guard !appearedCards.contains(id) else {
                    appeared = true
                    return
                }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.06)) {
                    appeared = true
                }
                appearedCards.insert(id)
            }
    }
}

extension View {
    func staggeredAppear(index: Int, appearedCards: Binding<Set<String>>, id: String) -> some View {
        modifier(StaggeredAppearModifier(index: index, appearedCards: appearedCards, id: id))
    }
}
