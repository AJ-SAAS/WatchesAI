import SwiftUI
import FirebaseCore
import RevenueCat

@main
struct WatchesAIApp: App {
    @StateObject private var viewModel = WatchViewModel()
    
    init() {
        FirebaseApp.configure()
        Purchases.configure(withAPIKey: "YOUR_REVENUECAT_API_KEY")
    }
    
    var body: some Scene {
        WindowGroup {
            if viewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(viewModel)
            } else {
                AuthView()
                    .environmentObject(viewModel)
            }
        }
    }
}
