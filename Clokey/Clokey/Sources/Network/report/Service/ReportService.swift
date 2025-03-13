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
    
    // 신고 정보 조회 GET API
    public func getReportInfo(
        clokeyId: String,
        completion: @escaping (Result<ReportResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .getReportInfo(clokeyId: clokeyId),
            decodingType: ReportResponseDTO.self,
            completion: completion
        )
    }
    
    // 프로필 신고 POST API
    public func reportProfile(
        data: ReportRequestDTO,
        completion: @escaping (Result<AccountReportReasonDTO, NetworkError>) -> Void
    ) {
        request(
            target: .reportProfile(data: data),
            decodingType: AccountReportReasonDTO.self,
            completion: completion
        )
    }
}
