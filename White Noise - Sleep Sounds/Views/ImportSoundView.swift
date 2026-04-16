import SwiftUI
import UniformTypeIdentifiers

struct ImportSoundView: View {
    @Bindable var customSoundsManager: CustomSoundsManager
    @Bindable var player: AudioPlayerViewModel
    @Binding var selectedTab: Int

    @State private var showFilePicker = false
    @State private var pendingURL: URL?
    @State private var soundName = ""
    @State private var selectedCategory = "General"
    @State private var showNameSheet = false
    @State private var importError: String?
    @State private var showError = false

    private let categories = ["General", "Nature", "Rain", "Urban", "Machine", "Fire", "Water"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        importButton

                        if !customSoundsManager.sounds.isEmpty {
                            customSoundsList
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("My Sounds")
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: CustomSoundsManager.supportedTypes,
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        pendingURL = url
                        soundName = url.deletingPathExtension().lastPathComponent
                            .replacingOccurrences(of: "_", with: " ")
                            .replacingOccurrences(of: "-", with: " ")
                            .capitalized
                        showNameSheet = true
                    }
                case .failure(let error):
                    importError = error.localizedDescription
                    showError = true
                }
            }
            .sheet(isPresented: $showNameSheet) {
                namingSheet
            }
            .alert("Import Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(importError ?? "An unknown error occurred.")
            }
        }
    }

    // MARK: - Import Button

    private var importButton: some View {
        Button {
            AnalyticsManager.shared.track(.importSoundTapped)
            showFilePicker = true
        } label: {
            VStack(spacing: 12) {
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.appAccent)

                Text("Import Sound")
                    .font(DS.Typography.button)
                    .foregroundStyle(.white)

                Text("MP3, M4A, WAV, AIFF")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.xxl)
            .background(Color.surfaceContainerHigh)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        }
    }

    // MARK: - Custom Sounds List

    private var customSoundsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Imported Sounds")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))

            ForEach(customSoundsManager.sounds) { sound in
                customSoundRow(sound)
            }
        }
    }

    private func customSoundRow(_ customSound: CustomSound) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.appAccent.opacity(0.7))

            VStack(alignment: .leading, spacing: 2) {
                Text(customSound.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)

                Text(customSound.category)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()

            Button {
                if let sound = customSoundsManager.asSound(customSound) {
                    AnalyticsManager.shared.track(.customSoundPlayed, properties: ["sound_name": customSound.name, "category": customSound.category])
                    player.play(sound: sound)
                    selectedTab = 2
                }
            } label: {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.appAccent)
            }
        }
        .padding(DS.Spacing.md)
        .background(Color.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .contextMenu {
            Button(role: .destructive) {
                AnalyticsManager.shared.track(.customSoundDeleted, properties: ["sound_name": customSound.name])
                customSoundsManager.deleteSound(customSound)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Naming Sheet

    private var namingSheet: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 20) {
                    TextField("Sound name", text: $soundName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 16)

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)

                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Name Your Sound")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        pendingURL = nil
                        showNameSheet = false
                    }
                    .foregroundStyle(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveImportedSound()
                    }
                    .foregroundStyle(Color.appAccent)
                    .disabled(soundName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }

    private func saveImportedSound() {
        guard let url = pendingURL else { return }
        let trimmedName = soundName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        do {
            try customSoundsManager.importSound(from: url, name: trimmedName, category: selectedCategory)
            AnalyticsManager.shared.track(.soundImported, properties: ["sound_name": trimmedName, "category": selectedCategory, "file_type": url.pathExtension])
        } catch {
            AnalyticsManager.shared.track(.soundImportFailed, properties: ["error": error.localizedDescription])
            importError = error.localizedDescription
            showError = true
        }

        pendingURL = nil
        showNameSheet = false
    }
}
