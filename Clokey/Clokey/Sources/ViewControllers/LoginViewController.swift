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

protocol Coordinator: AnyObject {
    func switchToMain()
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
        viewModel.handleAppleLogin()
    }
    
    
    // MARK: - Navigation
    
    // 화면 전환 메서드
    private func navigateToMain() {
        coordinator?.switchToMain()
    }

}
