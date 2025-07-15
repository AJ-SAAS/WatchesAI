// ViewModels/CollectionViewModel.swift
import Foundation
import FirebaseAuth
import FirebaseFirestore

class CollectionViewModel: ObservableObject {
    @Published var watches: [Watch] = []
    @Published var currentWatchID: String?
    @Published var toastMessage: String?
    @Published var selectedType: String = "Collection"
    
    func setType(_ type: String) {
        selectedType = type
        fetchWatches()
    }
    
    func fetchWatches() {
        guard let userID = Auth.auth().currentUser?.uid else {
            toastMessage = "Please log in"
            return
        }
        FirebaseService.shared.fetchUserWatches(for: userID) { result in
            switch result {
            case .success(let watches):
                self.watches = watches.filter { $0.type == self.selectedType }
                self.currentWatchID = self.watches.first?.id
            case .failure(let error):
                self.toastMessage = "Error fetching watches: \(error.localizedDescription)"
            }
        }
    }
    
    func swipe(watch: Watch, direction: SwipeDirection) {
        guard let userID = Auth.auth().currentUser?.uid else {
            toastMessage = "Please log in"
            return
        }
        if direction == .left {
            FirebaseService.shared.deleteWatch(watch, for: userID) { result in
                switch result {
                case .success:
                    self.watches.removeAll { $0.id == watch.id }
                    self.currentWatchID = self.watches.first?.id
                    self.toastMessage = "Removed from \(self.selectedType)!"
                case .failure(let error):
                    self.toastMessage = "Error: \(error.localizedDescription)"
                }
            }
        } else {
            self.currentWatchID = self.watches.drop { $0.id == watch.id }.first?.id
        }
    }
}
