//
//  FeedbackRequest.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 12/09/26.
//

import Foundation

struct FeedbackRequest: JSONCodable {
    let reporterId: String
    let reportType: String
    let description: String
    let imageURLs: [String]
    
    enum CodingKeys: String, CodingKey {
        case reporterId = "reporter_id"
        case reportType = "report_type"
        case description
        case imageURLs = "image_urls"
    }
}
