//
//  JWTHelper.swift
//  Clokey
//
//  Created by 황상환 on 2/15/25.
//

import Foundation

class JWTHelper {
    static let shared = JWTHelper() // 싱글톤 패턴
    private init() {} // 외부에서 초기화 방지
    
    func getTokenExpirationDate(from jwt: String) -> Date? {
        guard let payload = decodeJWT(jwt),
              let exp = payload["exp"] as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: exp)
    }
    
    func decodeJWT(_ jwt: String) -> [String: Any]? {
        let parts = jwt.split(separator: ".")
        guard parts.count > 1 else {
            print("JWT 형식이 잘못됨: \(jwt)")
            return nil
        }
        
        let payload = String(parts[1])
        var base64 = payload.replacingOccurrences(of: "-", with: "+")
                           .replacingOccurrences(of: "_", with: "/")
        
        while base64.count % 4 != 0 {
            base64.append("=")
        }
        
        guard let data = Data(base64Encoded: base64) else {
            print("Base64 디코딩 실패: \(base64)")
            return nil
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            print("JSON 파싱 실패")
            return nil
        }
        
        return json
    }
    
    // 토큰이 만료되었는지 체크하는 메서드 추가
    func isTokenExpired(_ jwt: String) -> Bool {
        guard let expirationDate = getTokenExpirationDate(from: jwt) else {
            return true // 만료 시간을 확인할 수 없으면 만료된 것으로 처리
        }
        return expirationDate < Date()
    }
}
