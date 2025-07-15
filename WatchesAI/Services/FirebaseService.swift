import Firebase
import FirebaseFirestore
import FirebaseStorage

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {}
    
    func fetchSwipeCards(completion: @escaping (Result<[Watch], Error>) -> Void) {
        db.collection("swipeCards").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            let watches = documents.compactMap { doc -> Watch? in
                let data = doc.data()
                return Watch(
                    id: doc.documentID,
                    brand: data["brand"] as? String ?? "",
                    model: data["model"] as? String ?? "",
                    year: data["year"] as? String ?? "",
                    movement: data["movement"] as? String ?? "",
                    material: data["material"] as? String ?? "",
                    style: data["style"] as? String ?? "",
                    value: data["value"] as? Double ?? 0.0,
                    type: data["type"] as? String ?? "Collection",
                    complications: data["complications"] as? String ?? "",
                    imageURL: data["imageURL"] as? String
                )
            }
            completion(.success(watches))
        }
    }
    
    func fetchUserWatches(for userID: String, completion: @escaping (Result<[Watch], Error>) -> Void) {
        db.collection("users").document(userID).collection("watches").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            let watches = documents.compactMap { doc -> Watch? in
                let data = doc.data()
                return Watch(
                    id: doc.documentID,
                    brand: data["brand"] as? String ?? "",
                    model: data["model"] as? String ?? "",
                    year: data["year"] as? String ?? "",
                    movement: data["movement"] as? String ?? "",
                    material: data["material"] as? String ?? "",
                    style: data["style"] as? String ?? "",
                    value: data["value"] as? Double ?? 0.0,
                    type: data["type"] as? String ?? "Collection",
                    complications: data["complications"] as? String ?? "",
                    imageURL: data["imageURL"] as? String
                )
            }
            completion(.success(watches))
        }
    }
    
    func saveWatch(_ watch: Watch, for userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let watchData: [String: Any] = [
            "id": watch.id,
            "brand": watch.brand,
            "model": watch.model,
            "year": watch.year,
            "movement": watch.movement,
            "material": watch.material,
            "style": watch.style,
            "value": watch.value,
            "type": watch.type,
            "complications": watch.complications,
            "imageURL": watch.imageURL as Any
        ]
        db.collection("users").document(userID).collection("watches").document(watch.id).setData(watchData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deleteWatch(_ watch: Watch, for userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("users").document(userID).collection("watches").document(watch.id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func uploadPhoto(_ image: UIImage, for watchID: String, userID: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not compress image"])))
            return
        }
        let storageRef = storage.reference().child("users/\(userID)/watches/\(watchID).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let urlString = url?.absoluteString {
                    completion(.success(urlString))
                } else {
                    completion(.failure(NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not get download URL"])))
                }
            }
        }
    }
}
