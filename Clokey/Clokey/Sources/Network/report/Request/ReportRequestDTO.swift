//
//  ReportRequestDTO.swift
//  Clokey
//
//  Created by 황상환 on 3/12/25.
//

import Foundation

// 각 신고 정보 조회 API는 Request 사용 X

// 계정 신고하기
public struct ReportRequestDTO: Codable {
    public let clokeyId: String
    public let profileReportType: String
    public let content: String

    public init(clokeyId: String, profileReportType: String, content: String) {
        self.clokeyId = clokeyId
        self.profileReportType = profileReportType
        self.content = content
    }
}


