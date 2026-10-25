//
//  FeatureControlFetcher.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 31/08/26.
//

struct FeatureControlResponse: JSONDecodable {
    let variant: String
}

protocol FeatureControlFetcherProtocol: AnyObject {
    func getFeatureControlVariant(key: String) async -> String
}

final class FeatureControlFetcher: FeatureControlFetcherProtocol {
    func getFeatureControlVariant(key: String) async -> String {
        do {
            let response: FeatureControlResponse = try await supabaseClient
                .from("feature_control")
                .select("variant, key")
                .eq("key", value: key)
                .single()
                .execute()
                .value
            
            return response.variant
        }
        catch {
            return "DISABLED"
        }
    }
}
