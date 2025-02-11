//
//  DeleteAccountViewController.swift
//  Clokey
//
//  Created by 한금준 on 2/4/25.
//

import UIKit

class DeleteAccountViewController: UIViewController {
    
    private let deleteAccountView = DeleteAccountView()

    override func loadView() {
        view = deleteAccountView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActions()
    }
    
    private func setupActions() {
        // backButton 동작 추가
        deleteAccountView.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        deleteAccountView.cancelButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        // 계정 탈퇴 버튼 동작 추가
        deleteAccountView.deleteButton.addTarget(self, action: #selector(didTapDeleteAccountButton), for: .touchUpInside)
    }
    
    @objc private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapDeleteAccountButton() {
            // UIAlertController를 사용한 팝업 구현
            let alert = UIAlertController(title: "계정 탈퇴",
                                          message: "정말로 계정을 탈퇴하시겠습니까?",
                                          preferredStyle: .alert)
            
            // "탈퇴" 액션 추가
            let deleteAction = UIAlertAction(title: "탈퇴", style: .destructive) { _ in
                self.handleAccountDeletion()
            }
            alert.addAction(deleteAction)
            
            // "취소" 액션 추가
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            // 팝업 표시
            present(alert, animated: true, completion: nil)
        }
    
    private func handleAccountDeletion() {
        print("계정이 탈퇴되었습니다.")
        
        // 로그인 상태 초기화
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            print("SceneDelegate를 찾을 수 없습니다.")
            return
        }
        
        sceneDelegate.switchToLogin()
    }
        
//        private func handleAccountDeletion() {
//            // 계정 탈퇴 로직 처리
//            print("계정이 탈퇴되었습니다.")
//            dismiss(animated: true, completion: nil)
//
//        }

}
