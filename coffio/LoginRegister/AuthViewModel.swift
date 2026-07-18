//
//  AuthViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/04/26.
//

import Foundation
import SwiftUI
import GoogleSignIn

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var popUpErrorMessage: String = ""
    @Published var isError: Bool = false
    @Published var showRegister: Bool = false
    @Published var showDeleteAlert = false
    
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
}
