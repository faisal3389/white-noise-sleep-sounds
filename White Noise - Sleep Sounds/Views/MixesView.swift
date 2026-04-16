import SwiftUI

struct MixesView: View {
    @Bindable var player: AudioPlayerViewModel
    var mixesManager: MixesManager
    var storeManager: StoreManager

    @State private var showCreateMix = false
    @State private var showPremiumSheet = false
    @State private var editingMix: SoundMix?
    @State private var createHeroPressed = false
    @State private var previewTask: Task<Void, Never>?
    @State private var previewMixId: UUID?

    private let curatedPreviewSeconds: Int = 60

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
        .onChange(of: player.currentMix?.id) { _, newId in
            if let activePreviewId = previewMixId, newId != activePreviewId {
                previewTask?.cancel()
                previewTask = nil
                previewMixId = nil
            }
        }
    }

    // MARK: - Curated Mix Playback (with preview gating for free users)

    private func playCuratedMix(_ mix: SoundMix) {
        previewTask?.cancel()
        previewTask = nil

        AnalyticsManager.shared.track(.curatedMixPlayed, properties: [
            "mix_name": mix.name,
            "is_premium": storeManager.isPremium
        ])
        player.playMix(mix: mix, source: "curated")

        guard !storeManager.isPremium else {
            previewMixId = nil
            return
        }

        previewMixId = mix.id
        let mixName = mix.name
        let seconds = curatedPreviewSeconds
        previewTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(seconds))
            if Task.isCancelled { return }
            player.stop()
            AnalyticsManager.shared.track(.curatedMixPreviewEnded, properties: ["mix_name": mixName])
            previewMixId = nil
            previewTask = nil
            showPremiumSheet = true
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
            AnalyticsManager.shared.track(.createMixTapped, properties: ["is_premium": storeManager.isPremium])
            if storeManager.isPremium {
                showCreateMix = true
            } else {
                AnalyticsManager.shared.track(.premiumLockedContentTapped, properties: ["feature": "create_mix", "source": "mixes"])
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
                                player.playMix(mix: mix, source: "user")
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
                                let wasFav = mix.isFavorite
                                mixesManager.toggleFavorite(mix)
                                AnalyticsManager.shared.track(wasFav ? .mixUnfavorited : .mixFavorited, properties: ["mix_name": mix.name])
                            } label: {
                                Label(
                                    mix.isFavorite ? "Unfavorite" : "Favorite",
                                    systemImage: mix.isFavorite ? "heart.slash" : "heart"
                                )
                            }

                            Button(role: .destructive) {
                                AnalyticsManager.shared.track(.mixDeleted, properties: ["mix_name": mix.name])
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
            playCuratedMix(mix)
        } label: {
            ZStack(alignment: .bottomLeading) {
                GeometryReader { geo in
                    Image(mix.backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }

                // Dark overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
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
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(alignment: .topTrailing) {
                if !storeManager.isPremium {
                    previewBadge.padding(12)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func curatedSmallCard(_ mix: SoundMix) -> some View {
        Button {
            playCuratedMix(mix)
        } label: {
            ZStack(alignment: .bottomLeading) {
                GeometryReader { geo in
                    Image(mix.backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }

                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
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
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(alignment: .topTrailing) {
                if !storeManager.isPremium {
                    previewBadge.padding(8)
                }
            }
        }
        .buttonStyle(CardPressStyle())
    }

    private var previewBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock.fill")
                .font(.system(size: 10, weight: .semibold))
            Text("1 min preview")
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule().strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
        )
    }
}
