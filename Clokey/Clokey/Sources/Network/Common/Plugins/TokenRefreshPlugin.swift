//
//  TokenRefreshPlugin.swift
//  Clokey
//
//  Created by 황상환 on 2/15/25.
//

import Foundation
import Moya

final class TokenRefreshPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request

        // 현재 액세스 토큰 가져오기
        guard let accessToken = KeychainHelper.shared.get(forKey: "accessToken") else {
            return request
        }

        // 토큰이 만료될 예정인지 확인 - 5분 이하
        if let expirationDate = JWTHelper.shared.getTokenExpirationDate(from: accessToken) {
            let timeRemaining = expirationDate.timeIntervalSince(Date())
            
            if timeRemaining <= 5 * 60 { // 5분 이하 남았을 때
                print("토큰 만료 임박.. 바로 재발급 ON from TokenRefreshPlugin")
                TokenManager.shared.validateAndRefreshTokenIfNeeded { isValid in
                    if isValid {
                        if let newAccessToken = KeychainHelper.shared.get(forKey: "accessToken") {
                            request.addValue("Bearer \(newAccessToken)", forHTTPHeaderField: "Authorization")
                        }
                    }
                }
            }
        }

        return request
    }
}
