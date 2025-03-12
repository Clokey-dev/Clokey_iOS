//
//  AccountReportCompleteViewController.swift
//  Report
//
//  Created by 한금준 on 3/5/25.
//

import UIKit

class AccountReportCompleteViewController: UIViewController {
    private let navBarManager = NavigationBarManager()
    
    private let accountReportCompleteView = AccountReportCompleteView()

    // 선택된 신고 이유를 저장할 변수
    var selectedReportReason: ReportReason?

    override func viewDidLoad() {
        super.viewDidLoad()
        view = accountReportCompleteView
        
        setupNavigationBar()
        setupAction()
        
        // 선택된 신고 이유가 있으면 뷰에 설정
        if let selectedReason = selectedReportReason {
            accountReportCompleteView.setReportReason(selectedReason.title)
        }
    }
    
    private func setupAction() {
        accountReportCompleteView.completeButton.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
        
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
    
    @objc private func didTapCompleteButton() {

    }
}
