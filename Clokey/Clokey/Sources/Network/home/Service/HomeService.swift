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
    
    func recommendClothes(
        nowTemp: Int32,
        minTemp: Int32,
        maxTemp: Int32,
        completion: @escaping (Result<RecommendClothesResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .recommendClothes(nowTemp: nowTemp, minTemp: minTemp, maxTemp: maxTemp),
            decodingType: RecommendClothesResponseDTO.self,
            completion: completion
        )
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
    
    func fetchGetDetailIssuesData<T: Decodable>(
        section: String,
        page: Int,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        let decodingType: T.Type = section == "closet" ? GetDetailIssuesClosetResponseDTO.self as! T.Type :
                                   section == "calendar" ? GetDetailIssuesCalendarResponseDTO.self as! T.Type : T.self

        request(target: .getDetailIssues(section: section, page: page), decodingType: decodingType, completion: completion)
    }
}


