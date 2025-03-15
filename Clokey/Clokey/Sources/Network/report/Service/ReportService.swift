//
//  ReportService.swift
//  Clokey
//
//  Created by 한금준 on 3/16/25.
//

import Foundation
import Moya

public final class ReportService : NetworkManager {
    typealias Endpoint = ReportEndpoint
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<ReportEndpoint>
    
    public init(provider: MoyaProvider<ReportEndpoint>? = nil) {
        // 플러그인 추가
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)), // 로그 플러그인
            AccessTokenPlugin()
        ]
        
        // provider 초기화
        self.provider = provider ?? MoyaProvider<ReportEndpoint>(plugins: plugins)
    }
    
    func getProfileReportInformation(
        clokeyId: String,
        completion: @escaping (Result<getProfileReportInformationResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .getProfileReportInformation(clokeyId: clokeyId),
            decodingType: getProfileReportInformationResponseDTO.self,
            completion: completion
        )
    }
    
    
   
}

