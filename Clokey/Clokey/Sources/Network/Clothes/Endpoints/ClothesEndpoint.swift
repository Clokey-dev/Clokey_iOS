//
//  ClothesEndpoint.swift
//  NetworkTest
//
//  Created by 한금준 on 1/29/25.
//

import Foundation
import Moya

public enum ClothesEndpoint {
    case inquiryClothesDetail(cloth_id: Int)
    case checkEditClothes(cloth_id: Int)
    case checkPopUpClothes(clothId: Int)
    case getCategoryClothes(category: String, season: String, sort: String, page: Int) // 쿼리 매개변수 추가
    case addClothes(image: Data, data: AddClothesRequestDTO) // category_id 추가
    case editClothes(cloth_id: Int, category_id: Int, data: EditClothesRequestDTO)
    case deleteClothes(cloth_id: Int)
    case getClothes(clokeyId: String?, categoryId: CLong, season: String, sort: String, page: Int, size: Int)
    case searchByNameAndBrand(keyword: String, page: Int, size: Int)

}

extension ClothesEndpoint: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    // 엔드 포인트 주소
    public var path: String {
        switch self {
        case .inquiryClothesDetail(let cloth_id):
            return "/clothes/\(cloth_id)"
        case .checkEditClothes(cloth_id: let cloth_id):
            return "/clothes/\(cloth_id)/edit-view"
        case .checkPopUpClothes(let clothId):
            return "/clothes/\(clothId)/popup-view"
        case .getCategoryClothes:
            return "/clothes"
        case .addClothes:
            return "/clothes"
        case .editClothes(cloth_id: let cloth_id):
            return "/clothes/\(cloth_id)/edit"
        case .deleteClothes(let cloth_id):
            return "/clothes/\(cloth_id)"
        case .getClothes(let clokeyId, _, _, _, _, _):
            return "/clothes/closet-view"
        case .searchByNameAndBrand:
            return "/clothes/search/name-and-brand"
        }
    }
    
    // HTTP 메서드
    public var method: Moya.Method {
        switch self {
        case .addClothes:
            return .post
        case .editClothes:
            return .patch
        case .deleteClothes:
            return .delete
        case .getClothes,
             .inquiryClothesDetail,
             .checkEditClothes,
             .checkPopUpClothes,
             .getCategoryClothes,
             .searchByNameAndBrand:
            return .get
        }
    }
    
    // 요청 데이터(내가 서버로 보내야 하는 데이터)
    public var task: Moya.Task {
        switch self {
        case .inquiryClothesDetail(let cloth_id):
            return .requestPlain
        case .checkEditClothes(let cloth_id):
            return .requestPlain
        case .checkPopUpClothes(let clothId):
            return .requestPlain
        case .getCategoryClothes(let category, let season, let sort, let page):
            // Query parameters를 설정
            return .requestParameters(
                parameters: [
                    "category": category,
                    "season": season,
                    "sort": sort,
                    "page": page
                ],
                encoding: URLEncoding.queryString // 쿼리 스트링 방식
            )
        case .addClothes(let image, let data):
            var multipartData = [MultipartFormData]()

            do {
                let jsonData = try JSONEncoder().encode(data)
                
                // ✅ JSON 확인 로그 추가
                let jsonString = String(data: jsonData, encoding: .utf8) ?? "JSON 변환 실패"
                print("✅ JSON 데이터: \(jsonString)")

                let jsonPart = MultipartFormData(provider: .data(jsonData), name: "clothCreateRequest", mimeType: "application/json")
                multipartData.append(jsonPart)
            } catch {
                print("🚨 JSON 인코딩 실패: \(error.localizedDescription)")
                return .requestPlain
            }

            // ✅ 이미지 파일 추가 (name을 "imageFile"로 변경)
            let fileName = "clothes_image.jpg"
            let imagePart = MultipartFormData(provider: .data(image), name: "imageFile", fileName: fileName, mimeType: "image/jpeg")

            // ✅ 이미지 크기 로그 출력
            print("✅ 이미지 크기: \(image.count) bytes")

            multipartData.append(imagePart)

            return .uploadMultipart(multipartData)
            

                
            
        case .editClothes(let cloth_id, let category_id, let data):
            return .requestCompositeParameters(
                bodyParameters: try! data.asDictionary(),
                bodyEncoding: JSONEncoding.default,
                urlParameters: ["category_id": category_id]
            )
        case .deleteClothes(let cloth_id):
            return .requestPlain
        case let .getClothes(clokeyId, categoryId, season, sort, page, size):
            var parameters: [String: Any] = [
                "categoryId": categoryId,
                "season": season,
                "sort": sort,
                "page": page,
                "size": size
            ]
            
            // clokeyId가 있을 때만 파라미터에 추가
            if let clokeyId = clokeyId {
                parameters["clokeyId"] = clokeyId
            }
            
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )
        case let .searchByNameAndBrand(keyword, page, size):
            return .requestParameters(
                parameters: [
                    "keyword": keyword,
                    "page": page,
                    "size": size
                ],
                encoding: URLEncoding.queryString
            )
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .addClothes, .editClothes:
            return [
                "Content-Type": "multipart/form-data"
            ]
        default:
            return [
                "Content-Type": "application/json"
            ]
        }
    }
    
}
