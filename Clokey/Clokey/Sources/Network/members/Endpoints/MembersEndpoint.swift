//
//  MembersEndpoint.swift
//  Clokey
//
//  Created by 황상환 on 1/27/25.
//

import Foundation
import Moya

public enum MembersEndpoint {
    case SocialLogin(data: LoginRequestDTO)
    case ReissueToken(data: ReissueTokenRequestDTO)
    case agreeToTerms(data: AgreementToTermsRequestDTO)
    case getTerms
    case updateProfile(data: ProfileUpdateRequestDTO, imageData1: Data, imageData2: Data)
    case checkIdAvailability(checkId: String)
    case getUserProfile(clokey_id: String?)
    //    case getUser
    case followUser(data: FollowRequestDTO)
    case unfollowUser(data: UnFollowRequestDTO)
    case getAgreedTerms
    case optionalTermAgree(data: OptionalTermAgreeRequestDTO)
    case getFollowPeople(clokeyId: String, page: Int, isFollowing: Bool)
    // 추가적인 API는 여기 케이스로 정의
}

extension MembersEndpoint: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("잘못된 URL입니다.")
        }
        return url
    }
    
    // 엔드 포인트 주소
    public var path: String {
        switch self {
        case .SocialLogin:
            return "/login"
        case .ReissueToken:
            return "/reissue-token"
        case .agreeToTerms:
            return "/users/terms"
        case .getTerms:
            return "/users/terms"
        case .updateProfile:
            return "/users/profile"
        case .checkIdAvailability(let clokeyId):
            return "/users/\(clokeyId)/check"
        case .getUserProfile:
            return "/users"
            //        case .getUser:
            //            return "/users"
        case .followUser:
            return "/users/follow"
        case .unfollowUser:
            return "/users/follow"
        case .getAgreedTerms:
            return "/users/terms/optional"
        case .optionalTermAgree:
            return "users/terms/optional"
        case .getFollowPeople(let clokeyId, _, _):
            return "/users/\(clokeyId)/follow"
        }
    }
    
    // HTTP 메서드
    public var method: Moya.Method {
        switch self {
        case .SocialLogin, .ReissueToken, .agreeToTerms, .followUser, .optionalTermAgree:
            return .post
        case .updateProfile:
            return .patch
        case .checkIdAvailability, .getUserProfile,/*.getUser,*/ .getTerms, .getAgreedTerms, .getFollowPeople:
            return .get
        case .unfollowUser:
            return .delete
        }
    }
    
    // 요청 데이터(내가 서버로 보내야 하는 데이터)
    public var task: Moya.Task {
        switch self {
        case .SocialLogin(let data):
            return .requestJSONEncodable(data)
        case .ReissueToken(let data):
            return .requestJSONEncodable(data)
        case .agreeToTerms(let data):
            return .requestJSONEncodable(data)
        case .getTerms:
            return .requestPlain
        case .updateProfile(let data, let imageData1, let imageData2):
            var multipartData = [MultipartFormData]()
            
            // ✅ JSON 데이터 추가 (profileRequest)
            do {
                let jsonData = try JSONEncoder().encode(data)
                let jsonPart = MultipartFormData(provider: .data(jsonData), name: "profileRequest", mimeType: "application/json")
                multipartData.append(jsonPart)
                print("✅ JSON 데이터 추가됨: \(String(data: jsonData, encoding: .utf8) ?? "변환 실패")")
            } catch {
                print("🚨 JSON 인코딩 오류: \(error.localizedDescription)")
            }
            
            // ✅ 첫 번째 이미지 파일 추가 (프로필 사진)
            let imagePart1 = MultipartFormData(provider: .data(imageData1), name: "profileImage", fileName: "profile.jpg", mimeType: "image/jpeg")
            multipartData.append(imagePart1)
            
            // ✅ 두 번째 이미지 파일 추가 (배경 사진)
            let imagePart2 = MultipartFormData(provider: .data(imageData2), name: "profileBackImage", fileName: "background.jpg", mimeType: "image/jpeg")
            multipartData.append(imagePart2)
            
            // 🔹 추가된 데이터 확인
            for item in multipartData {
                switch item.provider {
                case .data(let data):
                    print("📂 Multipart 데이터 추가됨: \(item.name) (\(data.count) bytes)")
                default:
                    print("📂 Multipart 데이터 추가됨: \(item.name)")
                }
            }
            
            return .uploadMultipart(multipartData)
        case .checkIdAvailability(_):
            return .requestPlain
        case .getUserProfile(let clokey_id):
            var parameters: [String: Any] = [:]
            if let clokey_id = clokey_id, !clokey_id.isEmpty {
                parameters["clokey_id"] = clokey_id
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            //        case .getUser:
            //            return .requestPlain
        case .followUser(let data):
            return .requestJSONEncodable(data)
        case .unfollowUser(let data):
            return .requestJSONEncodable(data)
        case .getAgreedTerms:
            return .requestPlain
        case .optionalTermAgree(let data):
            return .requestJSONEncodable(data)
        case .getFollowPeople(_, let page, let isFollowing):
            var parameters: [String: Any] = [
                "page": page,
                "isFollowing": isFollowing
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String: String]? {
        switch self {
        case .updateProfile:
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
