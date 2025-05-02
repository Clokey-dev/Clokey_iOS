//
//  TokenManager.swift
//  Clokey
//
//  Created by 황상환 on 2/15/25.
//

import Foundation

class TokenManager {
    static let shared = TokenManager()
    private init() {}
    
    private let memberService = MembersService()
    // 제한 시간 설정
    private let THREE_HOURS: TimeInterval = 3 * 60 * 60
    
    func validateAndRefreshTokenIfNeeded(completion: @escaping (Bool) -> Void) {
        guard let accessToken = KeychainHelper.shared.get(forKey: "accessToken"),
              let expirationDate = JWTHelper.shared.getTokenExpirationDate(from: accessToken) else {
            print("액세스 토큰이 없거나 파싱 실패 → 로그인 필요")
            completion(false) // 로그인 화면 이동
            return
        }

        let timeRemaining = expirationDate.timeIntervalSince(Date())
        print("TokenManager: JWT 만료시간 = \(expirationDate)")
        print("TokenManager: 남은시간 = \(timeRemaining / 60)분")

        // accessToken이 만료되었을 경우 → refreshToken으로 재발급 시도
        if timeRemaining <= 0 {
            print("액세스 토큰 만료됨! 리프레시 토큰으로 재발급 시도")

            if KeychainHelper.shared.get(forKey: "refreshToken") == nil {
                print("리프레시 토큰 없음 → 로그인 화면 이동")
                KeychainHelper.shared.delete(forKey: "accessToken")
                KeychainHelper.shared.delete(forKey: "refreshToken")
                completion(false) // 로그인 화면 이동
                return
            }

            // refreshToken() 실행
            refreshToken { isSuccess in
                if isSuccess {
                    print("액세스 토큰 재발급 완료 from TokenManager")
                    completion(true)
                } else {
                    print("리프레시 토큰도 만료됨 → 로그인 화면 이동")
                    KeychainHelper.shared.delete(forKey: "accessToken")
                    KeychainHelper.shared.delete(forKey: "refreshToken")
                    completion(false) // 로그인 화면 이동
                }
            }
            return
        }


        // 10분 이하 남았을 때만 갱신 실행
        if timeRemaining <= 10 * 60 {
            print("토큰 만료 임박.. 재발급 ON!")
            refreshToken(completion: completion)
        } else {
            completion(true) // 토큰이 충분히 남았으면 그냥 유지
        }
    }

    // 재발급 API
    func refreshToken(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let refreshToken = KeychainHelper.shared.get(forKey: "refreshToken") else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            print("리프레시 토큰을 사용하여 액세스 토큰 재발급 시도")

            let reissueRequestDTO = ReissueTokenRequestDTO(refreshToken: refreshToken)
            
            self.memberService.reissueToken(data: reissueRequestDTO) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        KeychainHelper.shared.save(response.accessToken, forKey: "accessToken")
                        KeychainHelper.shared.save(response.refreshToken, forKey: "refreshToken")
                        completion(true) // 토큰 재발급 성공
                    case .failure(_):
                        completion(false) // 재발급 실패
                    }
                }
            }
        }
    }

}
