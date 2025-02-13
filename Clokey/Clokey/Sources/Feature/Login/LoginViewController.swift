//
//  LoginViewController.swift
//  Clokey
//
//  Created by 황상환 on 1/8/25.
//

import Foundation
import UIKit
import SnapKit
import Then
import Combine
import AuthenticationServices

protocol Coordinator: AnyObject {
    func switchToMain()
    func getPresentationAnchor() -> ASPresentationAnchor
    
    //
    func navigateToAgreement() // 약관동의 화면으로 이동
    //
}

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    private lazy var loginView = LoginView()
    private var cancellables = Set<AnyCancellable>()
    private weak var coordinator: Coordinator?
    private let authService = KakaoAuthService.shared

    // 로그인 상태 및 에러 메시지 관리
    @Published private var isLoggedIn = false
    @Published private var errorMessage: String?

    // MARK: - Initialization
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // 카카오 로그인 버튼 이벤트 설정
        loginView.kakaoLoginButton.addTarget(
            self,
            action: #selector(kakaoLoginButtonTapped),
            for: .touchUpInside
        )
        
        // 애플 로그인 버튼 이벤트 설정
        loginView.appleLoginButton.addTarget(
            self,
            action: #selector(appleLoginButtonTapped),
            for: .touchUpInside
        )

        // 로그인 상태 변화 감지
        $isLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                if isLoggedIn {
//                    self?.navigateToMain()
                    self?.navigateToAgreement()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    // 카카오 로그인
    @objc private func kakaoLoginButtonTapped() {
        authService.handleKakaoLogin { [weak self] result in
            switch result {
            case .success(let accessToken):
                self?.sendKakaoLoginRequest(accessToken: accessToken)
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    // 애플 로그인
    @objc private func appleLoginButtonTapped() {
        let request = createAppleLoginRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // MARK: - Apple Login
    
    // 애플 로그인 요청 생성
    private func createAppleLoginRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        return request
    }
    
    // 애플 로그인 결과 처리
        private func handleAppleLoginResult(with credential: ASAuthorizationAppleIDCredential) {
            guard let authorizationCode = credential.authorizationCode,
                  let codeString = String(data: authorizationCode, encoding: .utf8) else {
                errorMessage = "Failed to get authorization code"
                return
            }
            
            // 이메일 확인
            if let email = credential.email {
                print("Email: \(email)")
            }
            
            print("Authorization Code: \(codeString)")
            handleSuccessfulLogin()
        }

    // MARK: - Helpers
    
    // 로그인 성공
    private func handleSuccessfulLogin() {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        isLoggedIn = true
    }
    
    // 로그인 -> 메인
//    private func navigateToMain() {
//        coordinator?.switchToMain()
//    }
    
    //
    private func navigateToAgreement() {
        guard let SceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            fatalError("SceneDelegate not found")
        }
        SceneDelegate.navigateToAgreement()
    }
    //
    
    // MARK: - API
    
    // Kakao Login
    private func sendKakaoLoginRequest(accessToken: String) {
        let requestDTO = KakaoLoginRequestDTO(type: "kakao", accessToken: accessToken)
        let memberService = MembersService()
        
        print("카카오 AccessToken: \(accessToken)")
        
        memberService.kaKaoLogin(data: requestDTO) { result in
            switch result {
            case .success(let response):
                // AccessToken & RefreshToken을 Keychain에 저장
                KeychainHelper.shared.save(response.accessToken, forKey: "accessToken")
                KeychainHelper.shared.save(response.refreshToken, forKey: "refreshToken")
                
                print("로그인 성공: \(response)")
                
                // ✅ registerStatus 확인
                if response.registerStatus == "REGISTERED" {
                    DispatchQueue.main.async {
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                            sceneDelegate.switchToMain()
                        } else {
                            print("🚨 SceneDelegate를 찾을 수 없음")
                        }
                    }
                } else if response.registerStatus == "AGREED_PROFILE_NOT_SET" {
                    DispatchQueue.main.async {
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                            sceneDelegate.navigateToAddProfile()
                        } else {
                            print("🚨 SceneDelegate를 찾을 수 없음")
                        }
                    }
                }
                else {
                    self.navigateToAgreement() // 약관 동의 화면으로 이동
                }
//                self.handleSuccessfulLogin()
            
            case .failure(let error):
                if case .serverError(let statusCode, _) = error, statusCode == 4001 {
                    self.reissueToken { reissueResult in
                        switch reissueResult {
                        case .success(let newTokens):
                            // 새로운 액세스 토큰으로 다시 로그인 요청
                            self.sendKakaoLoginRequest(accessToken: newTokens.accessToken)
                        case .failure(let reissueError):
                            print("토큰 재발급 실패: \(reissueError.localizedDescription)")
                            self.errorMessage = reissueError.localizedDescription
                        }
                    }
                } else {
                    print("로그인 실패: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // 재발급
    private func reissueToken(completion: @escaping (Result<KakaoLoginResponseDTO, Error>) -> Void) {
        guard let refreshToken = KeychainHelper.shared.get(forKey: "refreshToken") else {
            completion(.failure(NSError(domain: "TokenReissue", code: -1, userInfo: [NSLocalizedDescriptionKey: "리프레시 토큰 없음"])))
            return
        }
        
        let reissueRequestDTO = ReissueTokenRequestDTO(refreshToken: refreshToken)
        let memberService = MembersService()
        
        memberService.reissueToken(data: reissueRequestDTO) { result in
            switch result {
            case .success(let response):
                KeychainHelper.shared.save(response.accessToken, forKey: "accessToken")
                KeychainHelper.shared.save(response.refreshToken, forKey: "refreshToken")
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}

// MARK: - ASAuthorizationControllerDelegate
extension LoginViewController: ASAuthorizationControllerDelegate {
    // 애플 로그인 성공 시 호출
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            handleAppleLoginResult(with: appleIDCredential)
        }
    }
    
    // 애플 로그인 실패 시 호출
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        errorMessage = error.localizedDescription
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    // 애플 로그인 창을 표시할 앵커 뷰를 반환
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let presentationAnchor = coordinator?.getPresentationAnchor() else {
            fatalError("Coordinator must provide a presentation anchor")
        }
        return presentationAnchor
    }
}
