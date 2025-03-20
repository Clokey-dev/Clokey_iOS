//
//  ReportResponseDTO.swift
//  Clokey
//
//  Created by 황상환 on 3/12/25.
//

import Foundation

// 신고 정보 조회 통합
public struct ReportResponseDTO<T: Codable>: Codable {
    public let clokeyId: String
    public let nickName: String
    public let userProfile: String
    public let reportTypeResults: [ReportTypeDTO]
    public var additionalData: T?  // 신고 타입별 추가 데이터
    public var commentContent: String?  // 댓글 내용 직접 추가
    public var historyContent: String?  // 히스토리 내용 직접 추가
    
    // CodingKeys를 통해 API 응답의 필드명과 매핑
    private enum CodingKeys: String, CodingKey {
        case clokeyId, nickName, userProfile, reportTypeResults
        case commentContent, historyContent
    }
    
    // 디코딩 초기화
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        clokeyId = try container.decode(String.self, forKey: .clokeyId)
        nickName = try container.decode(String.self, forKey: .nickName)
        userProfile = try container.decode(String.self, forKey: .userProfile)
        reportTypeResults = try container.decode([ReportTypeDTO].self, forKey: .reportTypeResults)
        
        // 댓글/히스토리 내용 옵셔널로 디코딩
        commentContent = try container.decodeIfPresent(String.self, forKey: .commentContent)
        historyContent = try container.decodeIfPresent(String.self, forKey: .historyContent)
        
        // additionalData는 제네릭 타입에 따라 설정
        if T.self == CommentAdditionalData.self && commentContent != nil {
            additionalData = CommentAdditionalData(commentContent: commentContent!) as? T
        } else if T.self == HistoryAdditionalData.self && historyContent != nil {
            additionalData = HistoryAdditionalData(historyContent: historyContent!) as? T
        } else {
            additionalData = nil
        }
    }
    
    // 인코딩 구현 (Encodable 프로토콜 요구사항)
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(clokeyId, forKey: .clokeyId)
        try container.encode(nickName, forKey: .nickName)
        try container.encode(userProfile, forKey: .userProfile)
        try container.encode(reportTypeResults, forKey: .reportTypeResults)
        
        // 옵셔널 필드는 존재할 때만 인코딩
        try container.encodeIfPresent(commentContent, forKey: .commentContent)
        try container.encodeIfPresent(historyContent, forKey: .historyContent)
    }
}

// 신고 타입별 추가 데이터 구조체
public struct ProfileAdditionalData: Codable {
    // 추가 데이터 없음.
}

public struct CommentAdditionalData: Codable {
    public let commentContent: String
}

public struct HistoryAdditionalData: Codable {
    public let historyContent: String
}

// ReportTypeDTO
public struct ReportTypeDTO: Codable {
    public let reportType: String
    public let reportContents: [String]
    public let title: String
}

// 계정 신고하기
public struct AccountReportReasonDTO: Codable {
    public let profileReportId: Int
}

// 댓글 신고하기
public struct CommentReportReasonDTO: Codable {
    public let commentReportId: Int
}

// 기록 신고하기
public struct HistoryReportReasonDTO: Codable {
    public let historyReportId: Int
}
