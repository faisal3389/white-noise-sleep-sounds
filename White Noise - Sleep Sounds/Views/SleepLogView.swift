import SwiftUI

struct SleepLogView: View {
    @Bindable var sleepLog: SleepLogManager

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if sleepLog.entries.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            statsHeader
                            weeklyEntries
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Sleep Log")
        }
    }

    // MARK: - Stats Header

    private var statsHeader: some View {
        HStack(spacing: 12) {
            statCard(
                title: "Streak",
                value: "\(sleepLog.currentStreak)",
                icon: "flame.fill"
            )

            statCard(
                title: "This Week",
                value: formatMinutes(sleepLog.totalSleepThisWeek),
                icon: "calendar"
            )

            statCard(
                title: "Sessions",
                value: "\(sleepLog.entries.count)",
                icon: "moon.stars.fill"
            )
        }
    }

    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.appAccent)

            Text(value)
                .font(DS.Typography.headlineSm)
                .foregroundStyle(.white)

            Text(title)
                .font(DS.Typography.labelSm)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.lg)
        .background(Color.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
    }

    // MARK: - Weekly Entries

    private var weeklyEntries: some View {
        ForEach(sleepLog.entriesGroupedByWeek, id: \.weekLabel) { group in
            VStack(alignment: .leading, spacing: 8) {
                Text(group.weekLabel)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
                    .padding(.top, 8)

                ForEach(group.entries) { entry in
                    entryRow(entry)
                }
            }
        }
    }

    private func entryRow(_ entry: SleepLogEntry) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "moon.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.appAccent.opacity(0.7))
                .frame(width: 32, height: 32)
                .background(Color.appAccent.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.mixName ?? entry.soundName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)

                Text(entry.date, format: .dateTime.weekday(.wide).month(.abbreviated).day().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()

            Text(entry.durationFormatted)
                .font(DS.Typography.buttonSm)
                .foregroundStyle(Color.appAccent)
        }
        .padding(DS.Spacing.md)
        .background(Color.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .contextMenu {
            Button(role: .destructive) {
                AnalyticsManager.shared.track(.sleepLogEntryDeleted, properties: ["sound_name": entry.soundName])
                sleepLog.deleteEntry(entry)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "bed.double.fill")
                .font(.system(size: 70))
                .foregroundStyle(Color.appAccent.opacity(0.5))

            Text("No Sleep Data Yet")
                .font(.title2.weight(.medium))
                .foregroundStyle(.white.opacity(0.7))

            Text("Your sleep sessions will appear here when you use the sleep timer or sleep clock.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Helpers

    private func formatMinutes(_ total: Int) -> String {
        let hours = total / 60
        let mins = total % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }
}
