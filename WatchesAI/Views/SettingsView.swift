import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: WatchViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    if viewModel.isSubscribed {
                        Text("Subscription: Premium")
                    } else {
                        Text("Subscription: Free")
                    }
                    Button("Sign Out") {
                        viewModel.signOut()
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("Legal")) {
                    Link("Privacy Policy", destination: URL(string: "https://watchesai.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://watchesai.com/terms")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(WatchViewModel())
    }
}
