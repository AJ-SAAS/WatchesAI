import SwiftUI
import FirebaseCore

@main
struct WatchesAIApp: App {
    @StateObject private var authService = AuthService()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(authService)
        }
    }
}
