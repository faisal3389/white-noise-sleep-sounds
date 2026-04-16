import SwiftUI

struct PremiumUpgradeView: View {
    var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss
    private let analytics = AnalyticsManager.shared

    @State private var showSuccessFlow = false
    @State private var showFailureAlert = false
    @State private var failureMessage = ""

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
                    analytics.track(.premiumPurchaseTapped)
                    Task { await storeManager.purchase() }
                } label: {
                    if storeManager.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                    } else {
                        Text(storeManager.priceString.isEmpty ? "Premium — One Time" : "Just \(storeManager.priceString) — One Time")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                    }
                }
                .background(LinearGradient.jewelButton)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                .padding(.horizontal, 32)

                if let error = storeManager.purchaseError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                // Restore
                Button {
                    analytics.track(.restorePurchasesTapped)
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

            // Success walkthrough overlay
            if showSuccessFlow {
                PurchaseSuccessWalkthroughView {
                    dismiss()
                }
                .transition(.opacity)
            }

            // Failure alert overlay
            if showFailureAlert {
                PurchaseFailureAlertView(message: failureMessage) {
                    showFailureAlert = false
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            analytics.track(.premiumSheetViewed, properties: ["source": "premium_view"])
        }
        .onChange(of: storeManager.isPremium) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showSuccessFlow = true
                }
            }
        }
        .onChange(of: storeManager.purchaseError) { _, newValue in
            if let error = newValue, !error.isEmpty {
                failureMessage = error
                withAnimation(.easeInOut(duration: 0.3)) {
                    showFailureAlert = true
                }
            }
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

// MARK: - Purchase Success Walkthrough

private struct PurchaseSuccessWalkthroughView: View {
    var onDone: () -> Void
    @State private var currentPage = 0
    @State private var showCheckmark = true

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if showCheckmark {
                successCelebrationPage
                    .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    TabView(selection: $currentPage) {
                        welcomePage.tag(0)
                        howItWorksPage.tag(1)
                        premiumUnlockedPage.tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)

                    VStack(spacing: 24) {
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Capsule()
                                    .fill(index == currentPage ? Color.appAccent : Color.white.opacity(0.3))
                                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                                    .animation(.easeInOut(duration: 0.2), value: currentPage)
                            }
                        }

                        Button {
                            if currentPage < 2 {
                                currentPage += 1
                            } else {
                                onDone()
                            }
                        } label: {
                            Text(currentPage < 2 ? "Next" : "Start Exploring")
                                .font(DS.Typography.button)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(LinearGradient.jewelButton)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                        }
                        .padding(.horizontal, 32)

                        if currentPage < 2 {
                            Button("Skip") {
                                onDone()
                            }
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .padding(.bottom, 48)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showCheckmark = false
                }
            }
        }
    }

    // MARK: - Success Celebration

    private var successCelebrationPage: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                // Glow ring
                Circle()
                    .fill(Color.appAccent.opacity(0.08))
                    .frame(width: 180, height: 180)

                Circle()
                    .fill(Color.appAccent.opacity(0.15))
                    .frame(width: 130, height: 130)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.appAccent)
                    .symbolEffect(.bounce, value: showCheckmark)
            }

            Text("You're Premium!")
                .font(DS.Typography.displayHero)
                .foregroundStyle(.white)

            Text("Thank you for your support.\nAll sounds and features are now unlocked.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Walkthrough Pages

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(Color.appAccent)
                .shadow(color: Color.appAccent.opacity(0.10), radius: 32)

            VStack(spacing: 12) {
                Text("Your Personal")
                    .font(DS.Typography.displayHero)
                    .foregroundStyle(.white)

                Text("Sound Sanctuary")
                    .font(DS.Typography.displayHero)
                    .foregroundStyle(Color.appAccent)
            }

            Text("Beautiful sounds to help you sleep, focus, and relax.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }

    private var howItWorksPage: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 32) {
                featureRow(
                    icon: "play.circle.fill",
                    title: "Pick a Sound",
                    description: "Choose from 30+ sounds across 7 categories"
                )

                featureRow(
                    icon: "slider.horizontal.3",
                    title: "Mix Them Together",
                    description: "Combine up to 5 sounds with custom volumes"
                )

                featureRow(
                    icon: "moon.fill",
                    title: "Set a Sleep Timer",
                    description: "Fade out gently and wake refreshed"
                )
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }

    private var premiumUnlockedPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "star.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.appAccent)

            Text("All Yours Now")
                .font(DS.Typography.displayHero)
                .foregroundStyle(.white)

            Text("Every sound unlocked. No ads. No limits.\nEnjoy your premium experience.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: DS.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(Color.appAccent)
                .frame(width: DS.Spacing.sectionLg, height: DS.Spacing.sectionLg)

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(title)
                    .font(DS.Typography.headlineSm)
                    .foregroundStyle(.white)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()
        }
    }
}

// MARK: - Purchase Failure Alert

private struct PurchaseFailureAlertView: View {
    let message: String
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 20) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.error)

                Text("Purchase Failed")
                    .font(DS.Typography.headlineLg)
                    .foregroundStyle(.white)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                Button {
                    onDismiss()
                } label: {
                    Text("Try Again")
                        .font(DS.Typography.button)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.error.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                }
                .padding(.horizontal, 16)
            }
            .padding(28)
            .frame(maxWidth: 320)
            .background(Color.surfaceContainerHigh)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl))
            .dsShadow(DS.ShadowToken.ambient)
        }
    }
}
