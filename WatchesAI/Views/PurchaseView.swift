import SwiftUI
import RevenueCat

struct PurchaseView: View {
    @EnvironmentObject var viewModel: WatchViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Upgrade to WatchesAI Pro")
                    .font(.title2)
                    .bold()
                Text("Unlock unlimited watches and premium features!")
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    Purchases.shared.getOfferings { offerings, error in
                        guard let offerings = offerings, error == nil,
                              let package = offerings.current?.availablePackages.first else {
                            print("Error fetching offerings: \(String(describing: error))")
                            return
                        }
                        
                        Purchases.shared.purchase(package: package) { transaction, customerInfo, error, userCancelled in
                            if let error = error {
                                print("Purchase error: \(error.localizedDescription)")
                            } else if let customerInfo = customerInfo, customerInfo.activeSubscriptions.contains("premium") {
                                viewModel.isSubscribed = true
                                dismiss()
                            } else if userCancelled {
                                print("Purchase was cancelled")
                            }
                        }
                    }
                }) {
                    Text("Subscribe Now")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Upgrade")
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
        }
    }
}

struct PurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseView()
            .environmentObject(WatchViewModel())
    }
}
