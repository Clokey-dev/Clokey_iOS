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
        // 플러그인 추가
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)), // 로그 플러그인
            AccessTokenPlugin(),
            TokenRefreshPlugin()
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
        clothId: Int,
        completion: @escaping (Result<checkPopUpClothesResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .checkPopUpClothes(clothId: clothId),
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
    
    public func addClothes(
        data: AddClothesRequestDTO, image: UIImage, completion: @escaping (Result<Moya.Response, MoyaError>) -> Void
    ){
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("🚨 이미지 변환 실패")
                return
            }
            
        provider.request(.addClothes(data: data, imageData: imageData)) { result in
                switch result {
                case .success(let response):
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        print("🚀 서버 응답 JSON: \(jsonString)")
                    }
                    completion(.success(response))
                case .failure(let error):
                    print("🚨 요청 실패: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
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

