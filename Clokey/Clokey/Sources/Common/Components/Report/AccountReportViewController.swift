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
        
        accountReportView.checkbox2.addTarget(self, action: #selector(didTapInfoButton), for: .touchUpInside)
    }
    
    private func setupAction() {
        accountReportView.completeButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(didTapCheckButton1))
        accountReportView.checkbox1Title.isUserInteractionEnabled = true
        accountReportView.checkbox1Title.addGestureRecognizer(tapGesture1)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(didTapInfoButton))
        accountReportView.checkbox2Title.isUserInteractionEnabled = true
        accountReportView.checkbox2Title.addGestureRecognizer(tapGesture2)
        
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(didTapCheckButton3))
        accountReportView.checkbox3Title.isUserInteractionEnabled = true
        accountReportView.checkbox3Title.addGestureRecognizer(tapGesture3)
        
        let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(didTapCheckButton4))
        accountReportView.checkbox4Title.isUserInteractionEnabled = true
        accountReportView.checkbox4Title.addGestureRecognizer(tapGesture4)
        
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
            font: .ptdSemiBoldFont(ofSize: 18),
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
    
    @objc private func didTapCheckButton1(_ sender: UIButton) {
        
        switch buttonState {
        case .initial:
            buttonState = .transformed
            accountReportView.checkbox1.isChecked = true
        case .transformed:
            buttonState = .initial
            accountReportView.checkbox1.isChecked = false
        }
    }
    
    @objc private func didTapCheckButton3(_ sender: UIButton) {
        
        switch buttonState {
        case .initial:
            buttonState = .transformed
            accountReportView.checkbox3.isChecked = true
        case .transformed:
            buttonState = .initial
            accountReportView.checkbox3.isChecked = false
        }
    }
    
    @objc private func didTapCheckButton4(_ sender: UIButton) {
        
        switch buttonState {
        case .initial:
            buttonState = .transformed
            accountReportView.checkbox4.isChecked = true
        case .transformed:
            buttonState = .initial
            accountReportView.checkbox4.isChecked = false
        }
    }
    
    @objc private func didTapInfoButton(_ sender: UIButton) {
        
        switch buttonState {
        case .initial:
            accountReportView.checkbox2InfoContainer.snp.remakeConstraints {
                $0.top.equalTo(accountReportView.checkbox2Title.snp.bottom).offset(8)
                $0.leading.equalTo(accountReportView.checkbox2Title.snp.leading)
                $0.width.equalTo(324)
                $0.height.equalTo(86)
            }
            buttonState = .transformed
            accountReportView.checkbox2.isChecked = true
        case .transformed:
            accountReportView.checkbox2InfoContainer.snp.remakeConstraints {
                $0.top.equalTo(accountReportView.checkbox2Title.snp.bottom).offset(8)
                $0.leading.equalTo(accountReportView.checkbox2Title.snp.leading)
                $0.width.equalTo(324)
                $0.height.equalTo(0)
            }
            buttonState = .initial
            accountReportView.checkbox2.isChecked = false
        }
    }
    
}
