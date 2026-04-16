import SwiftUI

struct CreateMixView: View {
    @Bindable var player: AudioPlayerViewModel
    var mixesManager: MixesManager
    var editingMix: SoundMix?

    @Environment(\.dismiss) private var dismiss

    @State private var selectedSoundIds: Set<String> = []
    @State private var componentVolumes: [String: Float] = [:]
    @State private var mixName: String = ""
    @State private var isPreviewing = false

    private let maxSounds = 5
    private let allSounds = SoundLibrary.allSounds

    init(player: AudioPlayerViewModel, mixesManager: MixesManager, editingMix: SoundMix? = nil) {
        self.player = player
        self.mixesManager = mixesManager
        self.editingMix = editingMix

        if let mix = editingMix {
            _mixName = State(initialValue: mix.name)
            let ids = Set(mix.components.map(\.soundId))
            _selectedSoundIds = State(initialValue: ids)
            var vols: [String: Float] = [:]
            for comp in mix.components {
                vols[comp.soundId] = comp.volume
            }
            _componentVolumes = State(initialValue: vols)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    soundGrid

                    if !selectedSoundIds.isEmpty {
                        selectedSoundsPanel
                    }
                }
            }
            .navigationTitle(editingMix != nil ? "Edit Mix" : "Create Mix")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if isPreviewing {
                            player.stop()
                        }
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMix()
                    }
                    .foregroundStyle(canSave ? Color.appAccent : .gray)
                    .disabled(!canSave)
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var canSave: Bool {
        selectedSoundIds.count >= 2 && !mixName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Sound Grid

    private var soundGrid: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Mix name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mix Name")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.onSurfaceVariant)

                    TextField("e.g. Rainy Cabin", text: $mixName)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.appSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Text("Select 2-5 sounds")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.onSurfaceVariant)
                    .padding(.horizontal, 16)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(allSounds) { sound in
                        soundCell(sound)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, selectedSoundIds.isEmpty ? 16 : 260)
        }
    }

    private func soundCell(_ sound: Sound) -> some View {
        let isSelected = selectedSoundIds.contains(sound.id)
        let isDisabled = !isSelected && selectedSoundIds.count >= maxSounds

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isSelected {
                    selectedSoundIds.remove(sound.id)
                    componentVolumes.removeValue(forKey: sound.id)
                } else if selectedSoundIds.count < maxSounds {
                    selectedSoundIds.insert(sound.id)
                    componentVolumes[sound.id] = 0.7
                }
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appSurface)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            Image(sound.backgroundImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .opacity(0.6)
                        }

                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.appAccent, lineWidth: 2)

                        Circle()
                            .fill(Color.appAccent)
                            .frame(width: 28, height: 28)
                            .overlay {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                            }
                    }
                }

                Text(sound.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(isSelected ? Color.onSurface : Color.onSurfaceVariant)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .opacity(isDisabled ? 0.4 : 1.0)
        .disabled(isDisabled)
    }

    // MARK: - Selected Sounds Panel

    private var selectedSoundsPanel: some View {
        VStack(spacing: 12) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 8)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(selectedSoundsOrdered) { sound in
                        componentRow(sound)
                    }
                }
            }
            .frame(maxHeight: 150)

            // Action buttons
            HStack(spacing: 12) {
                Button {
                    togglePreview()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isPreviewing ? "stop.fill" : "play.fill")
                        Text(isPreviewing ? "Stop" : "Preview")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.appAccent, lineWidth: 1.5)
                    )
                }

                Spacer()

                Text("\(selectedSoundIds.count)/\(maxSounds) sounds")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.onSurfaceVariant)
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 16)
        .background(
            Color.appSurface
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 20, y: -5)
        )
    }

    private var selectedSoundsOrdered: [Sound] {
        allSounds.filter { selectedSoundIds.contains($0.id) }
    }

    private func componentRow(_ sound: Sound) -> some View {
        HStack(spacing: 10) {
            Text(sound.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.onSurface)
                .frame(width: 80, alignment: .leading)
                .lineLimit(1)

            Slider(
                value: Binding(
                    get: { componentVolumes[sound.id] ?? 0.7 },
                    set: { componentVolumes[sound.id] = $0 }
                ),
                in: 0...1
            )
            .tint(Color.appAccent)

            Button {
                withAnimation {
                    selectedSoundIds.remove(sound.id)
                    componentVolumes.removeValue(forKey: sound.id)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.onSurfaceVariant)
            }
        }
    }

    // MARK: - Actions

    private func togglePreview() {
        if isPreviewing {
            AnalyticsManager.shared.track(.mixPreviewStopped, properties: ["component_count": selectedSoundIds.count])
            player.stop()
            isPreviewing = false
        } else {
            let components = buildComponents()
            guard components.count >= 2 else { return }
            AnalyticsManager.shared.track(.mixPreviewed, properties: ["component_count": components.count])
            let previewMix = SoundMix(name: "Preview", components: components)
            player.playMix(mix: previewMix)
            isPreviewing = true
        }
    }

    private func saveMix() {
        let components = buildComponents()
        guard components.count >= 2 else { return }

        if isPreviewing {
            player.stop()
            isPreviewing = false
        }

        let isEditing = editingMix != nil
        let mix = SoundMix(
            id: editingMix?.id ?? UUID(),
            name: mixName.trimmingCharacters(in: .whitespaces),
            description: components.compactMap { $0.sound?.name }.joined(separator: " + "),
            components: components,
            isFavorite: editingMix?.isFavorite ?? false,
            createdAt: editingMix?.createdAt ?? Date()
        )

        mixesManager.saveMix(mix)
        AnalyticsManager.shared.track(isEditing ? .mixEdited : .mixCreated, properties: [
            "mix_name": mix.name,
            "component_count": components.count,
            "sounds": components.compactMap { $0.sound?.name }.joined(separator: ", ")
        ])
        dismiss()
    }

    private func buildComponents() -> [MixComponent] {
        selectedSoundsOrdered.map { sound in
            MixComponent(soundId: sound.id, volume: componentVolumes[sound.id] ?? 0.7)
        }
    }
}
