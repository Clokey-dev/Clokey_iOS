//
//  AccessTokenPlugin.swift
//  Clokey
//
//  Created by 황상환 on 2/1/25.
//

import Foundation
import Moya

final class AccessTokenPlugin: PluginType {
    func prepare(_ request: URLRequest, target: any TargetType) -> URLRequest {
        var request = request
        
        // 키체인에서 어세스 토큰 가져오기
        if let accessToken = KeychainHelper.shared.get(forKey: "accessToken") {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}
