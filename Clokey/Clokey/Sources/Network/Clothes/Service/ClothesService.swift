//
//  ClothesService.swift
//  NetworkTest
//
//  Created by 한금준 on 1/30/25.
//

import Foundation
import Moya

public final class ClothesService : NetworkManager {
    typealias Endpoint = ClothesEndpoint
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<ClothesEndpoint>
    
    public init(provider: MoyaProvider<ClothesEndpoint>? = nil) {
        // 플러그인 추가
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)) // 로그 플러그인
        ]
        
        // provider 초기화
        self.provider = provider ?? MoyaProvider<ClothesEndpoint>(plugins: plugins)
    }
    
    public func inquiryClothesDetail (
        cloth_id: Int,
        completion: @escaping (Result<InquiryClothesDetailResponseDTO, NetworkError>) -> Void
    ){
        request(
            target: .inquiryClothesDetail(cloth_id: cloth_id),
            decodingType: InquiryClothesDetailResponseDTO.self,
            completion: completion
        )
    }
    
    public func checkEditClothes (
        cloth_id: Int,
        completion: @escaping (Result<checkEditClothesResponseDTO, NetworkError>) -> Void
    ){
        request(
            target: .checkEditClothes(cloth_id: cloth_id),
            decodingType: checkEditClothesResponseDTO.self,
            completion: completion)
    }
    
    public func checkPopUpClothes (
        cloth_id: Int,
        completion: @escaping (Result<checkPopUpClothesResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .checkPopUpClothes(cloth_id: cloth_id),
            decodingType: checkPopUpClothesResponseDTO.self,
            completion: completion)
    }
    
    public func getCategoryClothes (
        category: String, season: String, sort: String, page: Int,
        completion: @escaping (Result<getCategoryClothesResponseDTO, NetworkError>) -> Void
    ){
        request(
            target: .getCategoryClothes(category: category, season: season, sort: sort, page: page),
            decodingType: getCategoryClothesResponseDTO.self,
            completion: completion)
    }
    
    public func addClothes (
        category_id: Int,
        data: AddClothesRequestDTO,
        completion: @escaping (Result<addClothesResponseDTO, NetworkError>) -> Void
    ){
        request(
            target: .addClothes(category_id: category_id, data: data),
            decodingType: addClothesResponseDTO.self,
            completion: completion)
    }
    
    public func editClothes (
        cloth_id: Int, category_id: Int,
        data: EditClothesRequestDTO,
        completion: @escaping (Result<Bool, NetworkError>) -> Void
    ){
        request(
            target: .editClothes(cloth_id: cloth_id, category_id: category_id, data: data),
            decodingType: Bool.self,
            completion: completion)
    }
    
    public func deleteClothes (
        cloth_id: Int,
        completion: @escaping (Result<Bool, NetworkError>) -> Void
    ){
        request(
            target: .deleteClothes(cloth_id: cloth_id),
            decodingType: Bool.self,
            completion: completion)
    }
}


