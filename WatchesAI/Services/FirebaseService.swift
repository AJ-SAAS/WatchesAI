import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Sign in anonymously
    func signInAnonymously(completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let user = result?.user else { return }
            completion(.success(user.uid))
        }
    }
    
    // Add a watch to Firestore
    func addWatch(_ watch: Watch, forUser uid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let data = try Firestore.Encoder().encode(watch)
            db.collection("users").document(uid).collection("watches").document(watch.id).setData(data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // Fetch watches for a user
    func fetchWatches(forUser uid: String, completion: @escaping (Result<[Watch], Error>) -> Void) {
        db.collection("users").document(uid).collection("watches").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            let watches = documents.compactMap { try? $0.data(as: Watch.self) }
            completion(.success(watches))
        }
    }

    // Upload watch image to Firebase Storage
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not compress image"])))
            return
        }

        let filename = UUID().uuidString + ".jpg"
        let storageRef = Storage.storage().reference().child("watch_images/\(filename)")

        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let urlString = url?.absoluteString {
                    completion(.success(urlString))
                } else {
                    completion(.failure(NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not get download URL"])))
                }
            }
        }
    }
}

