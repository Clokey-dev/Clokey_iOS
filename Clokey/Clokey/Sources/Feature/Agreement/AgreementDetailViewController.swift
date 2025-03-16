//
//  AgreementDetailViewController.swift
//  Clokey
//
//  Created by 소민준 on 1/18/25.
//

import UIKit
import WebKit

/// 약관동의 case
enum AgreementType {
    case termsOfService
    case privacyPolicy
    case locationPolicy
    case marketingPolicy
    case pushPolicy
    case nothing
}

class AgreementDetailViewController: UIViewController {
    private let navBarManager = NavigationBarManager()
    private let webView: WKWebView!
    private let agreementTitle: String

    init(title: String, agreementType: AgreementType) {
        self.agreementTitle = title
        let configuration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        super.init(nibName: nil, bundle: nil)
        connectWebLink(agreementType: agreementType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupUI()
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
            title: agreementTitle,
            font: .ptdSemiBoldFont(ofSize: 18),
            textColor: .black
        )
    }
    
    // 뒤로가기
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    /// webView 레이아웃 설정
    private func setupUI() {
        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
    }

    /// 약관동의 깃헙 연결 함수
    private func connectWebLink(agreementType: AgreementType) {
        switch agreementType {
        case .termsOfService:
            if let termsOfServiceURL = URL(string: "https://namu.wiki/w/서비스") {
                let request = URLRequest(url: termsOfServiceURL)
                webView.load(request)
            } else {
                
            }
        case .privacyPolicy:
            if let privacyPolicyURL = URL(string: "https://namu.wiki/w/개인정보") {
                let request = URLRequest(url: privacyPolicyURL)
                webView.load(request)
            } else {
                
            }
        case .locationPolicy:
            if let termsOfServiceURL = URL(string: "https://namu.wiki/w/위치") {
                let request = URLRequest(url: termsOfServiceURL)
                webView.load(request)
            } else {
                
            }
        case .marketingPolicy:
            if let termsOfServiceURL = URL(string: "https://namu.wiki/w/마케팅") {
                let request = URLRequest(url: termsOfServiceURL)
                webView.load(request)
            } else {
               
            }
        case .pushPolicy:
            if let termsOfServiceURL = URL(string: "https://namu.wiki/w/푸시") {
                let request = URLRequest(url: termsOfServiceURL)
                webView.load(request)
            } else {
               
            }
        case .nothing:
            if let termsOfServiceURL = URL(string: "https://namu.wiki/w/논") {
                let request = URLRequest(url: termsOfServiceURL)
                webView.load(request)
            } else {
                
            }
        }
    }
}
