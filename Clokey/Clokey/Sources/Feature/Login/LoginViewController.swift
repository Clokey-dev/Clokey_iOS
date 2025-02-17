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
    func navigateToAgreement() // 약관동의 화면으로 이동
}

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    private lazy var loginView = LoginView()
    private var cancellables = Set<AnyCancellable>()
    private weak var coordinator: Coordinator?
    private let authService = KakaoAuthService.shared
    let memberService = MembersService()

    // 로그인 상태 및 에러 메시지 관리
    @Published private var errorMessage: String?
    // fcm 디바이스 토큰
    private let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") ?? ""

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
    }
    
    // MARK: - Actions
    
    // 카카오 로그인
    @objc private func kakaoLoginButtonTapped() {
        authService.handleKakaoLogin { [weak self] result in
            switch result {
            case .success(let accessToken):
                self?.sendKakaoLoginRequest(accessToken: accessToken, fcmToken: self?.fcmToken ?? "")
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

    // MARK: - Social Login
    
    // 카카오 로그인
    private func sendKakaoLoginRequest(accessToken: String, fcmToken: String) {
        handleSocialLogin(type: "kakao", accessToken: accessToken, fcmToken: fcmToken)
    }
    
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
        
        if let email = credential.email {
            print("Email: \(email)")
        }
        print("Authorization Code: \(codeString)")
        
        handleSocialLogin(type: "apple", authorizationCode: codeString, fcmToken: fcmToken)
    }

    // MARK: - Helpers
    
    // 약관동의로..
    private func navigateToAgreement() {
        guard let SceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            fatalError("SceneDelegate not found")
        }
        SceneDelegate.navigateToAgreement()
    }
    //
    
    // MARK: - API
    
    // 공동 로그인 처리
    private func handleSocialLogin(type: String, accessToken: String? = nil, authorizationCode: String? = nil, fcmToken: String? = nil) {
        let requestDTO = LoginRequestDTO(
            type: type,
            accessToken: accessToken,
            authorizationCode: authorizationCode,
            deviceToken: fcmToken ?? ""
        )
        
        memberService.SocialLogin(data: requestDTO) { [weak self] result in
            switch result {
            case .success(let response):
                // AccessToken & RefreshToken 저장
                KeychainHelper.shared.save(response.accessToken, forKey: "accessToken")
                KeychainHelper.shared.save(response.refreshToken, forKey: "refreshToken")
                
                print("\n로그인 성공: \(response)\n")
                
                // 상태에 따른 화면 전환
                DispatchQueue.main.async {
                    self?.handleLoginResponse(status: response.registerStatus)
                }
                
            case .failure(let error):
                print("로그인 실패: \(error.localizedDescription)")
                self?.errorMessage = error.localizedDescription
            }
        }
    }

    // 회원가입 처리 로직
    private func handleLoginResponse(status: String) {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            print("SceneDelegate를 찾을 수 없음")
            return
        }
        
        switch status {
        case "REGISTERED":
            // 자동 로그인을 위한 키
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            print("자동로그인 ON")
            sceneDelegate.switchToMain()
        case "AGREED_PROFILE_NOT_SET":
            sceneDelegate.navigateToAddProfile()
        default:
            navigateToAgreement()
        }
    }

    // 재발급
    private func reissueToken(completion: @escaping (Result<LoginResponseDTO, Error>) -> Void) {
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
