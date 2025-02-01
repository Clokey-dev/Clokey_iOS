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
    private var detailData: HistoryDetailResponseDTO?
    private let historyService = HistoryService()
    
    // 임시 historyId - 서버에게 추가로 요청해야함.
    private let historyId = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if let detailData = detailData {
            calendarDetailView.configure(with: detailData) // UI 업데이트
        }
        
        calendarDetailView.likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        calendarDetailView.commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)

    }

    func setDetailData(_ data: HistoryDetailResponseDTO) {
        self.detailData = data
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(calendarDetailView)
        
        calendarDetailView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Action
    
    // 좋아요 버튼
    @objc private func didTapLikeButton() {
//        guard let detailData = detailData else { return }
        
        fetchToggleLike(historyId: historyId, isLiked: !detailData!.isLiked)
    }
    
    // 댓글뷰
    @objc private func didTapCommentButton() {
        let commentVC = CalendarCommentViewController()
        commentVC.modalPresentationStyle = .overFullScreen 
        present(commentVC, animated: false)
    }
    
    // MARK: - Method
    
    // 좋아요 토글 API
    private func fetchToggleLike(historyId: Int, isLiked: Bool) {
        let request = HistoryLikeRequestDTO(historyId: "\(historyId)", isLiked: isLiked)
        
        historyService.historyLike(data: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                print("좋아요 변경 성공: \(response)")
                
                // 새로운 값으로 UI 업데이트
                DispatchQueue.main.async {
                    self.calendarDetailView.updateLikeState(isLiked: response.isLiked, likeCount: response.likeCount)
                }
                
            case .failure(let error):
                print("좋아요 변경 실패: \(error.localizedDescription)")
            }
        }
    }
}
