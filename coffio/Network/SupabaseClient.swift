//
//  SupabaseClient.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/04/26.
//

import Foundation
import Supabase

let supabaseClient = SupabaseClient(
    supabaseURL: URL(string: "https://zbnrcvrbdlrnguutylex.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpibnJjdnJiZGxybmd1dXR5bGV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI2MzA2NTksImV4cCI6MjA4ODIwNjY1OX0.taAUfNNwck5fF7CiWsdwqFhRz7_x3sOOi021RAdyoeA"
)
