//
//  SupabaseClient.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/04/26.
//

import Foundation
import Supabase

private let supabaseHost: String = {
    guard let host = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_HOST") as? String else {
        fatalError("SUPABASE_HOST not found in Info.plist")
    }
    return host
}()

private let supabaseKey: String = {
    guard let host = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
        fatalError("SUPABASE_HOST not found in Info.plist")
    }
    return host
}()

let supabaseClient = SupabaseClient(
    supabaseURL: URL(string: supabaseHost)!,
    supabaseKey: supabaseKey
)
