//
//  coffioApp.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/03/26.
//

import GoogleSignIn
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Callback when APNs returns a device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let pushToken = tokenParts.joined()
        
        // Pass the token to your auth or push service
        Task {
                await PushNotificationManager.shared.handleDeviceToken(pushToken)
            }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

@main
struct coffioApp: App {
    // 2. Attach the AppDelegate adaptor
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let authService: AuthenticationService = AuthenticationService.shared
    let locationProvider: LocationProvider = LocationProvider.shared
    
    @StateObject private var navigationRouter = AppNavigationRouter()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(authService)
            .environmentObject(navigationRouter) // Inject into environment for child views
            .task {
                await PushNotificationManager.shared.requestPermission()
            }
            .onOpenURL { url in
                // 2. Intercept URL with our own App Deeplink Handler first
                let wasDeeplinkHandled = navigationRouter.processIncomingURL(url)
                
                // 3. If our handler didn't care about it, pass it to Google Sign-In as a fallback
                if !wasDeeplinkHandled {
                    _ = GIDSignIn.sharedInstance.handle(url)
                }
            }
        }
    }
}
