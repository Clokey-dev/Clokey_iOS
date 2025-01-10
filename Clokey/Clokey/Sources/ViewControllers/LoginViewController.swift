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
    private let viewModel = LoginViewModel()
    private var cancellables = Set<AnyCancellable>()
    private weak var coordinator: Coordinator?
    
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
        bindViewModel()
     
    }
    
    // MARK: - Setup
    
    // 로그인 버튼에 액션 연결
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
    
    // 로그인 상태 변화 감지
    private func bindViewModel() {
        viewModel.$isLoggedIn
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
        viewModel.handleKakaoLogin()
    }
    
    // 애플 로그인
    @objc private func appleLoginButtonTapped() {
        // 애플 로그인 요청 객체 생성
        let request = viewModel.createAppleLoginRequest()
        // 인증 컨트롤러 생성 및 설정
        // ASAuthorizationController: 애플 인증 요청을 처리하는 컨트롤러
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        // 델리게이트 설정 - 인증 결과를 받을 객체 지정
        authorizationController.delegate = self
        // 로그인 UI를 표시할 window 설정
        authorizationController.presentationContextProvider = self
        // 애플 로그인 시트
        authorizationController.performRequests()
    }
    
    
    // MARK: - Navigation
    
    // 화면 전환 메서드
    private func navigateToMain() {
        coordinator?.switchToMain()
    }

}

// MARK: - ASAuthorizationControllerDelegate
// 애플 로그인 인증 결과를 처리하는 델리게이트
extension LoginViewController: ASAuthorizationControllerDelegate {
    // 인증 성공 시 호출되는 메서드
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // 애플이 제공하는 사용자 인증 정보(credential)를 ASAuthorizationAppleIDCredential로 타입 캐스팅
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // ViewModel에게 인증 결과 처리 위임
            viewModel.handleAppleLoginResult(with: appleIDCredential)
        }
    }
    
    // 인증 실패 시 호출되는 메서드
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 에러 메시지를 ViewModel의 errorMessage에 전달
        viewModel.errorMessage = error.localizedDescription
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
// 애플 로그인 UI를 어디에 표시할지 지정하는 프로토콜
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    // 로그인 UI를 표시할 window를 반환하는 메서드
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let presentationAnchor = coordinator?.getPresentationAnchor() else {
            fatalError("Coordinator must provide a presentation anchor")
        }
        return presentationAnchor
    }
}
