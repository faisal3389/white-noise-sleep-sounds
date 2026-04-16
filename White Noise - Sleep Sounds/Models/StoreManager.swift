import Foundation
#if canImport(RevenueCat)
import RevenueCat

private extension Error {
    /// Returns `true` when the user intentionally cancelled the purchase sheet.
    var isCancelledPurchase: Bool {
        let nsError = self as NSError
        return nsError.domain == RevenueCat.ErrorCode.errorDomain
            && nsError.code == RevenueCat.ErrorCode.purchaseCancelledError.rawValue
    }
}
#endif

@Observable
class StoreManager {
    // Set to true to unlock all premium features during local testing.
    // Only takes effect in DEBUG builds — release/App Store builds ignore this.
    #if DEBUG
    private static let forceUnlockPremium = false
    #endif

    private(set) var isPremium: Bool = {
        #if DEBUG
        return forceUnlockPremium
        #else
        return false
        #endif
    }()
    private(set) var purchaseError: String?
    private(set) var isLoading: Bool = false

    #if canImport(RevenueCat)
    private(set) var currentOffering: Offering?

    var premiumPackage: Package? {
        currentOffering?.availablePackages.first
    }

    /// Localized price string from the App Store (e.g. "$4.99", "CA$6.99").
    /// Falls back to an empty string while the price is loading.
    var priceString: String {
        premiumPackage?.localizedPriceString ?? ""
    }
    #else
    var priceString: String { "" }
    #endif

    init() {
        #if canImport(RevenueCat)
        Purchases.configure(withAPIKey: "appl_CNQAMLNHmBVDEWexzOqiGOmSLPL")
        Task { await loadOfferings() }
        Task { await checkEntitlements() }
        #endif
    }

    // MARK: - Load Offerings

    #if canImport(RevenueCat)
    @MainActor
    func loadOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            currentOffering = offerings.current
        } catch {
            print("Failed to load offerings: \(error)")
        }
    }
    #endif

    // MARK: - Purchase

    @MainActor
    func purchase() async {
        #if canImport(RevenueCat)
        // If offerings haven't loaded yet, try loading them first
        if currentOffering == nil {
            await loadOfferings()
        }

        guard let package = premiumPackage else {
            purchaseError = currentOffering == nil
                ? "Unable to load products. Please check your connection and try again."
                : "No purchase option available."
            return
        }
        isLoading = true
        purchaseError = nil

        do {
            let result = try await Purchases.shared.purchase(package: package)
            isPremium = result.customerInfo.entitlements["White Noise Premium"]?.isActive == true
            if isPremium {
                AnalyticsManager.shared.track(.premiumPurchaseCompleted)
            }
        } catch let error where error.isCancelledPurchase {
            AnalyticsManager.shared.track(.premiumPurchaseCancelled)
        } catch {
            AnalyticsManager.shared.track(.premiumPurchaseFailed, properties: ["error": error.localizedDescription])
            purchaseError = error.localizedDescription
        }

        isLoading = false
        #else
        purchaseError = "In-app purchases are not configured."
        #endif
    }

    // MARK: - Restore

    @MainActor
    func restorePurchases() async {
        #if canImport(RevenueCat)
        isLoading = true
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            isPremium = customerInfo.entitlements["White Noise Premium"]?.isActive == true
            AnalyticsManager.shared.track(.restorePurchasesCompleted, properties: ["is_premium": isPremium])
        } catch {
            purchaseError = error.localizedDescription
        }
        isLoading = false
        #endif
    }

    // MARK: - Check Entitlements

    #if canImport(RevenueCat)
    @MainActor
    private func checkEntitlements() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            isPremium = customerInfo.entitlements["White Noise Premium"]?.isActive == true
        } catch {
            print("Failed to check entitlements: \(error)")
        }
    }
    #endif
}
