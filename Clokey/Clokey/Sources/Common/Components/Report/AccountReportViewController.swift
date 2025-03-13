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
    
    private let accountReportView = CustomReportView()
    
    var buttonState: ButtonState = .initial
    
    // 신고할 사용자의 클로키 ID
    var clokeyId: String = ""
    
    // ReportService 인스턴스
    private let reportService = ReportService()
    
    // 로딩 인디케이터
    private var loadingIndicator: UIActivityIndicatorView?
    
    init(clokeyId: String = "") {
        self.clokeyId = clokeyId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = accountReportView
        
        setupNavigationBar()
        setupAction()
        
        // 클로키 ID가 있으면 신고 정보 로드
        if !clokeyId.isEmpty {
            loadReportInfo()
        }
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
    
    // 로딩 인디케이터 표시
    private func showLoadingIndicator() {
        if loadingIndicator == nil {
            loadingIndicator = UIActivityIndicatorView(style: .large)
            loadingIndicator?.center = view.center
            loadingIndicator?.color = .gray
            view.addSubview(loadingIndicator!)
        }
        loadingIndicator?.startAnimating()
    }
    
    // 로딩 인디케이터 숨김
    private func hideLoadingIndicator() {
        loadingIndicator?.stopAnimating()
    }
    
    // API를 통해 신고 정보 로드
    private func loadReportInfo() {
        showLoadingIndicator()
        
        reportService.getProfileReportInfo(clokeyId: clokeyId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                
                switch result {
                case .success(let response):
                    print("신고 정보 로드 성공: \(response)")
                    
                    // ReportReason 배열 생성
                    var reasons = [ReportReason]()
                    
                    for typeResult in response.reportTypeResults {
                        let reason = ReportReason(
                            reportType: typeResult.reportType,
                            title: typeResult.title,
                            reportContents: typeResult.reportContents
                        )
                        reasons.append(reason)
                    }
                    
                    // 뷰 업데이트
                    self.accountReportView.updateUserInfo(
                        clokeyId: response.clokeyId,
                        nickname: response.nickName,
                        profileImageUrl: response.userProfile
                    )
                    self.accountReportView.updateReportReasons(reasons: reasons)
                    
                case .failure(let error):
                    print("신고 정보를 불러오는 데 실패했습니다: \(error.localizedDescription)")
                    self.showErrorAlert()
                }
            }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "오류", message: "신고 정보를 불러오는 데 실패했습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }
    
    // 뒤로가기
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapNextButton() {
        // 선택된 신고 이유가 있는지 확인
        if let selectedReason = accountReportView.getSelectedReportReason() {
            // 다음 화면으로 이동하면서 선택된 신고 이유와 clokeyId 전달
            let nextVC = CustomReportCompleteViewController()
            nextVC.selectedReportReason = selectedReason
            nextVC.reportedClokeyId = self.clokeyId // clokeyId 전달
            navigationController?.pushViewController(nextVC, animated: true)
        } else {
            // 선택된 이유가 없을 경우 알림
            let alert = UIAlertController(title: "알림", message: "신고 사유를 선택해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
        }
    }
}
