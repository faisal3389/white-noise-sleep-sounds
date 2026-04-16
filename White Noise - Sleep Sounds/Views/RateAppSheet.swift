import SwiftUI

struct RateAppSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onRate: () -> Void
    var onDismiss: () -> Void

    @State private var appear = false
    @State private var tappedStar: Int? = nil

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            // soft accent halos
            Circle()
                .fill(Color.appAccent.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 60)
                .offset(x: -120, y: -220)

            Circle()
                .fill(Color.appSecondary.opacity(0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: 140, y: 260)

            VStack(spacing: DS.Spacing.xl) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(Color.appAccent.opacity(0.10))
                        .frame(width: 150, height: 150)

                    Circle()
                        .fill(Color.appAccent.opacity(0.18))
                        .frame(width: 104, height: 104)

                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 56, weight: .regular))
                        .foregroundStyle(Color.appAccent)
                        .shadow(color: Color.appAccent.opacity(0.35), radius: 24)
                        .symbolEffect(.pulse, options: .repeating)
                }
                .scaleEffect(appear ? 1 : 0.85)
                .opacity(appear ? 1 : 0)

                VStack(spacing: DS.Spacing.md) {
                    Text("Sleeping a little better?")
                        .font(DS.Typography.displayHero)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DS.Spacing.xl)

                    Text("A quick rating on the App Store helps us\nkeep crafting sounds for your rest.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DS.Spacing.xxl)
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 12)

                // Decorative stars
                HStack(spacing: DS.Spacing.md) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.appAccent)
                            .shadow(color: Color.appAccent.opacity(0.4), radius: 12)
                            .scaleEffect(tappedStar == index ? 1.2 : (appear ? 1 : 0.5))
                            .opacity(appear ? 1 : 0)
                            .animation(
                                .spring(response: 0.45, dampingFraction: 0.6)
                                    .delay(Double(index) * 0.07),
                                value: appear
                            )
                    }
                }
                .padding(.top, DS.Spacing.sm)

                Spacer()

                VStack(spacing: DS.Spacing.md) {
                    Button {
                        onRate()
                        dismiss()
                    } label: {
                        HStack(spacing: DS.Spacing.sm) {
                            Image(systemName: "star.fill")
                            Text("Rate 5 Stars")
                        }
                        .font(DS.Typography.button)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(LinearGradient.jewelButton)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                        .shadow(color: Color.appAccent.opacity(0.30), radius: 24, y: 8)
                    }
                    .padding(.horizontal, DS.Spacing.xl)

                    Button {
                        onDismiss()
                        dismiss()
                    } label: {
                        Text("Maybe later")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.bottom, DS.Spacing.xxl)
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 16)
            }
            .padding(.top, DS.Spacing.xxl)
        }
        .preferredColorScheme(.dark)
        .interactiveDismissDisabled(false)
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) {
                appear = true
            }
        }
    }
}

#Preview {
    RateAppSheet(onRate: {}, onDismiss: {})
}
