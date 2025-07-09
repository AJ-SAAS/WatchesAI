import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: WatchViewModel
    @State private var showingAddWatchView = false
    @State private var showingPurchaseView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Dashboard stats
                VStack(spacing: 15) {
                    Text("Total Watches: \(viewModel.watchCount)")
                        .font(.title2)
                    Text("Total Value: $\(viewModel.totalValue.currencyFormat)")
                        .font(.title2)
                    Text("Most Owned Brand: \(viewModel.mostOwnedBrand)")
                        .font(.title2)
                    Text("Favorite Style: \(viewModel.favoriteStyle)")
                        .font(.title2)
                }
                .padding()
                
                Spacer()
                
                // Add Watch button
                Button(action: {
                    if viewModel.watchCount < 3 || viewModel.isSubscribed {
                        showingAddWatchView = true
                    } else {
                        showingPurchaseView = true
                    }
                }) {
                    Text("Add New Watch")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("WatchesAI")
            .sheet(isPresented: $showingAddWatchView) {
                AddWatchView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showingPurchaseView) {
                PurchaseView()
                    .environmentObject(viewModel)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(WatchViewModel())
    }
}
