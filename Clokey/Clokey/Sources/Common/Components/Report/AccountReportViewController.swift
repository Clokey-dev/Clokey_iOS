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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapInfoButton))
        accountReportView.checkbox2Title.isUserInteractionEnabled = true
        accountReportView.checkbox2Title.addGestureRecognizer(tapGesture)
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
    
    @objc private func didTapNextButton() {
        let nextVC = AccountReportCompleteViewController()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc private func didTapInfoButton(_ sender: UIButton) {
        
        switch buttonState {
        case .initial:
            accountReportView.checkbox2InfoContainer.snp.remakeConstraints {
                $0.top.equalTo(accountReportView.checkbox2Title.snp.bottom).offset(8)
                $0.leading.equalTo(accountReportView.checkbox2Title.snp.leading)
                $0.width.equalTo(324)
                $0.height.equalTo(0)
            }
            buttonState = .transformed
        case .transformed:
            accountReportView.checkbox2InfoContainer.snp.remakeConstraints {
                $0.top.equalTo(accountReportView.checkbox2Title.snp.bottom).offset(8)
                $0.leading.equalTo(accountReportView.checkbox2Title.snp.leading)
                $0.width.equalTo(324)
                $0.height.equalTo(86)
            }
            buttonState = .initial
        }
    }
    
}
