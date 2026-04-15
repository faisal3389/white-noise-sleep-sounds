import SwiftUI

struct MixesView: View {
    @Bindable var player: AudioPlayerViewModel
    var mixesManager: MixesManager
    var storeManager: StoreManager

    @State private var showCreateMix = false
    @State private var showPremiumSheet = false
    @State private var editingMix: SoundMix?
    @State private var createHeroPressed = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                createHeroCard
                savedMixesSection
                curatedSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .sheet(isPresented: $showCreateMix) {
            CreateMixView(player: player, mixesManager: mixesManager)
        }
        .sheet(item: $editingMix) { mix in
            CreateMixView(player: player, mixesManager: mixesManager, editingMix: mix)
        }
        .sheet(isPresented: $showPremiumSheet) {
            PremiumUpgradeView(storeManager: storeManager)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mixes")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .tracking(-0.5)
                .foregroundStyle(Color.onSurface)

            Text("Your personal soundscapes, crafted for deep focus and tranquility.")
                .font(.system(size: 16))
                .foregroundStyle(Color.onSurfaceVariant)
        }
        .padding(.top, 16)
    }

    // MARK: - Create Hero Card

    private var createHeroCard: some View {
        Button {
            if storeManager.isPremium {
                showCreateMix = true
            } else {
                showPremiumSheet = true
            }
        } label: {
            ZStack {
                // Gradient background
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.primaryContainer.opacity(0.4),
                                Color.secondaryContainer.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 192)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    }

                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(storeManager.isPremium ? Color.appAccent : Color.gray)
                            .frame(width: 64, height: 64)
                            .shadow(color: (storeManager.isPremium ? Color.appAccent : Color.gray).opacity(0.4), radius: 16)

                        Image(systemName: storeManager.isPremium ? "plus" : "lock.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(Color.onPrimary)
                    }

                    Text("Create New Mix")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.onSurface)

                    if !storeManager.isPremium {
                        Text("Premium Feature")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.appAccent)
                    }
                }
            }
        }
        .buttonStyle(CardPressStyle())
    }

    // MARK: - Saved Mixes

    @ViewBuilder
    private var savedMixesSection: some View {
        if !mixesManager.mixes.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Mixes")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.onSurface)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(mixesManager.mixes) { mix in
                        MixCardView(
                            mix: mix,
                            isActive: player.currentMix?.id == mix.id && player.isMixPlaying,
                            onPlay: {
                                player.playMix(mix: mix)
                            },
                            onEdit: {
                                if storeManager.isPremium {
                                    editingMix = mix
                                } else {
                                    showPremiumSheet = true
                                }
                            }
                        )
                        .contextMenu {
                            Button {
                                mixesManager.toggleFavorite(mix)
                            } label: {
                                Label(
                                    mix.isFavorite ? "Unfavorite" : "Favorite",
                                    systemImage: mix.isFavorite ? "heart.slash" : "heart"
                                )
                            }

                            Button(role: .destructive) {
                                mixesManager.deleteMix(mix)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Curated For You

    private var curatedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Curated for You")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.onSurface)

            let curated = MixesManager.curatedMixes
            if curated.count >= 3 {
                // Asymmetric layout: 1 large + 2 stacked
                VStack(spacing: 12) {
                    curatedLargeCard(curated[0])

                    HStack(spacing: 12) {
                        curatedSmallCard(curated[1])
                        curatedSmallCard(curated[2])
                    }
                }
            }
        }
    }

    private func curatedLargeCard(_ mix: SoundMix) -> some View {
        Button {
            player.playMix(mix: mix)
        } label: {
            ZStack(alignment: .bottomLeading) {
                Image(mix.backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                // Dark overlay
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(mix.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(mix.description)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(16)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func curatedSmallCard(_ mix: SoundMix) -> some View {
        Button {
            player.playMix(mix: mix)
        } label: {
            ZStack(alignment: .bottomLeading) {
                Image(mix.backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(mix.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(mix.description)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(2)
                }
                .padding(12)
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(CardPressStyle())
    }
}
