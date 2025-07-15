import SwiftUI

struct CollectionView: View {
    @StateObject private var viewModel = CollectionViewModel()
    @State private var selectedTab: String = "Collection"
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 0) {
                    Picker("Collection Type", selection: $selectedTab) {
                        Text("Current").tag("Collection")
                        Text("Wishlist").tag("Wishlist")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                    .padding(.vertical, 8)
                    .onChange(of: selectedTab) { _, _ in
                        viewModel.fetchWatches()
                    }
                    
                    Text("Watches: \(viewModel.watches.count)")
                        .font(.headline)
                        .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                    
                    ZStack {
                        ForEach(viewModel.watches) { watch in
                            WatchCardView(card: watch, onSwipe: { direction in
                                viewModel.swipe(watch: watch, direction: direction)
                            })
                            .offset(x: viewModel.currentWatchID == watch.id ? 0 : 1000)
                            .animation(.spring(), value: viewModel.currentWatchID)
                        }
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                    .onAppear {
                        viewModel.setType(selectedTab)
                        viewModel.fetchWatches()
                    }
                    
                    Spacer()
                }
                .navigationTitle("My Collection")
                .background(Color(.systemGroupedBackground))
                .ignoresSafeArea(.all, edges: .bottom)
                .overlay(
                    viewModel.toastMessage != nil ?
                        Text(viewModel.toastMessage!)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .transition(.opacity)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    viewModel.toastMessage = nil
                                }
                            }
                        : nil,
                    alignment: .top
                )
            }
        }
    }
}

struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CollectionView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
            CollectionView()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
}
