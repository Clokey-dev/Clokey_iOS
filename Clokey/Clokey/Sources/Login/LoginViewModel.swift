//
//  LoginViewModel.swift
//  Clokey
//
//  Created by 황상환 on 1/8/25.
//

import Foundation
import Combine
import AuthenticationServices

final class LoginViewModel: NSObject {
    
    //MARK: - Properties
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    private let authService = KakaoAuthService.shared

    // MARK: - Methods
        
    // 카카오 로그인
    func handleKakaoLogin() {
        authService.handleKakaoLogin { [weak self] result in
            switch result {
            case .success:
                self?.handleSuccessfulLogin()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    // 애플 로그인 요청 생성
    func createAppleLoginRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        return request
    }
    
    // 애플 로그인 결과 처리
    func handleAppleLoginResult(with credential: ASAuthorizationAppleIDCredential) {
        // 애플 토큰
        /* TODO: 서버로 identityToken을 전송하여 사용자 인증 로직 처리 필요
         
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else { return }
        print(identityToken)
        print(tokenString)
                
        */
        
        // 로그인 성공 처리
        handleSuccessfulLogin()
    }
    
    // 로그인 성공
    private func handleSuccessfulLogin() {
        // UserDefaults 저장 로직
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        // 로그인 상태 업데이트
        isLoggedIn = true
    }
    
}
