//
//  KakaoLoginService.swift
//  Clokey
//
//  Created by 황상환 on 1/8/25.
//

import KakaoSDKUser
import KakaoSDKAuth
import Foundation

final class KakaoAuthService {
    static let shared = KakaoAuthService()
    private init() {}

    func handleKakaoLogin(completion: @escaping (Result<String, Error>) -> Void) {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let accessToken = oauthToken?.accessToken else {
                    completion(.failure(NSError(domain: "KakaoLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access Token 가져오기 실패"])))
                    return
                }
                completion(.success(accessToken))
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let accessToken = oauthToken?.accessToken else {
                    completion(.failure(NSError(domain: "KakaoLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access Token 가져오기 실패"])))
                    return
                }
                completion(.success(accessToken))
            }
        }
    }
}
