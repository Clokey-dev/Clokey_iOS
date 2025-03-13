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
    public let additionalData: T?  // 신고 타입별 추가 데이터
    
    // CodingKeys를 통해 API 응답의 필드명과 매핑
    private enum CodingKeys: String, CodingKey {
        case clokeyId, nickName, userProfile, reportTypeResults
        // additionalData는 직접 매핑하지 않고 init에서 처리
    }
    
    // 디코딩 초기화
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        clokeyId = try container.decode(String.self, forKey: .clokeyId)
        nickName = try container.decode(String.self, forKey: .nickName)
        userProfile = try container.decode(String.self, forKey: .userProfile)
        reportTypeResults = try container.decode([ReportTypeDTO].self, forKey: .reportTypeResults)
        
        additionalData = nil  // 기본값
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
