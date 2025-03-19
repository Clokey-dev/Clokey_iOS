//
//  CalendarCommentViewController.swift
//  Clokey
//
//  Created by 황상환 on 2/2/25.
//

import Foundation
import SnapKit
import Then
import UIKit
import Kingfisher

protocol CalendarCommentDelegate: AnyObject {
    func didUpdateComment(count: Int)  // 댓글 수 업데이트
    func didDeleteComment()  // 댓글 삭제됨
    func CalendarCommentViewController(_ viewController: CalendarCommentViewController, didSelectProfileWith clokeyId: String)
    func commentViewController(_ viewController: CalendarCommentViewController, didRequestReportForComment commentId: Int64)
}

class CalendarCommentViewController: UIViewController, CommentCellDelegate {
    
    weak var delegate: CalendarCommentDelegate?
    weak var reportDelegate: CalendarCommentDelegate?

    private let backgroundView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        $0.alpha = 0
    }
    
    // 블러 효과
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark)).then {
        $0.alpha = 0
    }
    
    private let commentView = CalendarCommentView()
    private var comments: [Comment] = []
    private var selectedCommentId: Int64? = nil // 대댓글 대상 ID
    
    // 선택한 댓글
    private var selectedIndexPath: IndexPath? = nil
    
    // API
    // 페이지네이션 관련 변수들
    private var currentPage = 1
    private var isLastPage = false
    private var isFetching = false
    
    // 서비스 및 히스토리 ID
    private let historyService = HistoryService()
    private let notificationService = NotificationService()
    private let historyId: Int
    
    // MARK: - Init
    
    init(historyId: Int) {
        self.historyId = historyId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        organizeComments()
        fetchComments()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.1) {
            self.backgroundView.alpha = 1
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(backgroundView)
        view.addSubview(commentView)
        
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        commentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        commentView.viewController = self
        commentView.comments = comments
        // 모달 닫기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        backgroundView.addGestureRecognizer(tapGesture)
        
        UIView.animate(withDuration: 0.1) { self.backgroundView.alpha = 1 }
        
        commentView.commentTableView.dataSource = self
        commentView.commentTableView.delegate = self
    }
    
    // 댓글 새로고침
    private func updateComments(_ newComments: [Comment]) {
        comments = newComments
        commentView.comments = comments
    }
    
    // 댓글 정렬 메서드 추가
    private func organizeComments() {
        let mainComments = comments.filter { $0.parentCommentId == nil }
        let replies = comments.filter { $0.parentCommentId != nil }
        
        var organizedComments: [Comment] = []
        
        for mainComment in mainComments {
            organizedComments.append(mainComment)
            let mainCommentReplies = replies.filter { $0.parentCommentId == mainComment.id }
            organizedComments.append(contentsOf: mainCommentReplies)
        }
        
        comments = organizedComments
    }
    
    // 배경 블러처리 On
    private func showBlurBackground() {
        view.addSubview(blurView)
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 1
        }
    }
    // 배경 블러처리 Off
    private func hideBlurBackground() {
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.alpha = 0
        }) { _ in
            self.blurView.removeFromSuperview()
        }
    }
    
    // 삭제 API 함수
    func didTapDelete(commentId: Int64) {
        let alert = UIAlertController(title: "댓글 삭제", message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
            self.historyService.historyCommentDelete(commentId: Int(commentId)) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        // 삭제 후 UI 업데이트
                        self.comments.removeAll { $0.id == commentId || $0.parentCommentId == Int(commentId) }
                        self.commentView.commentTableView.reloadData()

                        // 댓글 개수 업데이트 알림 보내기
                        self.delegate?.didUpdateComment(count: self.comments.count)
                    }
                case .failure(let error):
                    print("삭제 실패: \(error)")
                }
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }


    // 신고 API 함수
    func didTapReport(commentId: Int64) {
        print("신고 버튼 클릭")
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.commentViewController(self, didRequestReportForComment: commentId)
        }
    }
    
    // 차단 API 함수
    func didTapBlock(clokeyId: String) {
        print("\(clokeyId) 입니다요")

        let confirmAlert = UIAlertController(
            title: "사용자 차단",
            message: "정말 이 사용자를 차단하시겠습니까?",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "차단", style: .destructive) { [weak self] _ in
            self?.executeBlockRequest(clokeyId: clokeyId)
        }

        confirmAlert.addAction(cancelAction)
        confirmAlert.addAction(confirmAction)

        present(confirmAlert, animated: true)
    }
    // 차단 API
    private func executeBlockRequest(clokeyId: String) {
        let membersService = MembersService()

        membersService.blockOrUnblock(clokeyId: clokeyId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                print("\(clokeyId) 차단 성공")

                let successAlert = UIAlertController(
                    title: "차단 완료",
                    message: "해당 사용자가 차단되었습니다.",
                    preferredStyle: .alert
                )
                successAlert.addAction(UIAlertAction(title: "확인", style: .default))

                DispatchQueue.main.async {
                    self.present(successAlert, animated: true, completion: nil)
                }

            case .failure(let error):
                print("차단 실패: \(error.localizedDescription)")

                let failureAlert = UIAlertController(
                    title: "차단 실패",
                    message: "차단 요청을 처리하는 중 오류가 발생했습니다.",
                    preferredStyle: .alert
                )
                failureAlert.addAction(UIAlertAction(title: "확인", style: .default))

                DispatchQueue.main.async {
                    self.present(failureAlert, animated: true, completion: nil)
                }
            }
        }
    }

    
    @objc func dismissView() {
        print("X 버튼으로 닫힘!")  // 로그 확인용
        self.dismiss(animated: true) {
            if let presentationController = self.presentationController {
                self.presentationController?.delegate?.presentationControllerDidDismiss?(presentationController)
            }
        }
    }


    // 댓글 쓰기 버튼 눌렀을 때
    @objc func didTapSend() {
        guard let text = commentView.commentTextField.text, !text.isEmpty else { return }

        let requestDTO = HistoryCommentWriteRequestDTO(
            content: text,
            commentId: selectedCommentId
        )

        historyService.historyCommentWrite(
            historyId: historyId,
            data: requestDTO
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    // UI 초기화
                    self.resetCommentInput()

                    // 첫 페이지부터 다시 불러오기
                    self.currentPage = 1
                    self.isLastPage = false
                    self.comments = []
                    self.fetchComments(scrollToTop: true)  // 댓글 목록 새로고침 및 스크롤

                    // 댓글 개수 업데이트 알림 보내기
                    self.delegate?.didUpdateComment(count: self.comments.count)
                }
                
                // 댓글 성공 시 notificationComment 전송
                let commentId = response.commentId
                if self.selectedCommentId == nil {
                    self.sendCommentNotification(historyId: self.historyId, commentId: commentId)
                } else {
                    // 대댓글 기록 주인
                    self.sendCommentNotification(historyId: self.historyId, commentId: commentId)
                    // 댓글에 대댓글 알림
                    self.sendReplyNotification(commentId: self.selectedCommentId!, replyId: commentId)
                }

            case .failure(let error):
                print("댓글 작성 실패: \(error)")
            }
        }
    }


    // 댓글 UI 초기화
    private func resetCommentInput() {
        if let oldIndexPath = selectedIndexPath {
            let oldCell = commentView.commentTableView.cellForRow(at: oldIndexPath) as? CommentCell
            oldCell?.setSelected(false)
        }
        
        selectedIndexPath = nil
        selectedCommentId = nil
        commentView.commentTextField.placeholder = "댓글 달기"
        commentView.commentTextField.text = ""
    }

    // 댓글 알림 전송
    private func sendCommentNotification(historyId: Int, commentId: Int64) {
        notificationService.notificationComment(historyId: Int64(historyId), commentId: commentId) { result in
            switch result {
            case .success:
                print("댓글 알림 전송 성공")
            case .failure(let error):   
                print("댓글 알림 전송 실패: \(error.localizedDescription)")
            }
        }
    }

    // 대댓글 알림 전송
    private func sendReplyNotification(commentId: Int64, replyId: Int64) {
        notificationService.notificationReply(commentId: commentId, replyId: replyId) { result in
            switch result {
            case .success:
                print("대댓글 알림 전송 성공")
            case .failure(let error):
                print("대댓글 알림 전송 실패: \(error.localizedDescription)")
            }
        }
    }

   
    
    // MARK: - CommentCellDelegate 구현
    func didTapReplyButton(commentId: Int64) {
        // 이전에 선택된 셀의 선택 상태 해제
        if let oldIndexPath = selectedIndexPath {
            let oldCell = commentView.commentTableView.cellForRow(at: oldIndexPath) as? CommentCell
            oldCell?.setSelected(false)
        }
        
        // 새로 선택된 셀 찾기 및 선택 상태 설정
        if let newIndexPath = findIndexPath(for: commentId) {
            let newCell = commentView.commentTableView.cellForRow(at: newIndexPath) as? CommentCell
            newCell?.setSelected(true)
            selectedIndexPath = newIndexPath
        }
        
        selectedCommentId = commentId
        commentView.commentTextField.becomeFirstResponder()
        commentView.commentTextField.placeholder = "답글 작성하기"
    }
    
    // 프로필 이미지로 clokeyId 전달
    func didTapProfile(with clokeyId: String) {
        print("프로필 클릭됨: \(clokeyId)")
        DispatchQueue.main.async {
            self.navigateToProfile(clokeyId: clokeyId)
        }
    }
    
    private func findIndexPath(for commentId: Int64) -> IndexPath? {
        if let index = comments.firstIndex(where: { $0.id == commentId }) {
            return IndexPath(row: index, section: 0)
        }
        return nil
    }
    
    // MARK: - API
    private func fetchComments(scrollToTop: Bool = false) {
        guard !isFetching && !isLastPage else { return }
        
        isFetching = true
        
        historyService.historyComment(historyId: historyId, page: currentPage) { [weak self] result in
            guard let self = self else { return }
            
            self.isFetching = false
            
            switch result {
            case .success(let response):
                // Comment 모델로 변환
                let newComments = response.comments.map { comment in
                    let mainComment = Comment(
                        id: comment.commentId,
                        clokeyId: comment.clokeyId,
                        nickName: comment.nickName,
                        imageUrl: comment.userImageUrl,
                        content: comment.content,
                        parentCommentId: nil
                    )
                    
                    // 대댓글 변환
                    let replies = comment.replyResults.map { reply in
                        Comment(
                            id: reply.commentId,
                            clokeyId: reply.clokeyId,
                            nickName: reply.nickName,
                            imageUrl: reply.userImageUrl,
                            content: reply.content,
                            parentCommentId: comment.commentId
                        )
                    }
                    
                    return [mainComment] + replies
                }.flatMap { $0 }
                
                DispatchQueue.main.async {
                    // 첫 페이지면 교체, 아니면 추가
                    if self.currentPage == 1 {
                        self.comments = newComments
                    } else {
                        self.comments += newComments
                    }
                    
                    self.organizeComments()  // 댓글 정렬
                    self.delegate?.didUpdateComment(count: self.comments.count)
                    self.commentView.comments = self.comments  // View 업데이트
                    
                    if scrollToTop && !self.comments.isEmpty {
                        // 스크롤을 맨 위로
                        self.commentView.commentTableView.scrollToRow(
                            at: IndexPath(row: 0, section: 0),
                            at: .top,
                            animated: true
                        )
                    }
                    
                    self.isLastPage = response.isLast
                    self.currentPage += 1
                }
                
            case .failure(let error):
                print("댓글 조회 실패: \(error)")
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
   func scrollViewDidScroll(_ scrollView: UIScrollView) {
       let offsetY = scrollView.contentOffset.y
       let contentHeight = scrollView.contentSize.height
       let height = scrollView.frame.height
       
       // 스크롤이 하단에 도달하면 다음 페이지 요청
       if offsetY > contentHeight - height {
           fetchComments()
       }
   }
    
    // 프로필로 이동
    func handleProfile(clokeyId: String) {
        DispatchQueue.main.async {
            self.navigateToProfile(clokeyId: clokeyId)
        }
    }
    
    private func navigateToProfile(clokeyId: String) {
        delegate?.CalendarCommentViewController(self, didSelectProfileWith: clokeyId)
    }
}

extension CalendarCommentViewController: LikeUserCellDelegate {
    func didTapProfileImage(with clokeyId: String) {
        // 프로파일 이미지 탭 시 handleNotificationFollow 호출
        handleProfile(clokeyId: clokeyId)
    }
}


extension CalendarCommentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
        
        let comment = comments[indexPath.row]
        let isReply = comment.parentCommentId != nil
        let parentComment = comments.first { $0.id == comment.parentCommentId }

        cell.configure(
            profileImage: comment.imageUrl,
            name: comment.nickName,
            comment: comment.content,
            isLastReply: comment.parentCommentId == nil, // parentCommentId가 nil인 경우에만 답글 달기 표시
            commentId: comment.id,
            clokeyId: comment.clokeyId
        )

        cell.delegate = self
        
        // 대댓글 들여쓰기 처리
        if isReply {
            cell.mainStackView.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(10)
                $0.trailing.equalToSuperview().inset(12)
                $0.bottom.equalToSuperview().inset(15)
                $0.leading.equalToSuperview().inset(40)
            }
        } else {
            cell.mainStackView.snp.remakeConstraints {
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview().inset(12)
                $0.top.bottom.equalToSuperview().inset(8)
            }
        }
        
        return cell
    }

    private func isLastReply(comment: Comment) -> Bool {
        return !comments.contains { $0.parentCommentId == comment.id }
    }
}
