import SwiftUI

struct SoundScene: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let category: SoundCategory
    let icon: String
    let backgroundImage: String
    let isPremium: Bool

    static let allScenes: [SoundScene] = [
        SoundScene(id: "rainfall", name: "Rainfall", subtitle: "Gentle to heavy rain", category: .rain, icon: "cloud.rain.fill", backgroundImage: "bg_heavy_rain", isPremium: false),
        SoundScene(id: "forest", name: "Forest", subtitle: "Birds, leaves, and wildlife", category: .nature, icon: "leaf.fill", backgroundImage: "bg_forest", isPremium: false),
        SoundScene(id: "ocean_water", name: "Ocean & Water", subtitle: "Waves, rivers, and waterfalls", category: .water, icon: "water.waves", backgroundImage: "bg_ocean_waves", isPremium: false),
        SoundScene(id: "urban_night", name: "Urban Night", subtitle: "City streets, cafes, and trains", category: .urban, icon: "building.2.fill", backgroundImage: "bg_city_traffic", isPremium: false),
        SoundScene(id: "machines", name: "Machines & Fans", subtitle: "Mechanical white noise", category: .machine, icon: "fan.fill", backgroundImage: "bg_fan", isPremium: false),
        SoundScene(id: "fireside", name: "Fireside", subtitle: "Campfires and candlelight", category: .fire, icon: "flame.fill", backgroundImage: "bg_campfire", isPremium: false),
        SoundScene(id: "cosmic", name: "Cosmic", subtitle: "Generated noise textures", category: .noise, icon: "sparkles", backgroundImage: "bg_white_noise", isPremium: false),
        SoundScene(id: "premium", name: "Premium Collection", subtitle: "12 exclusive sounds", category: .premium, icon: "star.fill", backgroundImage: "bg_northern_lights", isPremium: true),
    ]
}

struct ScenesView: View {
    @Bindable var player: AudioPlayerViewModel
    @Bindable var favorites: FavoritesManager
    var storeManager: StoreManager
    @Binding var selectedTab: Int

    @State private var selectedScene: SoundScene?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(SoundScene.allScenes) { scene in
                        sceneCard(scene)
                    }
                }
                .padding(16)
            }
            .background(Color.appBackground)
            .navigationTitle("Scenes")
            .navigationDestination(item: $selectedScene) { scene in
                SceneDetailView(
                    scene: scene,
                    player: player,
                    favorites: favorites,
                    storeManager: storeManager,
                    selectedTab: $selectedTab
                )
            }
        }
    }

    @State private var showPremiumSheet = false

    private func sceneCard(_ scene: SoundScene) -> some View {
        Button {
            if scene.isPremium && !storeManager.isPremium {
                showPremiumSheet = true
            } else {
                selectedScene = scene
            }
        } label: {
            ZStack(alignment: .bottomLeading) {
                // Background
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.appSurface)

                    Image(scene.backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .opacity(0.6)

                    // Gradient overlay
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Lock overlay for premium scene
                    if scene.isPremium && !storeManager.isPremium {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.appAccent.opacity(0.1))
                            .overlay(
                                Image(systemName: "lock.fill")
                                    .font(.title)
                                    .foregroundStyle(Color.appAccent)
                            )
                    }
                }
                .frame(height: 160)

                // Content
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: scene.icon)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appAccent)

                        Text(scene.name)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(scene.subtitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    Spacer()

                    let count = SoundLibrary.sounds(for: scene.category).count
                    let label = scene.isPremium ? "\(count) sounds — Premium" : "\(count) sounds"
                    Text(label)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
                .padding(20)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPremiumSheet) {
            PremiumUpgradeView(storeManager: storeManager)
        }
    }
}

// MARK: - Scene Detail

struct SceneDetailView: View {
    let scene: SoundScene
    @Bindable var player: AudioPlayerViewModel
    @Bindable var favorites: FavoritesManager
    var storeManager: StoreManager
    @Binding var selectedTab: Int
    @State private var showPremiumSheet = false

    private var sounds: [Sound] {
        SoundLibrary.sounds(for: scene.category)
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Hero header
                    ZStack(alignment: .bottomLeading) {
                        Image(scene.backgroundImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 220)
                            .clipped()
                            .opacity(0.5)

                        LinearGradient(
                            colors: [.clear, Color.appBackground],
                            startPoint: .top,
                            endPoint: .bottom
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            Image(systemName: scene.icon)
                                .font(.title2)
                                .foregroundStyle(Color.appAccent)

                            Text(scene.name)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text(scene.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding(20)
                    }
                    .frame(height: 220)

                    // Sound list
                    LazyVStack(spacing: 0) {
                        ForEach(sounds) { sound in
                            Button {
                                if sound.isPremium && !storeManager.isPremium {
                                    showPremiumSheet = true
                                } else {
                                    player.play(sound: sound)
                                    selectedTab = 2
                                }
                            } label: {
                                SoundRowView(
                                    sound: sound,
                                    isFavorite: favorites.isFavorite(sound),
                                    onFavoriteToggle: { favorites.toggle(sound) }
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPremiumSheet) {
            PremiumUpgradeView(storeManager: storeManager)
        }
    }
}

// Make Scene work with navigationDestination
extension SoundScene: Hashable {
    static func == (lhs: SoundScene, rhs: SoundScene) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
