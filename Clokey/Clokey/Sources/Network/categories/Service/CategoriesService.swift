//
//  CategoriesService.swift
//  Clokey
//
//  Created by 한금준 on 2/12/25.
//

import Foundation
import Moya
import UIKit

public final class CategoriesService : NetworkManager {
    typealias Endpoint = CategoriesEndPoint
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<CategoriesEndPoint>
    
    public init(provider: MoyaProvider<CategoriesEndPoint>? = nil) {
        // 플러그인 추가
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)), // 로그 플러그인
            AccessTokenPlugin(),
            TokenRefreshPlugin()
        ]
        
        // provider 초기화
        self.provider = provider ?? MoyaProvider<CategoriesEndPoint>(plugins: plugins)
    }
    
    public func getRecommendCategory(
        name: String,
        completion: @escaping (Result<CategoriesResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .getRecommendCategory(name: name),
            decodingType: CategoriesResponseDTO.self,
            completion: completion
        )
    }
}


