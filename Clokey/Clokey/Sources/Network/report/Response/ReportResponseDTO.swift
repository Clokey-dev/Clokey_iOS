//
//  ReportResponseDTO.swift
//  Clokey
//
//  Created by 황상환 on 3/12/25.
//

import Foundation

// 계정 신고 정보 조회
public struct ReportResponseDTO: Codable {
    public let clokeyId: String
    public let nickName: String
    public let userProfile: String
    public let reportTypeResults: [ReportTypeDTO]
}

public struct ReportTypeDTO: Codable {
    public let reportType: String
    public let reportContents: [String]
    public let title: String
}

// 계정 신고하기
public struct AccountReportReasonDTO: Codable {
    public let profileReportId: Int
}
