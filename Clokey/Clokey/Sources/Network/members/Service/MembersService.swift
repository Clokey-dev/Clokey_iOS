//
//  MembersService.swift
//  Clokey
//
//  Created by 황상환 on 1/27/25.
//

import Foundation
import Moya
import UIKit

public final class MembersService: NetworkManager {
    typealias Endpoint = MembersEndpoint
    public typealias GetTermsResponseDTOList = [GetTermsResponseDTO]
    
    // MARK: - Provider 설정
    let provider: MoyaProvider<MembersEndpoint>
    
    public init(provider: MoyaProvider<MembersEndpoint>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
            AccessTokenPlugin(),
            TokenRefreshPlugin()
        ]
        self.provider = provider ?? MoyaProvider<MembersEndpoint>(plugins: plugins)
    }
    
    // MARK: - API funcs
    
    // 소셜 로그인 POST API
    public func SocialLogin(
        data: LoginRequestDTO,
        completion: @escaping (Result<LoginResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .SocialLogin(data: data),
            decodingType: LoginResponseDTO.self,
            completion: completion
        )
    }
    
    // 토큰 재발급 POST API
    public func reissueToken(
        data: ReissueTokenRequestDTO,
        completion: @escaping (Result<LoginResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .ReissueToken(data: data),
            decodingType: LoginResponseDTO.self,
            completion: completion)
    }
    
    /// 약관 동의 POST API
    public func agreeToTerms(
        data: AgreementToTermsRequestDTO,
        completion: @escaping (Result<AgreementToTermsResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .agreeToTerms(data: data),
            decodingType: AgreementToTermsResponseDTO.self,
            completion: completion
        )
    }
    
    public func getTerms(
        completion: @escaping (Result<[GetTermsResponseDTO], NetworkError>) -> Void
    ) {
        request(
            target: .getTerms,
            decodingType: [GetTermsResponseDTO].self,
            completion: completion)
    }
    
    /// 프로필 수정 PATCH API
    public func updateProfile(
        data: ProfileUpdateRequestDTO,
        imageData1: Data,
        imageData2: Data,
        completion: @escaping (Result<ProfileUpdateResponseDTO, NetworkError>) -> Void
    ) {
        request(
            target: .updateProfile(data: data, imageData1: imageData1, imageData2: imageData2),
            decodingType: ProfileUpdateResponseDTO.self,
            completion: completion
        )
    }

    /// 아이디 중복 확인 GET API
    public func checkIdAvailability (
        checkId: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        requestStatusCode(
            target: .checkIdAvailability(checkId: checkId),
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
