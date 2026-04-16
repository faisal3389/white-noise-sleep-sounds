import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    private let analytics = AnalyticsManager.shared

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
                .onAppear { analytics.track(.onboardingStarted) }

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    howItWorksPage.tag(1)
                    getStartedPage.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Page indicator + button
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
                            analytics.track(.onboardingPageViewed, properties: ["page": currentPage])
                        } else {
                            analytics.track(.onboardingCompleted)
                            hasSeenOnboarding = true
                        }
                    } label: {
                        Text(currentPage < 2 ? "Next" : "Get Started")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.appAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 32)

                    if currentPage < 2 {
                        Button("Skip") {
                            analytics.track(.onboardingSkipped, properties: ["skipped_at_page": currentPage])
                            hasSeenOnboarding = true
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Pages

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(Color.appAccent)
                .shadow(color: Color.appAccent.opacity(0.4), radius: 20)

            VStack(spacing: 12) {
                Text("Your Personal")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Sound Sanctuary")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
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

    private var getStartedPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundStyle(Color.appAccent)

            Text("Ready to Relax?")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Enjoy free with ads, or go premium for just $3.99 to unlock all sounds and remove ads.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(Color.appAccent)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()
        }
    }
}
