import Foundation
#if canImport(RevenueCat)
import RevenueCat
#endif

@Observable
class StoreManager {
    private(set) var isPremium: Bool = false
    private(set) var purchaseError: String?
    private(set) var isLoading: Bool = false

    #if canImport(RevenueCat)
    private(set) var currentOffering: Offering?

    var premiumPackage: Package? {
        currentOffering?.availablePackages.first
    }
    #endif

    init() {
        #if canImport(RevenueCat)
        Purchases.configure(withAPIKey: "your_key")
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
        guard let package = premiumPackage else { return }
        isLoading = true
        purchaseError = nil

        do {
            let result = try await Purchases.shared.purchase(package: package)
            isPremium = result.customerInfo.entitlements["premium"]?.isActive == true
            if isPremium {
                AnalyticsManager.shared.track(.premiumPurchaseCompleted)
            }
        } catch {
            if let rcError = error as? RevenueCat.ErrorCode, rcError == .purchaseCancelledError {
                AnalyticsManager.shared.track(.premiumPurchaseCancelled)
            } else {
                AnalyticsManager.shared.track(.premiumPurchaseFailed, properties: ["error": error.localizedDescription])
                purchaseError = error.localizedDescription
            }
        }

        isLoading = false
        #endif
    }

    // MARK: - Restore

    @MainActor
    func restorePurchases() async {
        #if canImport(RevenueCat)
        isLoading = true
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            isPremium = customerInfo.entitlements["premium"]?.isActive == true
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
            isPremium = customerInfo.entitlements["premium"]?.isActive == true
        } catch {
            print("Failed to check entitlements: \(error)")
        }
    }
    #endif
}
