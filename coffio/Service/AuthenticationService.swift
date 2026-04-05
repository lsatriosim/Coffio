//
//  AuthenticationService.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/04/26.
//

import Foundation
import Supabase

@MainActor
final class AuthenticationService: ObservableObject {
    static let shared: AuthenticationService = AuthenticationService()
    @Published var user: User? = nil
    @Published var showAuthPage: Bool = false
    
    init() {
        Task {
            await fetchUserProfile()
            
            if self.user == nil {
                showAuthPage = true
            }
        }
    }
    
    func login(email: String, password: String) async throws {
        try await supabaseClient.auth.signIn(email: email, password: password)
        await fetchUserProfile()
        showAuthPage = false
    }
    
    func logout() async throws {
        try await supabaseClient.auth.signOut()
        
        showAuthPage = true
    }
    
    func signUp(email: String, password: String) async throws {
        try await supabaseClient.auth.signUp(email: email, password: password)
        showAuthPage = false
    }
    
    func fetchUserProfile() async {
        do {
            let session: Session = try await supabaseClient.auth.session
            let user: User = session.user
            
            self.user = user
        }
        catch {
            self.user = nil
        }
    }
}
