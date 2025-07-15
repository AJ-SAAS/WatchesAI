// Views/MainTabView.swift
import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @EnvironmentObject var authService: AuthService
    @State private var selectedTab = 0
    
    var body: some View {
        if authService.isAuthenticated {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                
                CollectionView()
                    .tabItem {
                        Label("Collection", systemImage: "archivebox")
                    }
                    .tag(1)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(2)
            }
        } else {
            AuthView()
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthService())
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
    }
}
