import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .font(.system(.body, design: .default, weight: .regular))
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(.body, design: .default, weight: .regular))
                    Button(action: {
                        if isSignUp {
                            signUp()
                        } else {
                            signIn()
                        }
                    }) {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .font(.system(.headline, design: .default, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: geometry.size.width > 600 ? 400 : .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .accessibilityLabel(isSignUp ? "Sign Up" : "Sign In")
                    .disabled(email.isEmpty || password.count < 6)
                    Button(action: {
                        isSignUp.toggle()
                    }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Need an account? Sign Up")
                            .font(.system(.body, design: .default, weight: .regular))
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel(isSignUp ? "Switch to Sign In" : "Switch to Sign Up")
                    Spacer()
                }
                .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
                .navigationTitle("WatchesAI")
                .alert(isPresented: $showErrorAlert) {
                    Alert(title: Text("Message"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                .background(Color(.systemGroupedBackground))
            }
        }
    }
    
    private func signUp() {
        authService.signUp(email: email, password: password) { result in
            switch result {
            case .success:
                errorMessage = ""
                showErrorAlert = false
            case .failure(let error):
                errorMessage = "Sign-up error: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
    }
    
    private func signIn() {
        authService.signIn(email: email, password: password) { result in
            switch result {
            case .success:
                errorMessage = ""
                showErrorAlert = false
            case .failure(let error):
                errorMessage = "Sign-in error: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AuthView()
                .environmentObject(AuthService())
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
            AuthView()
                .environmentObject(AuthService())
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
}
