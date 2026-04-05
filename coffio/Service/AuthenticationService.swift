//
//  AuthenticationService.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/04/26.
//

import Foundation

final class AuthenticationService {
    static let shared: AuthenticationService = AuthenticationService()
    
    func login(email: String, password: String) async throws {
        try await supabaseClient.auth.signIn(email: email, password: password)
    }
}
