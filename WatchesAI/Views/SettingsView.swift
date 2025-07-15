import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccountAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                List {
                    // Account Section
                    Section(header: Text("Account")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        if let user = Auth.auth().currentUser {
                            Text("Email: \(user.email ?? "No Email")")
                                .font(.system(.body, design: .default, weight: .regular))
                                .padding(.vertical, 4)
                                .accessibilityLabel("Email: \(user.email ?? "No Email")")
                        }
                        NavigationLink("Manage Account") {
                            ManageAccountView()
                                .environmentObject(authService)
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .padding(.vertical, 4)
                        .accessibilityLabel("Manage Account")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                    
                    // Support Section
                    Section(header: Text("Support")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        Link("Contact Support", destination: URL(string: "mailto:support@watchesai.com")!)
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding(.vertical, 4)
                            .accessibilityLabel("Contact Support via Email")
                        Link("Visit Our Website", destination: URL(string: "https://www.watchesai.com")!)
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding(.vertical, 4)
                            .accessibilityLabel("Visit Website")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                    
                    // Legal Section
                    Section(header: Text("Legal")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        Link("Privacy Policy", destination: URL(string: "https://www.watchesai.com/privacy")!)
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding(.vertical, 4)
                            .accessibilityLabel("Privacy Policy")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                    
                    // Account Actions
                    Section(header: Text("Account Actions")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        Button("Log Out") {
                            showingLogoutAlert = true
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.red)
                        .padding(.vertical, 4)
                        .accessibilityLabel("Log Out")
                        .alert("Log Out", isPresented: $showingLogoutAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Log Out", role: .destructive) {
                                authService.signOut()
                            }
                        } message: {
                            Text("Are you sure you want to log out?")
                                .font(.system(.body, design: .default, weight: .regular))
                        }
                        
                        Button("Delete Account") {
                            showingDeleteAccountAlert = true
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.red)
                        .padding(.vertical, 4)
                        .accessibilityLabel("Delete Account")
                        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Delete", role: .destructive) {
                                authService.deleteAccount { error in
                                    if let error = error {
                                        print("Delete account error: \(error.localizedDescription)")
                                    }
                                }
                            }
                        } message: {
                            Text("This will permanently delete your account and all associated watches. Are you sure?")
                                .font(.system(.body, design: .default, weight: .regular))
                        }
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                    
                    // App Info
                    Section(header: Text("App Info")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        Text("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding(.vertical, 4)
                            .accessibilityLabel("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                }
                .navigationTitle("Settings")
                .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView()
                .environmentObject(AuthService())
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
            SettingsView()
                .environmentObject(AuthService())
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
}
