//
//  SettingViewController.swift
//  Clokey
//
//  Created by 한금준 on 2/4/25.
//

import UIKit

class SettingViewController: UIViewController {

    private let settingView = SettingView()
    
    // MARK: - Lifecycle
    override func loadView() {
        view = settingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActions()
    }
    
    private func setupActions() {
        // backButton 동작 추가
        settingView.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        settingView.logoutButton.addTarget(self, action: #selector(didTapLogouButton), for: .touchUpInside)
        
        settingView.deleteAccountButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        
        
    }
    
    @objc private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc private func didTapLogouButton() {
        // 로그인 상태 초기화
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            print("SceneDelegate를 찾을 수 없습니다.")
            return
        }
        
        sceneDelegate.switchToLogin()
    }

    @objc private func didTapDeleteButton() {
        let deleteAccountViewController = DeleteAccountViewController()
        deleteAccountViewController.modalPresentationStyle = .fullScreen // 전체 화면으로 표시
        present(deleteAccountViewController, animated: true, completion: nil)
    }
    
    
    
    
}
