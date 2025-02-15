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
    
    func fetchGetDetailIssuesData(
        section: String? = nil,
        page: Int,
        completion: @escaping (Result<GetDetailIssuesResponse, NetworkError>) -> Void
    ) {
        request(
            target: .getDetailIssues(section: section, page: page),
            decodingType: Data.self // Data로 먼저 받아서 후에 수동 디코딩
        ) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let decodedResponse: GetDetailIssuesResponse
                    
                    if section == "closet" {
                        let closetData = try decoder.decode(GetDetailIssuesClosetResponseDTO.self, from: data)
                        decodedResponse = .closet(closetData)
                    } else if section == "calendar" {
                        let calendarData = try decoder.decode(GetDetailIssuesCalendarResponseDTO.self, from: data)
                        decodedResponse = .calendar(calendarData)
                    } else {
                        throw NSError(domain: "Invalid section", code: -1, userInfo: nil)
                    }
                    
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(.decodingError(underlyingError: error as? DecodingError ?? DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unknown decoding error")))))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


