//
//  CommentRequest.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/05/26.
//


struct CommentRequest: Encodable {
    let threadId: String
    let userId: String
    let content: String
    let parentCommentId: String?

    enum CodingKeys: String, CodingKey {
        case threadId = "thread_id"
        case userId = "user_id"
        case content = "content"
        case parentCommentId = "parent_comment_id"
    }
}
