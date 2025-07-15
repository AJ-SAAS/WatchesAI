import SwiftUI
import FirebaseAuth

struct ManageAccountView: View {
    @EnvironmentObject var authService: AuthService
    @State private var newEmail = ""
    @State private var toastMessage: String?
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                Form {
                    Section(header: Text("Update Email")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        TextField("New Email", text: $newEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .font(.system(.body, design: .default, weight: .regular))
                        
                        Button("Send Verification Email") {
                            guard !newEmail.isEmpty else {
                                toastMessage = "Please enter a valid email"
                                return
                            }
                            authService.updateEmail(to: newEmail) { result in
                                switch result {
                                case .success:
                                    toastMessage = "Verification email sent! Please check your inbox."
                                case .failure(let error):
                                    toastMessage = "Error: \(error.localizedDescription)"
                                }
                            }
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.blue)
                        .padding(.vertical, 4)
                        .accessibilityLabel("Send Verification Email")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                    
                    Section(header: Text("Note")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        Text("A verification email will be sent to your new email address. Please verify it to update your email. To update your password, log out and use the 'Forgot Password' option on the login screen.")
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding(.vertical, 4)
                            .accessibilityLabel("Email and password update instructions")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                }
                .navigationTitle("Manage Account")
                .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                .overlay(
                    toastMessage != nil ?
                        Text(toastMessage!)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .transition(.opacity)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    toastMessage = nil
                                }
                            }
                        : nil,
                    alignment: .top
                )
            }
        }
    }
}

struct ManageAccountView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ManageAccountView()
                .environmentObject(AuthService())
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
            ManageAccountView()
                .environmentObject(AuthService())
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
}
