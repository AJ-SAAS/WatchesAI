import FirebaseAuth
import Foundation

class AuthService: ObservableObject {
    @Published var isAuthenticated: Bool = false
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.isAuthenticated = true
                completion(.success(()))
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.isAuthenticated = true
                completion(.success(()))
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
        } catch {
            print("Sign-out error: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount(completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"]))
            return
        }
        user.delete { error in
            if let error = error {
                completion(error)
            } else {
                self.isAuthenticated = false
                completion(nil)
            }
        }
    }
    
    func updateEmail(to email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }
        user.sendEmailVerification(beforeUpdatingEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
