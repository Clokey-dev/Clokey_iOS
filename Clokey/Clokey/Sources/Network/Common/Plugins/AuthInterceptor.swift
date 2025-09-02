//
//  AuthInterceptor.swift
//  Clokey
//
//  Created by 황상환 on 8/30/25.
//

import Foundation
import Alamofire
import Moya
import UIKit

final class AuthInterceptor: RequestInterceptor {

    // 1. 요청을 보내기 전 호출 (헤더 추가)
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        
        // 키체인에서 어세스 토큰 가져오기
        if let accessToken = KeychainHelper.shared.get(forKey: "accessToken") {
            request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        
        print("AuthInterceptor: 헤더에 토큰 추가 완료")
        completion(.success(request))
    }

    // 2. 요청 실패 시 호출 (401 에러 시 재시도)
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        // 401 에러가 아니면 재시도하지 않음
        guard let response = request.response, response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }

        print("AuthInterceptor: 401 Unauthorized 감지. 토큰 재발급 및 재시도 시작")

        // 토큰 재발급 로직 호출
        TokenManager.shared.refreshToken { isSuccess in
            if isSuccess {
                print("AuthInterceptor: 토큰 재발급 성공. 원래 요청을 재시도합니다.")
                completion(.retry) // 원래 요청 재시도
            } else {
                print("AuthInterceptor: 토큰 재발급 실패. 재시도하지 않습니다.")
                // 로그인 화면으로 전환 등의 처리가 필요
                DispatchQueue.main.async {
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.switchToLogin()
                }
                completion(.doNotRetry)
            }
        }
    }
}
