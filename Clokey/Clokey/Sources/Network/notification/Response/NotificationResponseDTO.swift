//
//  NotificationResponseDTO.swift
//  Clokey
//
//  Created by 소민준 on 2/15/25.
//

import Foundation

// ENUM: 이동 타입
public enum RedirectType: String, Codable {
    case historyRedirect = "HISTORY_REDIRECT"
    case memberRedirect = "MEMBER_REDIRECT"
}

// ENUM: redirectInfo를 저장하는 타입 (Int64 or String)
public enum RedirectInfo: Codable {
    case historyId(Int64)    // 히스토리 ID (숫자)
    case clokeyId(String)    // 멤버 닉네임 (문자열)
    
    // 디코딩 (JSON -> RedirectInfo)
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        
        // Int64 변환이 가능한지 확인 (HISTORY_REDIRECT인 경우)
        if let intValue = Int64(stringValue) {
            self = .historyId(intValue)
        } else {
            self = .clokeyId(stringValue) //  변환 불가능하면 그냥 String으로 저장
        }
    }
    
    
    // 인코딩 (RedirectInfo -> JSON)
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .historyId(let id):
            try container.encode(String(id)) // Int64를 다시 String으로 변환
        case .clokeyId(let clokeyId):
            try container.encode(clokeyId)
        }
    }
}
 //알림 목록조회
    public struct NotificationResponseDTO: Codable {
        public let NotificationResults: [NotificationResultsResponseDTO]
        public let totalPage: Int64
        public let totalElements: Int64
        public let isFirst: Bool
        public let isLast: Bool
    }
    
    
    // 개별 알림 DTO
    public struct NotificationResultsResponseDTO: Codable {
        public let notificationId: Int64
        public let content: String
        public let redirectType: RedirectType   // 항상 String으로 옴
        public let redirectInfo: RedirectInfo   // String -> Int64 변환 처리
        public let notificationImageUrl: String?
        public let createdAt: String
        public let isRead: Bool
    }
    
    
    
    //안읽음 알림 존재 유무 DTO
    public struct NotificationUnreadResponseDTO: Codable {
        public let unReadNotificationExist: Bool
    }
    //좋아요 알림
    public struct NotificationLoveResponseDTO: Codable {
        public let content: String
        public let memberProfileUrl: String
        public let historyId: Int64
    }
    
    //팔로우 알림
    public struct NotificationFollowResponseDTO: Codable {
        public let content: String
        public let memberProfileUrl: String
        public let historyId: Int64
    }
    
    //히스토리 댓글 알림
    public struct NotificationHistoryCommentResponseDTO: Codable{
        public let content: String
        public let memberProfileUrl: String
        public let clokeyId: String
    }
    //댓글 답장 알림
    public struct NotificationReplyResponseDTO: Codable {
        public let content: String
        public let memberProfileUrl: String
        public let historyId: Int64
    }
    
   
    


