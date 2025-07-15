// ViewModels/LogWatchViewModel.swift
import SwiftUI
import FirebaseAuth
import PhotosUI

class LogWatchViewModel: ObservableObject {
    @Published var brand = ""
    @Published var model = ""
    @Published var year = ""
    @Published var movement = ""
    @Published var material = ""
    @Published var style = ""
    @Published var type = "Collection"
    @Published var complications = ""
    @Published var value = ""
    @Published var image: UIImage?
    @Published var imagePickerItem: PhotosPickerItem?
    @Published var toastMessage: String?
    @Published var isLoading = false
    
    private let allowedMovements = ["Automatic", "Manual", "Quartz"]
    private let allowedMaterials = ["Stainless Steel", "Gold", "Titanium", "Ceramic"]
    private let allowedStyles = ["Dive", "Dress", "Chronograph", "Pilot"]
    private let allowedTypes = ["Collection", "Wishlist"]
    
    var isFormValid: Bool {
        !brand.isEmpty &&
        !model.isEmpty &&
        !year.isEmpty &&
        !movement.isEmpty &&
        !material.isEmpty &&
        !style.isEmpty &&
        !type.isEmpty &&
        !value.isEmpty &&
        Double(value) != nil
    }
    
    func validateInputs() -> Bool {
        guard isFormValid else {
            toastMessage = "Please fill in all required fields correctly."
            return false
        }
        guard allowedMovements.contains(movement) else {
            toastMessage = "Please select a valid movement."
            return false
        }
        guard allowedMaterials.contains(material) else {
            toastMessage = "Please select a valid material."
            return false
        }
        guard allowedStyles.contains(style) else {
            toastMessage = "Please select a valid style."
            return false
        }
        guard allowedTypes.contains(type) else {
            toastMessage = "Please select a valid type."
            return false
        }
        return true
    }
    
    func saveWatch(completion: @escaping (Result<Void, Error>) -> Void) {
        guard validateInputs() else {
            completion(.failure(NSError(domain: "ValidationError", code: -1, userInfo: [NSLocalizedDescriptionKey: toastMessage ?? "Invalid input"])))
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            toastMessage = "Please log in"
            completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        
        isLoading = true
        let watchID = UUID().uuidString
        let watch = Watch(
            id: watchID,
            brand: brand,
            model: model,
            year: year,
            movement: movement.isEmpty ? "Unknown" : movement,
            material: material.isEmpty ? "Unknown" : material,
            style: style.isEmpty ? "Unknown" : style,
            value: Double(value) ?? 0.0,
            type: type.isEmpty ? "Collection" : type,
            complications: complications.isEmpty ? "None" : complications,
            imageURL: nil
        )
        
        if let image = image {
            FirebaseService.shared.uploadPhoto(image, for: watchID, userID: userID) { result in
                switch result {
                case .success(let url):
                    let updatedWatch = Watch(
                        id: watch.id,
                        brand: watch.brand,
                        model: watch.model,
                        year: watch.year,
                        movement: watch.movement,
                        material: watch.material,
                        style: watch.style,
                        value: watch.value,
                        type: watch.type,
                        complications: watch.complications,
                        imageURL: url
                    )
                    FirebaseService.shared.saveWatch(updatedWatch, for: userID) { saveResult in
                        self.isLoading = false
                        switch saveResult {
                        case .success:
                            self.toastMessage = "Watch Added!"
                            self.resetForm()
                            completion(.success(()))
                        case .failure(let error):
                            self.toastMessage = "Error: \(error.localizedDescription)"
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    self.isLoading = false
                    self.toastMessage = "Error uploading image: \(error.localizedDescription)"
                    completion(.failure(error))
                }
            }
        } else {
            FirebaseService.shared.saveWatch(watch, for: userID) { result in
                self.isLoading = false
                switch result {
                case .success:
                    self.toastMessage = "Watch Added!"
                    self.resetForm()
                    completion(.success(()))
                case .failure(let error):
                    self.toastMessage = "Error: \(error.localizedDescription)"
                    completion(.failure(error))
                }
            }
        }
    }
    
    func resetForm() {
        brand = ""
        model = ""
        year = ""
        movement = ""
        material = ""
        style = ""
        type = "Collection"
        complications = ""
        value = ""
        image = nil
        imagePickerItem = nil
    }
    
    func loadImage() {
        Task {
            if let item = imagePickerItem, let data = try? await item.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                image = uiImage
            } else {
                toastMessage = "Failed to load image"
            }
        }
    }
}
