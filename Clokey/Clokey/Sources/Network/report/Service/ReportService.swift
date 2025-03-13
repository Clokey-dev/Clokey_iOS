//
//  ReportService.swift
//  Clokey
//
//  Created by 황상환 on 3/12/25.
//

import Foundation
import Moya

public final class ReportService: NetworkManager {
    typealias Endpoint = ReportEndpoint
    
    let provider: MoyaProvider<ReportEndpoint>
    
    public init(provider: MoyaProvider<ReportEndpoint>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
            AccessTokenPlugin(),
            TokenRefreshPlugin()
        ]
        self.provider = provider ?? MoyaProvider<ReportEndpoint>(plugins: plugins)
    }
    
    // 계전 신고 정보 조회 GET API
    public func getProfileReportInfo(
        clokeyId: String,
        completion: @escaping (Result<ReportResponseDTO<ProfileAdditionalData>, NetworkError>) -> Void
    ) {
        request(
            target: .getProfileReportInfo(clokeyId: clokeyId),
            decodingType: ReportResponseDTO<ProfileAdditionalData>.self,
            completion: completion
        )
    }
    
    // 댓글 신고 정보 조회 GET API
    public func getCommentReportInfo(
        commentId: String,
        completion: @escaping (Result<ReportResponseDTO<CommentAdditionalData>, NetworkError>) -> Void
    ) {
        request(
            target: .getCommentReportInfo(commentId: commentId),
            decodingType: ReportResponseDTO<CommentAdditionalData>.self,
            completion: completion
        )
    }
    
    // 기록 신고 정보 조회 GET API
    public func getHistoryReportInfo(
        historyId: String,
        completion: @escaping (Result<ReportResponseDTO<HistoryAdditionalData>, NetworkError>) -> Void
    ) {
        request(
            target: .getHistoryReportInfo(historyId: historyId),
            decodingType: ReportResponseDTO<HistoryAdditionalData>.self,
            completion: completion
        )
    }
    
    // 프로필 신고 POST API
    public func reportProfile(
        data: AccountReportRequestDTO,
        completion: @escaping (Result<AccountReportReasonDTO, NetworkError>) -> Void
    ) {
        request(
            target: .reportProfile(data: data),
            decodingType: AccountReportReasonDTO.self,
            completion: completion
        )
    }
    
    // 댓글 신고 POST API
    public func reportComment(
        data: CommentReportRequestDTO,
        completion: @escaping (Result<CommentReportReasonDTO, NetworkError>) -> Void
    ) {
        request(
            target: .reportComment(data: data),
            decodingType: CommentReportReasonDTO.self,
            completion: completion
        )
    }

    // 기록 신고 POST API
    public func reportHistory(
        data: HistoryReportRequestDTO,
        completion: @escaping (Result<HistoryReportReasonDTO, NetworkError>) -> Void
    ) {
        request(
            target: .reportHistory(data: data),
            decodingType: HistoryReportReasonDTO.self,
            completion: completion
        )
    }
}
