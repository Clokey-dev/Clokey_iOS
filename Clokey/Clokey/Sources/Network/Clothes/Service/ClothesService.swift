//
//  ClothesService.swift
//  NetworkTest
//
//  Created by 한금준 on 1/30/25.
//

import Foundation
import Moya
import UIKit

public final class ClothesService : NetworkManager {
    typealias Endpoint = ClothesEndpoint
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<ClothesEndpoint>
    
    public init(provider: MoyaProvider<ClothesEndpoint>? = nil) {
        let session = Session(interceptor: AuthInterceptor())
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = provider ?? MoyaProvider<ClothesEndpoint>(session: session, plugins: plugins)
    }
    
    public func checkEditClothes (
        clothId: Int64,
        completion: @escaping (Result<checkEditClothesResponseDTO, NetworkError>) -> Void
    ){
        request(
            target: .checkEditClothes(clothId: clothId),
            decodingType: checkEditClothesResponseDTO.self,
            completion: completion)
    }
    
    public func checkPopUpClothes (
        clothId: Int64,
        completion: @escaping (Result<checkPopUpClothesResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .checkPopUpClothes(clothId: clothId),
            decodingType: checkPopUpClothesResponseDTO.self,
            completion: completion)
    }
    
    public func getSmartSummationClothes(
        completion: @escaping (Result<SmartSummationResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .smartSummationClothes,
            decodingType: SmartSummationResponseDTO.self,
            completion: completion
        )
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
        imageData: Data,
        data: AddClothesRequestDTO,
        completion: @escaping (Result<AddClothesResponseDTO, NetworkError>) -> Void
    ){
        request(
            target: .addClothes(image: imageData, data: data),
            decodingType: AddClothesResponseDTO.self,
            completion: completion)
    }
    
    public func editClothes (
        clothId: Int64,
        imageData: Data,
        clothUpdateRequest: EditClothesRequestDTO,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ){
        requestStatusCode(
            target: .editClothes(clothId: clothId, imageData: imageData, clothUpdateRequest: clothUpdateRequest),
            completion: completion)
            
    }
    
    public func deleteClothes (
        cloth_id: Int,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ){
        requestStatusCode(
            target: .deleteClothes(cloth_id: cloth_id),
            completion: { result in
                switch result {
                case .success:
                    completion(.success(())) // 성공 처리
                case .failure(let error):
                    completion(.failure(error)) // 실패 처리
                }
            }
        )
    }   

    // 내 옷장 조회 GET API
    public func getClothes(
        clokeyId: String?,  
        categoryId: CLong,
        season: String,
        sort: String,
        page: Int,
        size: Int,
        completion: @escaping (Result<GetClothesByCategoryResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .getClothes(
                clokeyId: clokeyId,
                categoryId: categoryId,
                season: season,
                sort: sort,
                page: page,
                size: size
            ),
            decodingType: GetClothesByCategoryResponseDTO.self,
            completion: completion
        )
    }
    
    // 유저 옷장 검색 GET API
    public func searchClothes(
        keyword: String,
        page: Int,
        size: Int,
        completion: @escaping (Result<ClothSearchResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .searchByNameAndBrand(
                keyword: keyword,
                page: page,
                size: size
            ),
            decodingType: ClothSearchResponseDTO.self,
            completion: completion
        )
    }

}

