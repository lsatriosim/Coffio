//
//  PushNotificationManager.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 30/07/26.
//

import Foundation
import UserNotifications
import UIKit
import Supabase

final class PushNotificationManager {
    static let shared = PushNotificationManager()
    private init() {}
    private var pendingDeviceToken: String?
    
    func handleDeviceToken(_ token: String) async {
        print("📱 APNs token received")

        // Keep the token regardless of authentication state
        pendingDeviceToken = token

        await attemptToSaveToken()
    }
    
    func attemptToSaveToken() async {
        guard let token = pendingDeviceToken else {
            return
        }

        do {
            try await saveTokenToSupabase(
                token: token
            )

            // Token has successfully been persisted
            pendingDeviceToken = nil

        } catch {
            print("❌ Failed to save push token: \(error)")
        }
    }

    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } catch {
            print("Push authorization request failed: \(error)")
        }
    }

    func saveTokenToSupabase(token: String) async {
        guard let userId = supabaseClient.auth.currentUser?.id else {
            print("No authenticated user found; deferring token save.")
            return
        }

        struct PushTokenPayload: Encodable {
            let profile_id: UUID
            let token: String
            let platform: String
        }

        let payload = PushTokenPayload(
            profile_id: userId,
            token: token,
            platform: "ios"
        )

        do {
            // Upsert prevents duplicate rows if the same device re-registers
            try await supabaseClient
                .from("user_push_tokens")
                .upsert(payload, onConflict: "profile_id, token")
                .execute()
            
            print("Successfully saved device token to Supabase")
        } catch {
            print("Error saving token to Supabase: \(error)")
        }
    }
}
