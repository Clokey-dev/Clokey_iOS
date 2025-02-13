//
//  CalendarDetailViewController.swift
//  Clokey
//
//  Created by 황상환 on 2/1/25.
//

import Foundation
import UIKit

protocol RecordOOTDViewControllerDelegate: AnyObject {
    func didUpdateHistory()
}

class CalendarDetailViewController: UIViewController {

    // MARK: - Properties
    private let calendarDetailView = CalendarDetailView()
    private var viewModel: CalendarDetailViewModel?

    private var detailData: HistoryDetailResponseDTO?
    private let historyService = HistoryService()
    let navBarManager = NavigationBarManager()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        updateView()
        
        calendarDetailView.likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)

        calendarDetailView.plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        
        calendarDetailView.clothesIconButton.addTarget(self, action: #selector(didTapClothesIconButton), for: .touchUpInside)
        
        calendarDetailView.moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)

        
        // 댓글창
        let commentTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCommentButton))
        calendarDetailView.commentContainerView.addGestureRecognizer(commentTapGesture)
        
        // likeLabel에 탭 제스처 추가
        let likeTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLikeLabel))
        calendarDetailView.likeLabel.isUserInteractionEnabled = true
        calendarDetailView.likeLabel.addGestureRecognizer(likeTapGesture)
    }

    // MARK: - Setup
    
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
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        
        navBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(didTapBackButton)
        )
    }
    
    private func updateView() {
        if let viewModel = viewModel {
            calendarDetailView.configure(with: viewModel)
        }
    }

    
    // MARK: - Action
    
    // 태그 버튼
    @objc private func didTapClothesIconButton() {
        guard let viewModel = viewModel else { return }
        let clothDTOs = viewModel.cloths.map { ClothDTO(clothId: $0.clothId, clothImageUrl: $0.imageUrl, clothName: $0.name) }
        let tagView = RecordTagClothViewController(cloths: clothDTOs)
        tagView.modalPresentationStyle = .overFullScreen
        present(tagView, animated: false)
    }
    
    // 좋아요 버튼
    @objc private func didTapLikeButton() {
        toggleLikeState()
    }
    
    // 댓글뷰
    @objc private func didTapCommentButton() {
        guard let viewModel = viewModel else { return }
        let historyId = Int(viewModel.historyId)
        
        let commentVC = CalendarCommentViewController(historyId: historyId)
        commentVC.modalPresentationStyle = .pageSheet
        if let sheet = commentVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.preferredCornerRadius = 20
        }
        
        present(commentVC, animated: true)
    }
    
    // 편집뷰
    @objc private func didTapPlusButton() {
        guard let viewModel = viewModel else { return }
        let historyId = Int(viewModel.historyId)
        
        let actionSheet = CustomActionSheetViewController(historyId: historyId)
        actionSheet.delegate = self // delegate 설정 추가
        actionSheet.modalPresentationStyle = .overFullScreen
        present(actionSheet, animated: false)
    }
    
    // 좋아요 누른 사람 뷰
    @objc private func didTapLikeLabel() {
        guard let viewModel = viewModel else { return }
        let historyId = Int(viewModel.historyId)
        
        let likeListVC = LikeListViewController(historyId: historyId)
        likeListVC.modalPresentationStyle = .pageSheet
        
        if let sheet = likeListVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.preferredCornerRadius = 20
        }
        
        present(likeListVC, animated: true)
    }
    
    @objc private func didTapMoreButton() {
        calendarDetailView.expandContent()
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
        
        // 옵티미스틱 업데이트
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

extension CalendarDetailViewController: RecordOOTDViewControllerDelegate {
    func didUpdateHistory() {
        // 히스토리 데이터 다시 불러오기
        guard let viewModel = viewModel else { return }
        let historyId = Int(viewModel.historyId)
        
        historyService.historyDetail(historyId: historyId) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.viewModel = CalendarDetailViewModel(data: response)
                    self?.updateView()
                }
            case .failure(let error):
                print("Failed to refresh history: \(error)")
            }
        }
    }
}


extension CalendarDetailViewController: CustomActionSheetDelegate {
    func didDeleteHistory() {
        print("didDeleteHistory called")
        print("navigationController: \(String(describing: navigationController))")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                print("self is nil")
                return
            }
            
            if let nav = self.navigationController {
                print("Attempting to pop view controller")
                nav.popViewController(animated: true)
            } else {
                print("navigationController is nil")
                // navigationController가 nil인 경우 dismiss를 시도
                self.dismiss(animated: true)
            }
        }
    }
    
    // 데이터 확인
    func didTapEdit() {

        guard let viewModel = viewModel else {
            print("viewModel이 없음")
            return
        }
        
        print("전달할 데이터 췤")
        print("닉네임: \(viewModel.name)")
        print("내용: \(viewModel.content)")
        print("해시태그: \(viewModel.hashtags)")
        print("이미지 URL: \(viewModel.images)")
        
        let recordOOTDVC = RecordOOTDViewController()
        recordOOTDVC.delegate = self
        recordOOTDVC.setEditData(viewModel) // 데이터 전달
       
        navigationController?.pushViewController(recordOOTDVC, animated: true)
    }
}

