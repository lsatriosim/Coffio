//
//  ReportFetcher.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 16/07/26.
//

import Foundation

final class ReportFetcher {
    
    func submitReport(request: ReportRequest) async throws {
        try await supabaseClient
            .from("reports")
            .insert(request)
            .execute()
    }
    
    func fetchMyReports(reporterId: String) async throws -> [UserReportItem] {
        let response = try await supabaseClient
            .from("reports")
            .select("reporter_id, report_type, thread_id, reported_user_id")
            .eq("reporter_id", value: reporterId.lowercased())
            .execute()
            
        let decoder = JSONDecoder()
        return try decoder.decode([UserReportItem].self, from: response.data)
    }
}
