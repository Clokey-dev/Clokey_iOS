//
//  CustomReportCompleteViewController.swift
//  Report
//
//  Created by 한금준 on 3/5/25.
//

import UIKit

class CustomReportCompleteViewController: UIViewController {
    
    enum ReportType {
        case profile
        case comment
        case history
    }
    
    private let navBarManager = NavigationBarManager()
    
    private let customReportCompleteView = CustomReportCompleteView()

    // 선택된 신고 이유를 저장할 변수
    var selectedReportReason: ReportReason?
    
    // 신고 대상 사용자의 클로키 ID
    var reportedClokeyId: String = ""
    
    // ReportService 인스턴스
    private let reportService = ReportService()
    
    var reportType: ReportType = .profile
    var reportedCommentId: Int64?
    var reportedHistoryId: Int64?

    override func viewDidLoad() {
        super.viewDidLoad()
        view = customReportCompleteView
        
        setupNavigationBar()
        setupAction()
        setupTapGesture()
        
        // 선택된 신고 이유가 있으면 뷰에 설정
        if let selectedReason = selectedReportReason {
            customReportCompleteView.setReportReason(selectedReason.title)
        }
    }
    
    private func setupAction() {
        customReportCompleteView.completeButton.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
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
    
    // 신고 완료 버튼 클릭 시 처리
    @objc private func didTapCompleteButton() {
        guard let reportReason = selectedReportReason else {
            showAlert(message: "신고 사유가 선택되지 않았습니다.")
            return
        }
        
        // 신고 내용 가져오기
        let reportContent = customReportCompleteView.getTextContent()
        
        // 신고 내용이 비어있거나 기본 텍스트인 경우 처리
        if reportContent.isEmpty || reportContent == "신고 내용을 입력해주세요." {
            showAlert(message: "신고 내용을 입력해주세요.")
            return
        }
        
        switch reportType {
        case .profile:
            submitProfileReport(reason: reportReason, content: reportContent)
        case .comment:
            submitCommentReport(reason: reportReason, content: reportContent)
        case .history:
            submitHistoryReport(reason: reportReason, content: reportContent)
        }
    }
    
    private func submitProfileReport(reason: ReportReason, content: String) {
        if reportedClokeyId.isEmpty {
            showAlert(message: "신고할 사용자 정보가 없습니다.")
            return
        }
        
        // 신고 데이터 생성
        let reportData = AccountReportRequestDTO(
            clokeyId: reportedClokeyId,
            profileReportType: reason.reportType,
            content: content
        )
        
        // 신고 API 호출
        reportService.reportProfile(data: reportData) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(_):
                    // 신고 성공 처리
                    self.showSuccessAlert()
                    
                case .failure(let error):
                    // 신고 실패 처리
                    print("신고 실패: \(error.localizedDescription)")
                    self.showAlert(message: "신고 제출에 실패했습니다. 다시 시도해주세요.")
                }
            }
        }
    }

    private func submitCommentReport(reason: ReportReason, content: String) {
        guard let commentId = reportedCommentId else {
            showAlert(message: "신고할 댓글 정보가 없습니다.")
            return
        }
        
        // 신고 데이터 생성
        let reportData = CommentReportRequestDTO(
            commentId: Int(commentId), // commentId를 string으로 변환
            commentReportType: reason.reportType,
            content: content
        )
        
        // 신고 API 호출
        reportService.reportComment(data: reportData) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    // 신고 성공 처리
                    self.showSuccessAlert()
                    
                case .failure(let error):
                    // 신고 실패 처리
                    print("댓글 신고 실패: \(error.localizedDescription)")
                    self.showAlert(message: "신고 제출에 실패했습니다. 다시 시도해주세요.")
                }
            }
        }
    }
    
    private func submitHistoryReport(reason: ReportReason, content: String) {
        guard let historyId = reportedHistoryId else {
            showAlert(message: "신고할 기록 정보가 없습니다.")
            return
        }
        
        // 신고 데이터 생성
        let reportData = HistoryReportRequestDTO(
            historyId: Int(historyId),
            historyReportType: reason.reportType,
            content: content
        )
        
        // 신고 API 호출
        reportService.reportHistory(data: reportData) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    // 신고 성공 처리
                    self.showSuccessAlert()
                    
                case .failure(let error):
                    // 신고 실패 처리
                    print("히스토리 신고 실패: \(error.localizedDescription)")
                    self.showAlert(message: "신고 제출에 실패했습니다. 다시 시도해주세요.")
                }
            }
        }
    }
    
    // 알림 표시
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // 신고 성공 알림 및 화면 이동
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "신고 완료", message: "신고가 성공적으로 접수되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            // 홈 화면 또는 이전 화면으로 이동
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    // 탭 제스처 설정 함수 추가
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    // 키보드 내리는 함수 추가
    @objc internal override func dismissKeyboard() {
        view.endEditing(true)
    }
}
