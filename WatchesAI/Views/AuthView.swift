import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var viewModel: WatchViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSignUp: Bool = true
    @State private var showingResetPassword: Bool = false
    @State private var resetEmail: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    VStack(spacing: geometry.size.width > 600 ? 24 : 20) {
                        // Logo (replace with your app's logo)
                        Image("WatchesAI_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: min(geometry.size.width * 0.4, 200))
                            .padding(.top, geometry.size.width > 600 ? 40 : 24)
                            .accessibilityLabel("WatchesAI Logo")
                        
                        // Title
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .font(.system(.largeTitle, design: .default, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .accessibilityLabel(isSignUp ? "Create Account" : "Sign In")
                        
                        // Email Field
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .accessibilityLabel("Email")
                        
                        // Password Field
                        SecureField("Password", text: $password)
                            .textContentType(isSignUp ? .newPassword : .password)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .accessibilityLabel("Password")
                        
                        // Confirm Password Field (Sign Up only)
                        if isSignUp {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .disableAutocorrection(true)
                                .font(.system(.body, design: .default, weight: .regular))
                                .padding()
                                .background(.gray.opacity(0.1))
                                .cornerRadius(8)
                                .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                                .accessibilityLabel("Confirm Password")
                        }
                        
                        // Error Message
                        if let error = viewModel.authError {
                            Text(error)
                                .font(.system(.subheadline, design: .default, weight: .regular))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                                .accessibilityLabel("Error: \(error)")
                        }
                        
                        // Sign Up/Sign In Button
                        Button(isSignUp ? "Sign Up" : "Sign In") {
                            if isSignUp {
                                if password == confirmPassword {
                                    viewModel.signUp(email: email, password: password)
                                } else {
                                    viewModel.authError = "Passwords do not match"
                                }
                            } else {
                                viewModel.signIn(email: email, password: password)
                            }
                        }
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(email.isEmpty || password.isEmpty || (isSignUp && confirmPassword.isEmpty) ? .gray : .black)
                        .cornerRadius(8)
                        .disabled(email.isEmpty || password.isEmpty || (isSignUp && confirmPassword.isEmpty))
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .accessibilityLabel(isSignUp ? "Sign Up" : "Sign In")
                        
                        // Toggle Sign Up/Sign In
                        Button(isSignUp ? "Already have an account? Sign In" : "Need an account? Sign Up") {
                            isSignUp.toggle()
                            viewModel.authError = nil
                            email = ""
                            password = ""
                            confirmPassword = ""
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.black)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .accessibilityLabel(isSignUp ? "Switch to Sign In" : "Switch to Sign Up")
                        
                        // Forgot Password
                        Button("Forgot Password?") {
                            showingResetPassword = true
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.black)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                        .accessibilityLabel("Forgot Password")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
                }
                .background(Color.white.ignoresSafeArea())
                .sheet(isPresented: $showingResetPassword) {
                    VStack(spacing: geometry.size.width > 600 ? 24 : 20) {
                        Text("Reset Password")
                            .font(.system(.largeTitle, design: .default, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .accessibilityLabel("Reset Password")
                        
                        TextField("Email", text: $resetEmail)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .accessibilityLabel("Reset Email")
                        
                        Button("Send Reset Email") {
                            viewModel.resetPassword(email: resetEmail)
                            showingResetPassword = false
                            resetEmail = ""
                        }
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(resetEmail.isEmpty ? .gray : .black)
                        .cornerRadius(8)
                        .disabled(resetEmail.isEmpty)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .accessibilityLabel("Send Reset Email")
                        
                        Button("Cancel") {
                            showingResetPassword = false
                            resetEmail = ""
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.black)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                        .accessibilityLabel("Cancel")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
                    .background(Color.white.ignoresSafeArea())
                }
                .onChange(of: email) { _, _ in viewModel.authError = nil }
                .onChange(of: isSignUp) { _, _ in viewModel.authError = nil }
                .onChange(of: viewModel.isAuthenticated) { _, newValue in
                    if newValue {
                        // Transition handled by WatchesAIApp.swift
                    }
                }
            }
        }
    }
}

#Preview("iPhone 14") {
    AuthView()
        .environmentObject(WatchViewModel())
}

#Preview("iPad Pro") {
    AuthView()
        .environmentObject(WatchViewModel())
}
