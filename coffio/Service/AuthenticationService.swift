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
    
    func updateProfile(fullName: String) async throws {
        let session = try await supabaseClient.auth.session
        let userId = session.user.id.uuidString
        
        // Update Supabase
        try await supabaseClient
            .from("profiles")
            .update(["full_name": fullName])
            .eq("id", value: userId)
            .execute()
        
        // Refresh local user state so all observing ViewModels update
        await fetchUserProfile()
    }
    
    func uploadAvatar(data: Data) async throws {
        let session = try await supabaseClient.auth.session
        let userId = session.user.id.uuidString
        
        // 1. Define file path (e.g., profiles/USER_ID/avatar.jpg)
        // Using a timestamp or "avatar" with upsert ensures we manage storage efficiently
        let filePath = "\(userId)/avatar.jpg"
        
        // 2. Upload to Supabase Storage bucket "profile_images"
        _ = try await supabaseClient.storage
            .from("profile_images")
            .upload(
                filePath,
                data: data,
                options: FileOptions(contentType: "image/jpeg", upsert: true)
            )
        
        // 3. Get the Public URL
        let publicURL = try supabaseClient.storage
            .from("profile_images")
            .getPublicURL(path: filePath)
        
        // 4. Update the avatar_url in the profiles table
        try await supabaseClient
            .from("profiles")
            .update(["avatar_url": publicURL.absoluteString])
            .eq("id", value: userId)
            .execute()
        
        // 5. Refresh user profile to sync the UI
        await fetchUserProfile()
    }
}
