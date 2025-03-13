//
//  ReportRequestDTO.swift
//  Clokey
//
//  Created by 황상환 on 3/12/25.
//

import Foundation

// 각 신고 정보 조회 API는 Request 사용 X

// 댓글 신고하기
public struct CommentReportRequestDTO: Codable {
    public let commentId: Int
    public let commentReportType: String
    public let content: String

    public init(commentId: Int, commentReportType: String, content: String) {
        self.commentId = commentId
        self.commentReportType = commentReportType
        self.content = content
    }
}

public struct AccountReportRequestDTO: Codable {
    public let clokeyId: String
    public let profileReportType: String
    public let content: String

    public init(clokeyId: String, profileReportType: String, content: String) {
        self.clokeyId = clokeyId
        self.profileReportType = profileReportType
        self.content = content
    }
}


public struct HistoryReportRequestDTO: Codable {
    public let historyId: Int
    public let historyReportType: String
    public let content: String

    public init(historyId: Int, historyReportType: String, content: String) {
        self.historyId = historyId
        self.historyReportType = historyReportType
        self.content = content
    }
}

