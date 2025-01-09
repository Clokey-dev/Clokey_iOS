//
//  KakaoLoginService.swift
//  Clokey
//
//  Created by 황상환 on 1/8/25.
//

import KakaoSDKUser
import KakaoSDKAuth

final class KakaoAuthService {
    static let shared = KakaoAuthService()
    private init() {}
    
    func handleKakaoLogin(completion: @escaping (Result<Void, Error>) -> Void) {
        // 카카오톡을 통해 로그인 시도
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (_, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
        } else { // 카카오 계정 로그인 방식
            UserApi.shared.loginWithKakaoAccount { (_, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
        }
    }
}
