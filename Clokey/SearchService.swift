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
            AccessTokenPlugin()
        ]
        self.provider = provider ?? MoyaProvider<SearchEndpoint>(plugins: plugins)
    }
    //사용자 검색 API
    public func searchMemeber(
        data: String,
        page: Int,
        size: Int,
        completion: @escaping (Result< SearchMemberResponseDTO, NetworkError>) -> Void
    ){
        request(target: .searchMember(data: data, page: page, size: size),
                decodingType: SearchMemberResponseDTO.self,
                completion: completion
        )
    }
    
    //기록, 해시태그 검색 API
    public func searchHistory(
        data: String,
        page: Int,
        size: Int,
        completion: @escaping (Result< SearchHistoryCategoryResponseDTO, NetworkError>) -> Void
        
    ){
        request(target: .searchHistory(data: data, page: page, size: size),
                decodingType: SearchHistoryCategoryResponseDTO.self,
                completion: completion
        )
        
    }
    //옷 검색 API
    public func searchClothes(
        data: String,
        page: Int,
        size: Int,
        completion: @escaping (Result <SearchClothesResponseDTO, NetworkError>) -> Void
        
    ){
        request(target: .searchClothes(keyword: data, page: page, size: size),
                decodingType: SearchClothesResponseDTO.self,
                completion: completion
        )
    }
}
