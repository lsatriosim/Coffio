//
//  coffioApp.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/03/26.
//

import SwiftUI

@main
struct coffioApp: App {
    let authService: AuthenticationService = AuthenticationService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .task {
                    print("INFO DICT:", Bundle.main.infoDictionary ?? [:])
                }
        }
    }
}
