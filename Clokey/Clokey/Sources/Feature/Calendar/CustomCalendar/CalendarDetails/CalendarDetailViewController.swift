//
//  CalendarDetailViewController.swift
//  Clokey
//
//  Created by 황상환 on 2/1/25.
//

import Foundation
import UIKit

class CalendarDetailViewController: UIViewController {

    private let calendarDetailView = CalendarDetailView()
    private var viewModel: CalendarDetailViewModel?

    private var detailData: HistoryDetailResponseDTO?
    private let historyService = HistoryService()
    let navBarManager = NavigationBarManager()

    // 임시 historyId - 서버에게 추가로 요청해야함.
//    private let historyId = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        updateView()
        
        calendarDetailView.likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
//        calendarDetailView.commentContainerView.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        calendarDetailView.plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        
        // 댓글창
        let commentTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCommentButton))
        calendarDetailView.commentContainerView.addGestureRecognizer(commentTapGesture)
        
        // likeLabel에 탭 제스처 추가
        let likeTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLikeLabel))
        calendarDetailView.likeLabel.isUserInteractionEnabled = true
        calendarDetailView.likeLabel.addGestureRecognizer(likeTapGesture)
    }

    func setDetailData(_ data: HistoryDetailResponseDTO) {
        self.viewModel = CalendarDetailViewModel(data: data)
        if isViewLoaded {
            updateView()
        }
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(calendarDetailView)
        
        calendarDetailView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        
        navBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(didTapBackButton)
        )
        
//        navBarManager.setTitle(
//            to: navigationItem,
//            title: "상세보기", // ✅ 원하는 타이틀 설정
//            font: .systemFont(ofSize: 18, weight: .semibold),
//            textColor: .black
//        )
    }
    
    private func updateView() {
        if let viewModel = viewModel {
            calendarDetailView.configure(with: viewModel)
        }
    }

    
    // MARK: - Action
    
    // 좋아요 버튼
    @objc private func didTapLikeButton() {
        toggleLikeState()
    }
    
    // 댓글뷰
    @objc private func didTapCommentButton() {
        let commentVC = CalendarCommentViewController()
        commentVC.modalPresentationStyle = .pageSheet
        
        if let sheet = commentVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.preferredCornerRadius = 20
        }
        
        present(commentVC, animated: true)
    }
    
    // 편집뷰
    @objc private func didTapPlusButton() {
        let actionSheet = CustomActionSheetViewController()
        actionSheet.modalPresentationStyle = .overFullScreen
        present(actionSheet, animated: false)
    }
    
    // 좋아요 누른 사람 뷰
    @objc private func didTapLikeLabel() {
        // TODO: 나중에 바로 연결해서 줘도 좋을 듯
        // let likeListVC = LikeListViewController(historyId: yourHistoryId)
        let likeListVC = LikeListViewController()
        likeListVC.modalPresentationStyle = .pageSheet
        
        if let sheet = likeListVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.preferredCornerRadius = 20
        }
        
        present(likeListVC, animated: true)
    }
    
    // 뒤로가기
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Method
    
    // 좋아요
    private func toggleLikeState() {
        guard let viewModel = viewModel else { return }
        
        // 현재 좋아요 상태 확인
        let isCurrentlyLiked = calendarDetailView.likeButton.currentImage == UIImage(named: "heart_fill")
        
        print("isCurrentlyLiked 상태 : \(isCurrentlyLiked)")
        
        // 임시 UI 업데이트 (옵티미스틱 업데이트)
        let newLikeCount = (Int(viewModel.likeCount) ?? 0) + (isCurrentlyLiked ? -1 : 1)
        calendarDetailView.likeButton.setImage(UIImage(named: isCurrentlyLiked ? "heart_empty" : "heart_fill"), for: .normal)
        calendarDetailView.likeLabel.text = "\(newLikeCount)"

        // API 호출 - viewModel에서 historyId 가져옴
        fetchToggleLike(historyId: Int(viewModel.historyId), liked: isCurrentlyLiked)
    }
    
    // 좋아요 토글 API
    private func fetchToggleLike(historyId: Int, liked: Bool) {
        let request = HistoryLikeRequestDTO(historyId: "\(historyId)", liked: liked)
        
        historyService.historyLike(data: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                print("좋아요 변경 성공: \(response)")
                
                // ViewModel 업데이트
                if var updatedViewModel = self.viewModel {
                    // ViewModel의 좋아요 상태 업데이트
                    updatedViewModel.updateLikeState(liked: response.liked, likeCount: response.likeCount)
                    self.viewModel = updatedViewModel
                    
                    DispatchQueue.main.async {
                        self.calendarDetailView.updateLikeState(with: updatedViewModel)
                    }
                }
                
            case .failure(let error):
                print("좋아요 변경 실패: \(error.localizedDescription)")
            }
        }
    }
}
