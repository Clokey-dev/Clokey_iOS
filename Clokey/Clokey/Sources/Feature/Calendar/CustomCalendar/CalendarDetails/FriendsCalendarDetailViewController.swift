//
//  FriendsCalendarDetailViewController.swift
//  Clokey
//
//  Created by 황상환 on 2/19/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class FriendsCalendarDetailViewController: UIViewController, UIGestureRecognizerDelegate, UITextViewDelegate {

    // MARK: - Properties
    private let calendarDetailView = CalendarDetailView()
    private var viewModel: CalendarDetailViewModel?

    private var detailData: HistoryDetailResponseDTO?
    
    // 서버 API Service
    private let historyService = HistoryService()
    private let notificationService = NotificationService()
    
    let navBarManager = NavigationBarManager()
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        setupUI()
        setupNavigationBar()
        updateView()
        navBarManager.setupWhiteNavigationBar(for: navigationController)

        
        calendarDetailView.likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        
        calendarDetailView.plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        
        calendarDetailView.clothesIconButton.addTarget(self, action: #selector(didTapClothesIconButton), for: .touchUpInside)
        
        calendarDetailView.moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
        
        // 댓글 버튼에 직접 target-action 추가
        calendarDetailView.commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        
        // 댓글 컨테이너에 gesture recognizer 추가
        let commentTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCommentButton))
        calendarDetailView.commentContainerView.addGestureRecognizer(commentTapGesture)

        calendarDetailView.commentContainerView.addGestureRecognizer(commentTapGesture)
        
        // likeLabel에 탭 제스처 추가
        let likeTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLikeLabel))
        calendarDetailView.likeLabel.isUserInteractionEnabled = true
        calendarDetailView.likeLabel.addGestureRecognizer(likeTapGesture)
        
        // 사용자 프로필 탭 제스쳐 추가
        calendarDetailView.addProfileTapAction(target: self, action: #selector(didTapProfile))

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        
       
       
        // 델리게이트 할당
        calendarDetailView.hashtagsTextView.delegate = self
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
        
        calendarDetailView.shouldHidePlusButton = false
        calendarDetailView.shouldHidelockCheckImageView = true
        
        calendarDetailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = .white

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
    // 댓글 업데이트를 위한 API
    private func refreshHistoryDetail() {
        guard let viewModel = viewModel else { return }
        let historyId = Int(viewModel.historyId)

        print("댓글 변경 감지 → 최신 히스토리 데이터 가져오는 중...")

        historyService.historyDetail(historyId: historyId) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.viewModel = CalendarDetailViewModel(data: response)
                    self?.updateView()
                    print("최신 댓글 데이터 업데이트 완료!")
                }
            case .failure(let error):
                print("댓글 데이터 업데이트 실패: \(error)")
            }
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
        
        let commentVC = Clokey.CalendarCommentViewController(historyId: historyId)
        commentVC.delegate = self
        commentVC.modalPresentationStyle = .pageSheet

        // 모달 닫힘 감지
        commentVC.presentationController?.delegate = self

        if let sheet = commentVC.sheetPresentationController {
            sheet.detents = [UISheetPresentationController.Detent.medium(),
                             UISheetPresentationController.Detent.large()]
            sheet.preferredCornerRadius = 20
        }

        present(commentVC, animated: true)
    }
    
    // 좋아요 누른 사람 뷰
    @objc private func didTapLikeLabel() {
        guard let viewModel = viewModel else { return }
        let historyId = Int(viewModel.historyId)
        
        let likeListVC = LikeListViewController(historyId: historyId)
        likeListVC.delegate = self  // delegate 설정 추가
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
    @objc private func didTapProfile() {
        guard let clokeyId = viewModel?.clokeyId, !clokeyId.isEmpty else {
            print("클로키 아이디가 없습니다.")
            return
        }
        let followProfileVC = FollowProfileViewController(followId: clokeyId)
        navigationController?.pushViewController(followProfileVC, animated: true)
    }
    
    // 신고/차단 버튼
    @objc private func didTapPlusButton() {
        guard let viewModel = viewModel else { return }
        let historyId = Int(viewModel.historyId)
        
        let actionSheet = FriendsActionSheetViewController(historyId: historyId)
        actionSheet.delegate = self
        actionSheet.modalPresentationStyle = .overFullScreen
        present(actionSheet, animated: false)
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
                // 좋아요 누르면 true일때 알림 전송
                if response.liked {
                    self.sendLikeNotification(historyId: historyId)
                }
                
            case .failure(let error):
                print("좋아요 변경 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // 좋아요 알림
    private func sendLikeNotification(historyId: Int) {
        notificationService.notificationLove(historyId: Int64(historyId)) { result in
            switch result {
            case .success:
                print("좋아요 알림 전송 성공")
            case .failure(let error):
                print("좋아요 알림 전송 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // 댓글에서 프로필 화면으로
    func showProfile(for clokeyId: String) {
        let followProfileVC = FollowProfileViewController(followId: clokeyId)
        navigationController?.pushViewController(followProfileVC, animated: true)
    }
}

extension FriendsCalendarDetailViewController: LikeListViewControllerDelegate {
    func likeListViewController(_ viewController: LikeListViewController, didSelectProfileWith clokeyId: String) {
        // 모달을 닫고 프로필 화면으로 이동
        viewController.dismiss(animated: true) { [weak self] in
            self?.showProfile(for: clokeyId)
        }
    }
}

extension FriendsCalendarDetailViewController: CalendarCommentDelegate {
    func commentViewController(_ viewController: CalendarCommentViewController, didRequestReportForComment commentId: Int64) {
        let commentReportVC = CustomReportViewController(commentId: commentId)
        self.navigationController?.pushViewController(commentReportVC, animated: true)
    }
    
    func CalendarCommentViewController(_ viewController: CalendarCommentViewController, didSelectProfileWith clokeyId: String) {
        // 모달을 닫고 프로필 화면으로 이동
        viewController.dismiss(animated: true) { [weak self] in
            self?.showProfile(for: clokeyId)
        }
    }
    
    func didUpdateComment(count: Int) {
        print("댓글 개수 변경 감지! 새로운 댓글 개수: \(count)")

        // 댓글 개수를 UI에 반영 (라벨 업데이트)
        calendarDetailView.commentButton.setTitle("\(count)", for: .normal)

        // 최신 데이터를 가져오기 위해 API 호출
        refreshHistoryDetail()
    }

    func didDeleteComment() {
        print("댓글 삭제 감지!")
        refreshHistoryDetail()
    }
}

extension FriendsCalendarDetailViewController: FriendsActionSheetDelegate {
    func didReportUser() {
        guard let viewModel = viewModel else { return }
        let historyId = Int(viewModel.historyId)
        
        let historyIdInt64 = Int64(historyId)
        let reportVC = CustomReportViewController(historyId: historyIdInt64)
        reportVC.historyId = historyIdInt64
        navigationController?.pushViewController(reportVC, animated: true)
    }

    // 차단하기
    func didBlockUser() {
        guard let viewModel = viewModel else { return }
        let clokeyId = viewModel.clokeyId

        print("\(clokeyId) 는 ?? ")

        // 액션 시트 닫기
        dismiss(animated: false) { [weak self] in
            // Alert 표시
            let alert = UIAlertController(
                title: "사용자 차단",
                message: "정말 이 사용자를 차단하시겠습니까?",
                preferredStyle: .alert
            )

            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let confirmAction = UIAlertAction(title: "차단", style: .destructive) { _ in
                self?.blockMember(clokeyId: clokeyId)
            }

            alert.addAction(cancelAction)
            alert.addAction(confirmAction)

            // 현재 뷰 컨트롤러에서 Alert 띄우기
            if let topViewController = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow })?
                .rootViewController {
                topViewController.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // 차단 API
    private func blockMember(clokeyId: String) {
        let membersService = MembersService()
        
        membersService.blockOrUnblock(clokeyId: clokeyId) { result in
            switch result {
            case .success:
                print("\(clokeyId) 차단 성공")
                DispatchQueue.main.async {
                    if let navigationController = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .flatMap({ $0.windows })
                        .first(where: { $0.isKeyWindow })?
                        .rootViewController as? UINavigationController {
                        
                        navigationController.popViewController(animated: true)
                    } else {
                        print("네비게이션 컨트롤러를 찾을 수 없음")
                    }
                }
            case .failure(let error):
                print("차단 실패: \(error.localizedDescription)")
            }
        }
    }
}

// 모달 닫힘 감지
extension FriendsCalendarDetailViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("FriendsCalendarCommentViewController가 닫혔습니다!")

        refreshHistoryDetail()
    }
}

// UITextViewDelegate
extension FriendsCalendarDetailViewController {
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "hashtag" {
            // URL.host에는 '#' 제거한 값이 들어갑니다.
            let tappedHashtag = URL.host?.removingPercentEncoding ?? ""
            
            // 최근 검색어 목록에 추가 (여기서는 '#' 없이 추가됩니다)
            let searchManager = SearchManager()
            searchManager.addSearchKeyword(tappedHashtag)
            
            // 해시태그 검색 화면으로 이동
            let searchResultVC = SearchResultViewController(query: tappedHashtag,
                                                            results: [],
                                                            initialTabIsHashtag: true)
            navigationController?.pushViewController(searchResultVC, animated: true)
            return false // 기본 링크 동작 방지
        }
        return true
    }
}
