//
//  coffioApp.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/03/26.
//

import SwiftUI
import GoogleSignIn

@main
struct coffioApp: App {
    let authService: AuthenticationService = AuthenticationService.shared
    let locationProvider: LocationProvider = LocationProvider.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .task {
                    print("INFO DICT:", Bundle.main.infoDictionary ?? [:])
                }
                .onOpenURL { url in
                    _ = GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
