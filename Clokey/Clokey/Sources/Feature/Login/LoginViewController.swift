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
                    self?.navigateToMain()
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
        // 애플 토큰
        // TODO: 서버로 identityToken을 전송하여 사용자 인증 로직 처리 필요
        
//        guard let identityToken = credential.identityToken,
//              let tokenString = String(data: identityToken, encoding: .utf8) else { return }
//        print(identityToken)
//        print(tokenString)
    
        
        handleSuccessfulLogin()
    }

    // MARK: - Helpers
    
    // 로그인 성공
    private func handleSuccessfulLogin() {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        isLoggedIn = true
    }
    
    // 로그인 -> 메인
    private func navigateToMain() {
        coordinator?.switchToMain()
    }
    
    // MARK: - API
    
    // Kakao Login
    private func sendKakaoLoginRequest(accessToken: String) {
        let requestDTO = KakaoLoginRequestDTO(type: "kakao", accessToken: accessToken)
        
        let memberService = MembersService()
        memberService.kaKaoLogin(data: requestDTO) { result in
            switch result {
            case .success(let response):
                
                // AccessToken & RefreshToken을 Keychain에 저장
                KeychainHelper.shared.save(response.accessToken, forKey: "accessToken")
                KeychainHelper.shared.save(response.refreshToken, forKey: "refreshToken")
                
                print("로그인 성공: \(response)")
                self.handleSuccessfulLogin()
            case .failure(let error):
                print("로그인 실패: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
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
