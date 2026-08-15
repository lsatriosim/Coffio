import Foundation

import Foundation

final class DeeplinkHandler {
    
    private let supportedHost = "www.coffio.id"
    private let supportedScheme = "coffio"
    
    func handle(url: URL) -> DeeplinkTarget? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        let isWebUniversalLink = components.scheme == "https" && components.host == supportedHost
        let isCustomScheme = components.scheme == supportedScheme
        
        guard isWebUniversalLink || isCustomScheme else { return nil }
        
        // Extract all path components, filtering out empty strings caused by trailing/leading slashes
        var pathComponents = components.path.split(separator: "/").map(String.init)
        
        // If it's a custom scheme, the "host" (e.g., "event") acts as the first path component
        if isCustomScheme, let host = components.host {
            pathComponents.insert(host, at: 0)
        }
        
        // Now both formats will look like: ["event", "fa7c880c-..."]
        guard pathComponents.count >= 2 else { return nil }
        
        let targetType = pathComponents[0].lowercased()
        let idString = pathComponents[1]
        
        // Match explicit routing actions
        switch targetType {
        case "event":
            return .event(id: idString)
        default:
            return nil
        }
    }
}
