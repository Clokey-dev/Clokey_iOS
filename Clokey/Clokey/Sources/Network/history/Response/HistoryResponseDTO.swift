//
//  HistoryResponseDTO.swift
//  Clokey
//
//  Created by 황상환 on 1/28/25.
//

import Foundation

//// 월별 기록 조회
public struct HistoryMonthResponseDTO: Codable {
    public let memberId: Int64
    public let nickName: String
    public let histories: [HistoryDTO]
}

public struct HistoryDTO: Codable {
    public let historyId: Int
    public let date: String
    public let imageUrl: String
}

// 날짜 세부 페이지 - 일별
public struct HistoryDetailResponseDTO: Codable {
    public let memberId: Int64
    public let memberImageUrl: String
    public let historyId: Int64
    public let nickName: String
    public let clokeyId: String
    public let contents: String
    public let imageUrl: [String]
    public let hashtags: [String]
    public let visibility: Bool
    public let likeCount: Int
    public let commentCount: Int
    public let liked: Bool
    public let date: String
    public let cloths: [ClothDTO]
}

public struct ClothDTO: Codable {
    public let clothId: Int
    public let clothImageUrl: String
    public let clothName: String
}

// 좋아요
public struct HistoryLikeResponseDTO: Codable {
    public let historyId: Int64
    public let liked: Bool
    public let likeCount: Int64
}

// 댓글 조회
public struct HistoryCommentsResponseDTO: Codable {
    public let comments: [CommentDTO]
    public let totalPage: Int
    public let totalElements: Int
    public let isFirst: Bool
    public let isLast: Bool
}

public struct CommentDTO: Codable {
    public let commentId: Int
    public let nickName: String
    public let clokeyId: String
    public let userImageUrl: String
    public let content: String
    public let replyResults: [ReplyDTO]
}

public struct ReplyDTO: Codable {
    public let commentId: Int
    public let nickName: String
    public let clokeyId: String
    public let userImageUrl: String
    public let content: String
}

// 댓글 작성
public struct HistoryCommentWriteResponseDTO: Codable {
    public let commentId: Int64
}

// 좋아요한 사람
public struct HistoryLikeListResponseDTO: Codable {
    public let likedUsers: [LikeDTO]
    
    public struct LikeDTO: Codable {
        public let memberId: Int64
        public let clokeyId: String
        public let nickname: String
        public let imageUrl: String
        public let followStatus: Bool
        public let me: Bool
    }
}

// 세부 기록 추가
public struct HistoryCreateResponseDTO: Codable {
    public let historyId: Int64
}

public struct LikedHistoriesResponseDTO: Codable {
    public let historyPreviews: [HistoryPreviewDTO]
    public let totalPage: Int
    public let totalElements: Int
    public let isFirst: Bool
    public let isLast: Bool
    
    public struct HistoryPreviewDTO: Codable {
        public let id: Int
        public let imageUrl: String
        public let isMine: Bool
        
        enum CodingKeys: String, CodingKey {
            case id
            case imageUrl
            case isMine
        }
    }
    
}

// 내가 남긴 댓글
public struct CommentHistoryResponse: Codable {
    let histories: [HistoryModel]
    let totalPage: Int
    let totalElements: Int
    let isFirst: Bool
    let isLast: Bool
}

public struct HistoryModel: Codable {
    let comments: [CommentModel]
    let historyId: Int
    let nickname: String
    let imageUrl: String
    let date: String
}

public struct CommentModel: Codable {
    let content: String
}
