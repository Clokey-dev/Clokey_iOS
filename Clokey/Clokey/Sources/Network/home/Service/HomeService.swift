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
    
    
    func fetchOneYearAgoHistories(
        completion: @escaping (Result<OneYearAgoHistoriesResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .getOneYearAgoHistories,
            decodingType: OneYearAgoHistoriesResponseDTO.self,
            completion: completion
        )
    }
    
    func fetchGetIssuesData(
        view: String? = nil,
        section: String? = nil,
        page: Int? = nil,
        completion: @escaping (Result<GetIssuesResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .getIssues(view: view, section: section, page: page),
            decodingType: GetIssuesResponseDTO.self,
            completion: completion
        )
    }
}


