import SwiftUI

struct SleepTimerView: View {
    @Bindable var timerManager: TimerManager
    var onStart: () -> Void
    var onCancel: () -> Void

    @State private var useCustomTime = false
    @State private var customHours = 0
    @State private var customMinutes = 30

    @Environment(\.dismiss) private var dismiss

    private let presets = [15, 30, 45, 60, 120, 240]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if timerManager.isTimerActive {
                            activeTimerSection
                        } else {
                            presetSection
                            customSection
                            fadeOutToggle
                            alarmSection
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Sleep Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.appAccent)
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Active Timer

    private var activeTimerSection: some View {
        VStack(spacing: 20) {
            Text("Time Remaining")
                .font(.subheadline)
                .foregroundStyle(Color.onSurfaceVariant)

            Text(timerManager.remainingFormatted)
                .font(.system(size: 64, weight: .light, design: .monospaced))
                .foregroundStyle(.white)

            if timerManager.fadeOutEnabled {
                Label("Fade out enabled", systemImage: "speaker.wave.2.fill")
                    .font(.caption)
                    .foregroundStyle(Color.appAccent)
            }

            Button {
                AnalyticsManager.shared.track(.timerCancelled, properties: ["remaining_seconds": timerManager.remainingSeconds])
                onCancel()
                dismiss()
            } label: {
                Text("Cancel Timer")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.red.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Presets

    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Set")
                .font(.headline)
                .foregroundStyle(Color.onSurface)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(presets, id: \.self) { minutes in
                    Button {
                        timerManager.selectedMinutes = minutes
                        timerManager.fadeOutEnabled = timerManager.fadeOutEnabled
                        onStart()
                        AnalyticsManager.shared.track(.timerStartedPreset, properties: ["minutes": minutes, "fade_out": timerManager.fadeOutEnabled])
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        dismiss()
                    } label: {
                        Text(presetLabel(minutes))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.appSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.appAccent.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    // MARK: - Custom

    private var customSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom Duration")
                .font(.headline)
                .foregroundStyle(Color.onSurface)

            HStack(spacing: 0) {
                Picker("Hours", selection: $customHours) {
                    ForEach(0..<13) { h in
                        Text("\(h) hr").tag(h)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("Minutes", selection: $customMinutes) {
                    ForEach(Array(stride(from: 0, through: 55, by: 5)), id: \.self) { m in
                        Text("\(m) min").tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 120)

            Button {
                let total = customHours * 60 + customMinutes
                guard total > 0 else { return }
                timerManager.selectedMinutes = total
                onStart()
                AnalyticsManager.shared.track(.timerStartedCustom, properties: ["minutes": total, "fade_out": timerManager.fadeOutEnabled])
                dismiss()
            } label: {
                Text("Start Timer")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.appAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Fade Out

    private var fadeOutToggle: some View {
        Toggle(isOn: Binding(
            get: { timerManager.fadeOutEnabled },
            set: { newValue in
                timerManager.fadeOutEnabled = newValue
                AnalyticsManager.shared.track(.fadeOutToggled, properties: ["enabled": newValue])
            }
        )) {
            HStack(spacing: 10) {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundStyle(Color.appAccent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Fade Out")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.onSurface)
                    Text("Gradually lower volume over the last 30 seconds")
                        .font(.caption)
                        .foregroundStyle(Color.onSurfaceVariant)
                }
            }
        }
        .tint(Color.appAccent)
        .padding(16)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Alarm

    private var alarmSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: Binding(
                get: { timerManager.alarmEnabled },
                set: { newValue in
                    timerManager.alarmEnabled = newValue
                    AnalyticsManager.shared.track(.alarmToggled, properties: ["enabled": newValue])
                }
            )) {
                HStack(spacing: 10) {
                    Image(systemName: "alarm.fill")
                        .foregroundStyle(Color.appAccent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Wake Alarm")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.onSurface)
                        Text("Get a notification to wake up")
                            .font(.caption)
                            .foregroundStyle(Color.onSurfaceVariant)
                    }
                }
            }
            .tint(Color.appAccent)
            .onChange(of: timerManager.alarmEnabled) { _, enabled in
                if enabled {
                    timerManager.requestNotificationPermission()
                }
            }

            if timerManager.alarmEnabled {
                DatePicker(
                    "Alarm Time",
                    selection: $timerManager.alarmTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func presetLabel(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let h = minutes / 60
            return "\(h) hr"
        }
    }
}
