//
//  HomeService.swift
//  Clokey
//
//  Created by 한금준 on 2/2/25.
//

import Foundation
import Moya

public final class HomeService : NetworkManager {
    typealias Endpoint = HomeEndPoint
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<HomeEndPoint>
    
    public init(provider: MoyaProvider<HomeEndPoint>? = nil) {
        // 플러그인 추가
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)), // 로그 플러그인
            AccessTokenPlugin()
        ]
        
        // provider 초기화
        self.provider = provider ?? MoyaProvider<HomeEndPoint>(plugins: plugins)
    }
    
    public func getOneYearAgoHistories(
        completion: @escaping (Result<HistoryResult, NetworkError>) -> Void
    ) {
        request(
            target: .getOneYearAgoHistories,
            decodingType: OneYearAgoHistoriesResponseDTO.self
        ) { result in
            switch result {
            case .success(let responseDTO):
                if responseDTO.isSuccess, let result = responseDTO.result {
                    completion(.success(result))
                } else {
                    let errorMessage = responseDTO.message
                    completion(.failure(NetworkError.networkError(message: errorMessage)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


