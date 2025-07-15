import Foundation
import RevenueCat

class PurchaseModel: ObservableObject {
    @Published var isSubscribed: Bool = false
    @Published var errorMessage: String?

    func fetchOfferings() async {
        do {
            _ = try await Purchases.shared.offerings()
            // Handle offerings if needed
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to fetch offerings: \(error.localizedDescription)"
            }
        }
    }

    func restorePurchases(completion: @escaping (Bool) -> Void) {
        Purchases.shared.restorePurchases { customerInfo, error in
            if let error = error {
                self.errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
                completion(false)
            } else {
                self.isSubscribed = customerInfo?.activeSubscriptions.contains("premium") ?? false
                self.errorMessage = nil
                completion(true)
            }
        }
    }
}
