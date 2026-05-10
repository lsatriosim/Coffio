//
//  DiscussionUser.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/05/26.
//


import Foundation

// MARK: - User Profile Model
struct DiscussionUser: JSONDecodable, Identifiable {
    let id: String
    let username: String?
    let avatarUrl: String?
    let fullName: String?
    let email: String?

    enum CodingKeys: String, CodingKey {
        case id, username, email
        case avatarUrl = "avatar_url"
        case fullName = "full_name"
    }
}

// MARK: - Discussion Thread Model
struct DiscussionThreadItem: JSONDecodable, Identifiable {
    let id: String
    let tag: String
    let title: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let user: DiscussionUser
    let commentCount: Int

    enum CodingKeys: String, CodingKey {
        case id, tag, title, content, user
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case commentCount = "comment_count"
    }
}

// MARK: - Discussion Comment Model
struct DiscussionCommentItem: JSONDecodable, Identifiable {
    let id: String
    let threadId: String
    let parentCommentId: String?
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let user: DiscussionUser
    let replyCount: Int

    enum CodingKeys: String, CodingKey {
        case id, content, user
        case threadId = "thread_id"
        case parentCommentId = "parent_comment_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case replyCount = "reply_count"
    }
}
