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

    override func viewDidLoad() {
        super.viewDidLoad()
        view = accountReportCompleteView

        setupNavigationBar()
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
            //            font: .ptdSemiBoldFont(ofSize: 18),
            font: .systemFont(ofSize: 18, weight: .semibold),
            textColor: .black
        )
    }
    
    // 뒤로가기
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapCompleteButton() {
//        guard let viewControllerStack = self.navigationController?.viewControllers else { return }
//        for viewController in viewControllerStack {
//            if let followProfileVC = viewController as? FollowProfileViewController {
//                self.navigationController?.popToViewController(followProfileVC, animated: true)
//            }
//        }
        let repotSuccessVC = ReportSuccessViewController()
        navigationController?.pushViewController(repotSuccessVC, animated: true)
    }
}
