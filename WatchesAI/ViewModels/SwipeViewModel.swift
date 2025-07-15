// ViewModels/SwipeViewModel.swift
import Foundation
import FirebaseAuth
import FirebaseFirestore

class SwipeViewModel: ObservableObject {
    @Published var cards: [Watch] = []
    @Published var currentCardID: String?
    @Published var toastMessage: String?
    
    func fetchCards() {
        print("Fetching swipe cards...")
        FirebaseService.shared.fetchSwipeCards { result in
            switch result {
            case .success(let cards):
                print("Fetched \(cards.count) cards")
                DispatchQueue.main.async {
                    self.cards = cards
                    self.currentCardID = cards.first?.id
                    if cards.isEmpty {
                        self.toastMessage = "No watches available"
                    }
                }
            case .failure(let error):
                print("Fetch error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.toastMessage = "Error fetching cards: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func swipe(card: Watch, direction: SwipeDirection) {
        guard let userID = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.toastMessage = "Please log in"
            }
            return
        }
        if direction == .right {
            let watchToSave = Watch(
                id: UUID().uuidString,
                brand: card.brand,
                model: card.model,
                year: card.year,
                movement: card.movement,
                material: card.material,
                style: card.style,
                value: card.value,
                type: card.type,
                complications: card.complications,
                imageURL: card.imageURL
            )
            FirebaseService.shared.saveWatch(watchToSave, for: userID) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.toastMessage = "Added to \(watchToSave.type)!"
                    case .failure(let error):
                        self.toastMessage = "Error: \(error.localizedDescription)"
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.cards.removeAll { $0.id == card.id }
            self.currentCardID = self.cards.first?.id
        }
    }
}
