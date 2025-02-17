//
//  SearchService.swift
//  Clokey
//
//  Created by 소민준 on 2/13/25.
//

import Foundation
import Moya

public final class SearchService : NetworkManager {
    typealias Endpoint = SearchEndpoint
    let provider: MoyaProvider<SearchEndpoint>
    
    public init(provider: MoyaProvider<SearchEndpoint>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
            AccessTokenPlugin(),
            TokenRefreshPlugin()
        ]
        self.provider = provider ?? MoyaProvider<SearchEndpoint>(plugins: plugins)
    }
    //사용자 검색 API
    public func searchMember(
        by: String,
        keyword: String,
        page: Int,
        size: Int,
        completion: @escaping (Result< SearchMemberResponseDTO, NetworkError>) -> Void
    ){
        request(target: .searchMember(by: by, keyword: keyword, page: page, size: size),
                decodingType: SearchMemberResponseDTO.self,
                completion: completion
        )
    }
    
    //기록, 해시태그 검색 API
    public func searchHistory(
        by: String,
        keyword: String,
        page: Int,
        size: Int,
        completion: @escaping (Result< SearchHistoryCategoryResponseDTO, NetworkError>) -> Void
        
    ){
        request(target: .searchHistory(by: by, keyword: keyword, page: page, size: size),
                decodingType: SearchHistoryCategoryResponseDTO.self,
                completion: completion
        )
        
    }
    //옷 검색 API
    public func searchClothes(
        by: String,
        keyword: String,
        page: Int,
        size: Int,
        completion: @escaping (Result <SearchClothesResponseDTO, NetworkError>) -> Void
        
    ){
        request(target: .searchClothes(by: by, keyword: keyword, page: page, size: size),
                decodingType: SearchClothesResponseDTO.self,
                completion: completion
        )
    }
}
