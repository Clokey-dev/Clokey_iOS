//
//  HistoryService.swift
//  Clokey
//
//  Created by 황상환 on 1/28/25.
//

import Foundation
import Moya

public final class HistoryService: NetworkManager {
    typealias Endpoint = HistoryEndpoint
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<HistoryEndpoint>
    
    public init(provider: MoyaProvider<HistoryEndpoint>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
            AccessTokenPlugin()
        ]
        self.provider = provider ?? MoyaProvider<HistoryEndpoint>(plugins: plugins)
    }
    
    // MARK: - API funcs
    
    
    // 아이디 중복 확인 GET API
    public func historyMonth(
        clokeyId: String? = nil,
        month: String,
        completion: @escaping (Result<HistoryMonthResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .historyMonth(clokeyId: clokeyId, month: month),
            decodingType: HistoryMonthResponseDTO.self,
            completion: completion
        )
    }


}
