//
//  AuthViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/04/26.
//

import Foundation
import SwiftUI

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
        } catch {
            isError = true
            popUpErrorMessage = "username or email is invalid"
        }

        isLoading = false
        resetState()
    }

    func register() async {
        isLoading = true
        guard isValid() else {
            return
        }

        do {
            try await AuthenticationService.shared.signUp(email: email, password: password)
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
}
