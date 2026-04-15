import SwiftUI

struct PremiumUpgradeView: View {
    var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Icon
                Image(systemName: "star.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.appAccent)

                Text("Go Premium")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                // Benefits
                VStack(alignment: .leading, spacing: 14) {
                    benefitRow(icon: "xmark.circle.fill", text: "Remove all ads forever")
                    benefitRow(icon: "lock.open.fill", text: "Unlock 12 exclusive sounds")
                    benefitRow(icon: "heart.fill", text: "Support indie development")
                }
                .padding(.horizontal, 32)

                Spacer()

                // CTA Button
                Button {
                    Task { await storeManager.purchase() }
                } label: {
                    if storeManager.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                    } else {
                        Text("Just $0.99 — One Time")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                    }
                }
                .background(Color.appAccent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 32)

                if let error = storeManager.purchaseError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                // Restore
                Button {
                    Task { await storeManager.restorePurchases() }
                } label: {
                    Text("Restore Purchases")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Text("No subscriptions. Ever.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.bottom, 32)
            }
        }
        .onChange(of: storeManager.isPremium) { _, newValue in
            if newValue { dismiss() }
        }
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.appAccent)
                .frame(width: 24)
            Text(text)
                .font(.body)
                .foregroundStyle(.white)
        }
    }
}
