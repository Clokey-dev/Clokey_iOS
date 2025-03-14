//
//  CustomReportViewController.swift
//  Report
//
//  Created by 한금준 on 3/5/25.
//

import UIKit

enum ButtonState {
    case initial
    case transformed
}

class CustomReportViewController: UIViewController {
    private let navBarManager = NavigationBarManager()
    
    private let accountReportView = CustomReportView()
    
    var buttonState: ButtonState = .initial
    
    // 신고할 사용자의 클로키 ID
    var clokeyId: String = ""
    var commentId: Int64?
    var historyId: Int64?

    
    // ReportService 인스턴스
    private let reportService = ReportService()
    
    // 로딩 인디케이터
    private var loadingIndicator: UIActivityIndicatorView?
    
    init(clokeyId: String = "", commentId: Int64? = nil, historyId: Int64? = nil) {
        self.clokeyId = clokeyId
        self.commentId = commentId
        self.historyId = historyId
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
        
        // 신고정보 로드
        if !clokeyId.isEmpty {
            loadProfileReportInfo()
        } else if let commentId = commentId {
            loadCommentReportInfo(commentId: commentId)
        } else if let historyId = historyId {
            loadHistoryReportInfo(historyId: historyId)
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
    
    // MARK: - API
    
    // 계정 신고 정보 로드
    private func loadProfileReportInfo() {
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
    
    // 댓글 신고 정보 로드
    private func loadCommentReportInfo(commentId: Int64) {
        showLoadingIndicator()
        
        reportService.getCommentReportInfo(commentId: String(commentId)) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                
                switch result {
                case .success(let response):
                    print("댓글 신고 정보 로드 성공: \(response)")
                    
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
                    
                    // 댓글 내용 표시 (contentContainer 활성화)
                    if let content = response.commentContent {
                        self.accountReportView.contentContainer.isHidden = false
                        self.accountReportView.divideLine2.isHidden = false
                        self.accountReportView.contentTitle.text = "댓글 내용"
                        self.accountReportView.contentTextLabel.text = content
                        
                        // 제약조건 수정 - 신고 사유 타이틀의 위치를 변경
                        self.accountReportView.reportTitle.snp.remakeConstraints {
                            $0.top.equalTo(self.accountReportView.divideLine2.snp.bottom).offset(12)
                            $0.leading.equalToSuperview().offset(20)
                        }
                    }
                    
                    // 뷰 업데이트
                    self.accountReportView.updateUserInfo(
                        clokeyId: response.clokeyId,
                        nickname: response.nickName,
                        profileImageUrl: response.userProfile
                    )
                    self.accountReportView.updateReportReasons(reasons: reasons)
                    
                    // 네비게이션 타이틀 변경
                    self.navBarManager.setTitle(
                        to: self.navigationItem,
                        title: "댓글 신고하기",
                        font: .systemFont(ofSize: 18, weight: .semibold),
                        textColor: .black
                    )
                    
                case .failure(let error):
                    print("댓글 신고 정보를 불러오는 데 실패했습니다: \(error.localizedDescription)")
                    self.showErrorAlert()
                }
            }
        }
    }
    
    // 기록 신고 정보 로드
    private func loadHistoryReportInfo(historyId: Int64) {
        showLoadingIndicator()
        
        reportService.getHistoryReportInfo(historyId: String(historyId)) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                
                switch result {
                case .success(let response):
                    print("히스토리 신고 정보 로드 성공: \(response)")
                    
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
                    
                    // 히스토리 내용 표시
                    if let content = response.historyContent {
                        self.accountReportView.contentContainer.isHidden = false
                        self.accountReportView.divideLine2.isHidden = false
                        self.accountReportView.contentTitle.text = "기록 내용"
                        self.accountReportView.contentTextLabel.text = content
                        
                        // 제약조건 수정
                        self.accountReportView.reportTitle.snp.remakeConstraints {
                            $0.top.equalTo(self.accountReportView.divideLine2.snp.bottom).offset(12)
                            $0.leading.equalToSuperview().offset(20)
                        }
                    }
                    
                    // 뷰 업데이트
                    self.accountReportView.updateUserInfo(
                        clokeyId: response.clokeyId,
                        nickname: response.nickName,
                        profileImageUrl: response.userProfile
                    )
                    self.accountReportView.updateReportReasons(reasons: reasons)
                    
                    // 네비게이션 타이틀 변경
                    self.navBarManager.setTitle(
                        to: self.navigationItem,
                        title: "기록 신고하기",
                        font: .systemFont(ofSize: 18, weight: .semibold),
                        textColor: .black
                    )
                    
                case .failure(let error):
                    print("히스토리 신고 정보를 불러오는 데 실패했습니다: \(error.localizedDescription)")
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
            // 다음 화면으로 이동하면서 선택된 신고 이유와 ID 전달
            let nextVC = CustomReportCompleteViewController()
            nextVC.selectedReportReason = selectedReason
            
            if !clokeyId.isEmpty {
                nextVC.reportedClokeyId = self.clokeyId // 프로필 신고
                nextVC.reportType = .profile
            } else if let commentId = commentId {
                nextVC.reportedCommentId = commentId // 댓글 신고
                nextVC.reportType = .comment
            } else if let historyId = historyId {
                nextVC.reportedHistoryId = historyId // 기록 신고 추가
                nextVC.reportType = .history
            }
            
            navigationController?.pushViewController(nextVC, animated: true)
        } else {
            // 선택된 이유가 없을 경우 알림
            let alert = UIAlertController(title: "알림", message: "신고 사유를 선택해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
        }
    }
}
