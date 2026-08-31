//
//  FeatureControlService.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 31/08/26.
//

final class FeatureControlService {
    static var sharedInstance: FeatureControlService = FeatureControlService()
    private let fetcher: FeatureControlFetcherProtocol = FeatureControlFetcher()
    
    func isInternalGuestEnabled() async -> Bool {
        let variant = await fetcher.getFeatureControlVariant(key: "discover_event_internal_guest")
        return variant == "ENABLED"
    }
}
