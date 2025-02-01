//
//  MembersService.swift
//  Clokey
//
//  Created by 황상환 on 1/27/25.
//

import Foundation
import Moya

public final class MembersService: NetworkManager {
    typealias Endpoint = MembersEndpoint
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<MembersEndpoint>
    
    public init(provider: MoyaProvider<MembersEndpoint>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
            AccessTokenPlugin()
        ]
        self.provider = provider ?? MoyaProvider<MembersEndpoint>(plugins: plugins)
    }
    
    // MARK: - API funcs
    
    // 카카오 로그인 POST API
    public func kaKaoLogin(
        data: KakaoLoginRequestDTO,
        completion: @escaping (Result<KakaoLoginResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .kakaoLogin(data: data),
            decodingType: KakaoLoginResponseDTO.self,
            completion: completion
        )
    }
    
    // 토큰 재발급 POST API
    public func reissueToken(
        data: ReissueTokenRequestDTO,
        completion: @escaping (Result<KakaoLoginResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .ReissueToken(data: data),
            decodingType: KakaoLoginResponseDTO.self,
            completion: completion)
    }
    
    /// 약관 동의 POST API
    public func agreeToTerms(
        userId: Int,
        data: TermsAgreementRequestDTO,
        completion: @escaping (Result<TermsAgreementResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .agreeToTerms(userId: userId, data: data),
            decodingType: TermsAgreementResponseDTO.self,
            completion: completion
        )
    }
    
    /// 프로필 수정 PATCH API
    public func updateProfile(
        data: ProfileUpdateRequestDTO,
        completion: @escaping (Result<ProfileUpdateResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .updateProfile(data: data),
            decodingType: ProfileUpdateResponseDTO.self,
            completion: completion
        )
    }
    
    /// 아이디 중복 확인 GET API
    public func checkIdAvailability (
        id: String,
        completion: @escaping (Result<Bool, NetworkError>) -> Void
    ) {
        request(
            target: .checkIdAvailability(id: id),
            decodingType: Bool.self,
            completion: completion
        )
    }
    
    /// 회원 조회 GET API
    public func getUserProfile (
        clokeyId: String,
        completion: @escaping (Result<MembersInfoResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .getUserProfile(clokeyId: clokeyId),
            decodingType: MembersInfoResponseDTO.self,
            completion: completion
        )
    }
    
    /// 팔로우 POST API
    public func followUser (
        data: FollowRequestDTO,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        request(
            target: .followUser(data: data),
            decodingType: EmptyResponse.self,
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
    
    /// 언팔로우 DELETE API
    public func unfollowUser(
        data: UnFollowRequestDTO,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        request(
            target: .unfollowUser(data: data),
            decodingType: EmptyResponse.self,
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

}
