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
    public let isLiked: Bool
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
