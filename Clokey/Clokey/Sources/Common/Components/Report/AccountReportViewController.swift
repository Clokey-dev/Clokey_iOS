//
//  AccountReportViewController.swift
//  Report
//
//  Created by 한금준 on 3/5/25.
//

import UIKit

enum ButtonState {
    case initial
    case transformed
}

class AccountReportViewController: UIViewController {
    private let navBarManager = NavigationBarManager()
    
    private let accountReportView = AccountReportView()
    
    var buttonState: ButtonState = .initial
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = accountReportView
        
        setupNavigationBar()
        setupAction()
    }
    
    private func setupAction() {
        accountReportView.completeButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
    }
    
    // 네비게이션 설정
    private func setupNavigationBar() {
        navBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(didTapBackButton)
        )
        
        navBarManager.setTitle(
            to: navigationItem,
            title: "계정 신고하기",
            font: .systemFont(ofSize: 18, weight: .semibold),
            textColor: .black
        )
    }
    
    // 뒤로가기
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapNextButton() {
        // 선택된 신고 이유가 있는지 확인
        if let selectedReason = accountReportView.getSelectedReportReason() {
            // 다음 화면으로 이동하면서 선택된 신고 이유 전달
            let nextVC = AccountReportCompleteViewController()
            nextVC.selectedReportReason = selectedReason
            navigationController?.pushViewController(nextVC, animated: true)
        } else {
            // 선택된 이유가 없을 경우 알림
            let alert = UIAlertController(title: "알림", message: "신고 사유를 선택해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
        }
    }
}
