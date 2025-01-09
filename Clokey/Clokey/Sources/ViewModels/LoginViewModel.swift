//
//  LoginViewModel.swift
//  Clokey
//
//  Created by 황상환 on 1/8/25.
//

import Foundation
import Combine

final class LoginViewModel {
    
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
    
    // 애플 로그인
    func handleAppleLogin() {
        // 애플 로그인 구현 예정
    }
    
    // 로그인 성공
    private func handleSuccessfulLogin() {
        // UserDefaults 저장 로직
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        // 로그인 상태 업데이트
        isLoggedIn = true
    }
    
}
