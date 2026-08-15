//
//  AppNavigationRouter.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 19/07/26.
//


import SwiftUI

@MainActor
class AppNavigationRouter: ObservableObject {
    @Published var discoverPath: NavigationPath = NavigationPath()
    @Published var selectedTab = 0
    
    private let deeplinkHandler = DeeplinkHandler()
    
    public enum DiscoverDestination: Codable, Hashable {
        case eventDetail(id: String)
    }
         
    func navigateToEvent(id: String) {
        discoverPath.append(DiscoverDestination.eventDetail(id: id))
    }
    
    @discardableResult
    func processIncomingURL(_ url: URL) -> Bool {
        guard let target = deeplinkHandler.handle(url: url) else {
            return false
        }
         
        switch target {
        case .event(let eventId):
            navigateToEvent(id: eventId)
        }
         
        return true
    }
}
