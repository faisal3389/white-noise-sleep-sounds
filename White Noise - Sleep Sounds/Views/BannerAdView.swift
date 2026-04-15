import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView()
        bannerView.adUnitID = adUnitID
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        return bannerView
    }

    func updateUIView(_ bannerView: GADBannerView, context: Context) {
        if bannerView.rootViewController == nil {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                bannerView.rootViewController = rootVC

                let viewWidth = rootVC.view.frame.inset(by: rootVC.view.safeAreaInsets).width
                bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
                bannerView.load(GADRequest())
            }
        }
    }
}
#endif

struct AdBannerContainer: View {
    let isPremium: Bool
    private let testAdUnitID = "ca-app-pub-3940256099942544/2934735716"

    var body: some View {
        if !isPremium {
            #if canImport(GoogleMobileAds)
            BannerAdView(adUnitID: testAdUnitID)
                .frame(height: 50)
            #endif
        }
    }
}
