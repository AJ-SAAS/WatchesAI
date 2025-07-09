import Foundation
import Combine
import RevenueCat
import UIKit
import FirebaseAuth

class WatchViewModel: ObservableObject {
    @Published var watches: [Watch] = []
    @Published var watchCount: Int = 0
    @Published var isSubscribed: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var authError: String?

    private let firebaseService = FirebaseService.shared
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Sign-up error: \(error.localizedDescription)")
                self?.authError = error.localizedDescription
                self?.isAuthenticated = false
                return
            }
            guard let user = result?.user else { return }
            print("Signed up user UID: \(user.uid)")
            self?.isAuthenticated = true
            self?.authError = nil
            self?.fetchWatches(for: user.uid)
            self?.checkSubscriptionStatus()
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Sign-in error: \(error.localizedDescription)")
                self?.authError = error.localizedDescription
                self?.isAuthenticated = false
                return
            }
            guard let user = result?.user else { return }
            print("Signed in user UID: \(user.uid)")
            self?.isAuthenticated = true
            self?.authError = nil
            self?.fetchWatches(for: user.uid)
            self?.checkSubscriptionStatus()
        }
    }
    
    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                print("Password reset error: \(error.localizedDescription)")
                self?.authError = "Failed to send reset email: \(error.localizedDescription)"
            } else {
                self?.authError = "Password reset email sent"
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            watches = []
            watchCount = 0
            isSubscribed = false
            authError = nil
            print("User signed out")
        } catch {
            print("Sign-out error: \(error.localizedDescription)")
            authError = "Failed to sign out: \(error.localizedDescription)"
        }
    }
    
    func fetchWatches(for uid: String) {
        firebaseService.fetchWatches(forUser: uid) { [weak self] result in
            switch result {
            case .success(let watches):
                self?.watches = watches
                self?.watchCount = watches.count
            case .failure(let error):
                print("Error fetching watches: \(error.localizedDescription)")
            }
        }
    }
    
    func addWatch(_ watch: Watch, image: UIImage?, forUser uid: String) {
        var mutableWatch = watch
        if let image = image {
            firebaseService.uploadImage(image) { [weak self] result in
                switch result {
                case .success(let imageURL):
                    mutableWatch.imageURL = imageURL
                    self?.saveWatchToFirestore(mutableWatch, uid: uid)
                case .failure(let error):
                    print("Image upload failed: \(error.localizedDescription)")
                    self?.saveWatchToFirestore(mutableWatch, uid: uid)
                }
            }
        } else {
            saveWatchToFirestore(mutableWatch, uid: uid)
        }
    }
    
    private func saveWatchToFirestore(_ watch: Watch, uid: String) {
        firebaseService.addWatch(watch, forUser: uid) { [weak self] result in
            switch result {
            case .success:
                self?.fetchWatches(for: uid)
            case .failure(let error):
                print("Error adding watch: \(error.localizedDescription)")
            }
        }
    }
    
    var totalValue: Double {
        watches.reduce(0) { $0 + $1.value }
    }
    
    var mostOwnedBrand: String {
        let brandCounts = watches.reduce(into: [String: Int]()) { counts, watch in
            counts[watch.brand, default: 0] += 1
        }
        return brandCounts.max(by: { $0.value < $1.value })?.key ?? "None"
    }
    
    var favoriteStyle: String {
        let styleCounts = watches.reduce(into: [String: Int]()) { counts, watch in
            if let style = watch.style {
                counts[style, default: 0] += 1
            }
        }
        return styleCounts.max(by: { $0.value < $1.value })?.key ?? "None"
    }
    
    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            if let error = error {
                print("Subscription check error: \(error.localizedDescription)")
                return
            }
            self?.isSubscribed = customerInfo?.activeSubscriptions.contains("premium") ?? false
        }
    }
}
