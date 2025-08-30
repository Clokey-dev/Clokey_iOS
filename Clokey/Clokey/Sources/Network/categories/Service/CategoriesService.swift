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
        let session = Session(interceptor: AuthInterceptor())
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<CategoriesEndPoint>(session: session, plugins: plugins)
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


