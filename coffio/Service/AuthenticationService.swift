//
//  AuthenticationService.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/04/26.
//

import Foundation
import Supabase

struct ProfileUser: JSONDecodable {
    let id: String
    let username: String
    let avatarUrl: String?
    let fullName: String
    let email: String
    let role: Role
    
    enum Role: String, JSONDecodable {
        case user = "user"
        case admin = "admin"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case avatarUrl = "avatar_url"
        case fullName = "full_name"
        case email
        case role
    }
}

@MainActor
final class AuthenticationService: ObservableObject {
    static let shared: AuthenticationService = AuthenticationService()
    @Published var user: ProfileUser? = nil
    @Published var showAuthPage: Bool = false
    
    init() {
        Task {
            await fetchUserProfile()
        }
    }
    
    func login(email: String, password: String) async throws {
        try await supabaseClient.auth.signIn(email: email, password: password)
        await fetchUserProfile()
        showAuthPage = false
    }
    
    func logout() async throws {
        try await supabaseClient.auth.signOut()
        user = nil
        
        showAuthPage = true
    }
    
    func signUp(email: String, password: String) async throws {
        try await supabaseClient.auth.signUp(email: email, password: password)
        showAuthPage = false
    }
    
    func showLoginPage() {
        showAuthPage = true
    }
    
    func fetchUserProfile() async {
        do {
            let session: Session = try await supabaseClient.auth.session
            guard !session.isExpired else {
                try await logout()
                return
            }
            let user: User = session.user
            let userId: String = user.id.uuidString
            
            let response = try await supabaseClient
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
            
            let userProfile: ProfileUser = try JSONDecoder().decode(ProfileUser.self, from: response.data)
            self.user = userProfile
        }
        catch {
            self.user = nil
        }
    }
}
