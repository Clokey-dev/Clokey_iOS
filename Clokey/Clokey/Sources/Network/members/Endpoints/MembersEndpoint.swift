//
//  MembersEndpoint.swift
//  Clokey
//
//  Created by 황상환 on 1/27/25.
//

import Foundation
import Moya

public enum MembersEndpoint {
    case kakaoLogin(data: KakaoLoginRequestDTO)
    case ReissueToken(data: ReissueTokenRequestDTO)
    case agreeToTerms(userId: Int, data: TermsAgreementRequestDTO)
    case updateProfile(data: ProfileUpdateRequestDTO)
    case checkIdAvailability(id: String)
    case getUserProfile(clokeyId: String)
    case followUser(data: FollowRequestDTO)
    case unfollowUser(data: UnFollowRequestDTO)
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
        case .kakaoLogin:
            return "/login"
        case .ReissueToken:
            return "/reissue-token"
        case .agreeToTerms(let userId, _):
            return "/users/\(userId)/terms"
        case .updateProfile:
            return "/users/profile"
        case .checkIdAvailability:
            return "/users/check"
        case .getUserProfile(let clokeyId):
            return "/users/\(clokeyId)"
        case .followUser:
            return "/users/follow"
        case .unfollowUser:
            return "/users/follow"
        }
    }
    
    // HTTP 메서드
    public var method: Moya.Method {
        switch self {
        case .kakaoLogin, .ReissueToken, .agreeToTerms, .followUser:
            return .post
        case .updateProfile:
            return .patch
        case .checkIdAvailability, .getUserProfile:
            return .get
        case .unfollowUser:
            return .delete
        }
    }
    
    // 요청 데이터(내가 서버로 보내야 하는 데이터)
    public var task: Moya.Task {
        switch self {
        case .kakaoLogin(let data):
            return .requestJSONEncodable(data)
        case .ReissueToken(let data):
            return .requestJSONEncodable(data)
        case .agreeToTerms(_, let data):
            return .requestJSONEncodable(data)
        case .updateProfile(let data):
            return .requestJSONEncodable(data)
        case .checkIdAvailability(let id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        case .getUserProfile(_):
            return .requestPlain
        case .followUser(let data):
            return .requestJSONEncodable(data)
        case .unfollowUser(let data):
            return .requestJSONEncodable(data)
        }
    }
    
    public var headers: [String: String]? {
        return [
            "Content-Type": "application/json"
        ]
    }
}
