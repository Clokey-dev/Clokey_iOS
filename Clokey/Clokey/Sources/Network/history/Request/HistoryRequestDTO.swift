//
//  HistoryRequestDTO.swift
//  Clokey
//
//  Created by 황상환 on 1/28/25.
//

import Foundation


// 좋아요
public struct HistoryLikeRequestDTO: Codable {
    public let historyId: String
    public let liked: Bool
}

// 댓글 작성
public struct HistoryCommentWriteRequestDTO: Codable {
    public let content: String
    public let commentId: Int64?
}

// 댓글 수정
public struct HistoryCommentUpdateRequestDTO: Codable {
    public let content: String
}

// 세부 기록 추가
public struct HistoryCreateRequestDTO: Codable {
    public let content: String
    public let clothes: [Int64]
    public let hashtags: [String]
    public let visibility: String
    public let date: String   
    
    public init(
        content: String,
        clothes: [Int64],
        hashtags: [String],
        visibility: String,
        date: String
    ) {
        self.content = content
        self.clothes = clothes
        self.hashtags = hashtags
        self.visibility = visibility
        self.date = date
    }
}
