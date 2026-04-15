import SwiftUI
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@main
struct White_Noise___Sleep_SoundsApp: App {
    @State private var storeManager = StoreManager()
    @State private var settings = SettingsManager()

    var body: some Scene {
        WindowGroup {
            ContentView(storeManager: storeManager, settings: settings)
                #if os(iOS)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    requestATTPermission()
                }
                #endif
        }
    }

    #if os(iOS)
    private func requestATTPermission() {
        #if canImport(AppTrackingTransparency)
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                #if canImport(GoogleMobileAds)
                GADMobileAds.sharedInstance().start(completionHandler: nil)
                #endif
            }
        }
        #endif
    }
    #endif
}
