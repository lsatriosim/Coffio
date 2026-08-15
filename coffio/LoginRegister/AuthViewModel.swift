//
//  AuthViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/04/26.
//

import AuthenticationServices
import CryptoKit
import Foundation
import GoogleSignIn
import Security
import SwiftUI

@MainActor
final class AuthViewModel: NSObject, ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var popUpErrorMessage: String = ""
    @Published var isError: Bool = false
    @Published var showRegister: Bool = false
    @Published var showDeleteAlert = false
    private var currentNonce: String?
    
    func updateShowRegister(isPresented: Bool) {
        showRegister = isPresented
        resetState()
    }

    
    func resetState() {
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = nil
        isError = false
    }

    func login() async {
        isLoading = true
        guard isValid() else { return }

        do {
            try await AuthenticationService.shared.login(email: email, password: password)
            resetState()
        } catch {
            isError = true
            popUpErrorMessage = "username or email is invalid"
        }

        isLoading = false
    }

    func register() async {
        isLoading = true
        guard isValid() else {
            return
        }

        do {
            try await AuthenticationService.shared.signUp(email: email, password: password)
            resetState()
        } catch {
            isError = true
            popUpErrorMessage = "Failed to register. Please try again!"
        }

        isLoading = false
        resetState()
    }
    
    func isValid() -> Bool {
        errorMessage = nil
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "All field shouldn't empty"
            return false
        }
        
        if showRegister {
            guard !confirmPassword.isEmpty
            else {
                errorMessage = "All field shouldn't empty"
                return false
            }
            
            guard password == confirmPassword else {
                errorMessage = "Password doesn't match"
                return false
            }
        }
        return true
    }
    
    func logout() async {
        do {
            try await AuthenticationService.shared.logout()
        }
        catch {
            print("Failed to logout")
        }
    }
    
    func deleteAccount() async {
        isLoading = true
        do {
            try await AuthenticationService.shared.deleteAccount()
            resetState()
        } catch {
            isError = true
            popUpErrorMessage = "Failed to delete account. Please try again later."
        }
        isLoading = false
    }
    
    func performGoogleSupabaseSignIn() {
        // 1. Get the top-most root view controller to present the Google prompt
        guard let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
            .first else { return }
        
        isLoading = true
        errorMessage = nil
        
        // 2. Trigger native Google Sign-In
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                self.isLoading = false
                
                // Swift alternative to check if the user canceled the login sheet
                if let signError = error as? GIDSignInError, signError.code == .canceled {
                    return
                }
                
                self.isError = true
                self.popUpErrorMessage = error.localizedDescription
                return
            }
            
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                self.isLoading = false
                self.isError = true
                self.popUpErrorMessage = "Failed to retrieve ID Token from Google."
                return
            }
            
            // 3. Forward token string to the centralized AuthenticationService
            Task {
                do {
                    try await AuthenticationService.shared.loginWithGoogle(idToken: idToken)
                    self.resetState()
                } catch {
                    self.isError = true
                    self.popUpErrorMessage = error.localizedDescription
                }
                self.isLoading = false
            }
        }
    }
        
    func handleAppleSignInCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = appleIDCredential.identityToken,
                  let idTokenString = String(data: identityTokenData, encoding: .utf8) else {
                isError = true
                popUpErrorMessage = "Failed to retrieve ID Token from Apple."
                return
            }
            
            var fullName: String?
            if let nameComponents = appleIDCredential.fullName {
                fullName = PersonNameComponentsFormatter().string(from: nameComponents)
            }
            
            let rawNonce = currentNonce ?? ""
            isLoading = true
            
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                defer { self.isLoading = false }
                
                do {
                    try await AuthenticationService.shared.loginWithApple(
                        idToken: idTokenString,
                        nonce: rawNonce,
                        fullName: fullName
                    )
                    self.resetState()
                } catch {
                    self.isError = true
                    self.popUpErrorMessage = error.localizedDescription
                }
            }
            
        case .failure(let error):
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                return
            }
            isError = true
            popUpErrorMessage = error.localizedDescription
        }
    }

    func prepareAppleNonce() -> String {
        let rawNonce = randomNonceString()
        currentNonce = rawNonce
        return sha256(rawNonce)
    }
}

private extension AuthViewModel {
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
