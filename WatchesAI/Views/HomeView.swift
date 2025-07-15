// Views/HomeView.swift
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = SwipeViewModel()
    @State private var showAddWatch = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                cardStackView(geometry: geometry)
                addButtonView
                toastView
            }
            .onAppear {
                viewModel.fetchCards()
            }
            .sheet(isPresented: $showAddWatch) {
                AddWatchView()
            }
        }
    }
    
    private func cardStackView(geometry: GeometryProxy) -> some View {
        ZStack {
            if viewModel.cards.isEmpty {
                Text("No watches available")
                    .font(.system(.title, design: .default, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ForEach(viewModel.cards.reversed()) { card in
                    WatchCardView(
                        card: card,
                        onSwipe: { direction in
                            withAnimation(.spring()) {
                                viewModel.swipe(card: card, direction: direction)
                            }
                        }
                    )
                    .frame(maxWidth: min(geometry.size.width - 32, 400), alignment: .center)
                    .offset(y: card.id == viewModel.currentCardID ? 0 : -20)
                    .zIndex(card.id == viewModel.currentCardID ? 1 : 0)
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    private var addButtonView: some View {
        HStack {
            Spacer()
            VStack {
                Button(action: { showAddWatch = true }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                        .shadow(radius: 4)
                }
                .accessibilityLabel("Add New Watch")
                .padding(.top, 16)
                .padding(.trailing, 16)
                Spacer()
            }
        }
    }
    
    private var toastView: some View {
        Group {
            if let message = viewModel.toastMessage {
                Text(message)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            viewModel.toastMessage = nil
                        }
                    }
            }
        }
        .zIndex(2)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
            HomeView()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
}
