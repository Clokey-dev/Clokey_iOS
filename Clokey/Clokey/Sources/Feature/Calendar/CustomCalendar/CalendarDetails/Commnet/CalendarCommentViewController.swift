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

class CalendarCommentViewController: UIViewController, CommentCellDelegate {
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        $0.alpha = 0
    }
    
    private let commentView = CalendarCommentView()
    private var comments: [Comment] = Comment.sampleComments
    private var selectedCommentId: Int? = nil // 대댓글 대상 ID
    
    // API
    // 페이지네이션 관련 변수들
    private var currentPage = 1
    private var isLastPage = false
    private var isFetching = false
    
    // 서비스 및 히스토리 ID
    private let historyService = HistoryService()
//    private let historyId: Int
    // 예시
    let historyId = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        organizeComments()
        fetchComments()
    }

    private func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(backgroundView)
        view.addSubview(commentView)
        
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        commentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(view.frame.height * 0.8)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        backgroundView.addGestureRecognizer(tapGesture)
        
        UIView.animate(withDuration: 0.3) { self.backgroundView.alpha = 1 }
        
        commentView.commentTableView.dataSource = self
        commentView.commentTableView.delegate = self
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
    
    @objc private func dismissView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    
    @objc private func didTapSend() {
        if let text = commentView.commentTextField.text, !text.isEmpty {
            let newComment = Comment(
                id: comments.count + 1,
                memberId: 999,
                imageUrl: "https://example.com/images/default.jpg",
                content: text,
                parentCommentId: selectedCommentId  // 선택된 댓글 ID 사용
            )
            
            comments.append(newComment)
            organizeComments()  // 댓글 재정렬
            commentView.commentTableView.reloadData()
            commentView.commentTextField.text = ""
            selectedCommentId = nil  // 선택 초기화
        }
    }
    
    // MARK: - CommentCellDelegate 구현
    func didTapReplyButton(commentId: Int) {
        selectedCommentId = commentId
        commentView.commentTextField.becomeFirstResponder()
    }
    
    // MARK: - API
    private func fetchComments() {
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
                        memberId: comment.memberId,
                        imageUrl: comment.ImageUrl,
                        content: comment.content,
                        parentCommentId: nil
                    )
                    
                    // 대댓글 변환
                    let replies = comment.replies.map { reply in
                        Comment(
                            id: reply.commentId,
                            memberId: reply.memberId,
                            imageUrl: reply.ImageUrl,
                            content: reply.content,
                            parentCommentId: comment.commentId
                        )
                    }
                    
                    return [mainComment] + replies
                }.flatMap { $0 }
                
                // 첫 페이지면 교체, 아니면 추가
                if self.currentPage == 1 {
                    self.comments = newComments
                } else {
                    self.comments.append(contentsOf: newComments)
                }
                
                self.isLastPage = response.isLast
                self.currentPage += 1
                self.commentView.commentTableView.reloadData()
                
            case .failure(let error):
                print("댓글 조회 실패: \(error)")
                // 에러 처리 (필요시 alert 표시)
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
}

extension CalendarCommentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
        
        let comment = comments[indexPath.row]
        let isReply = comment.parentCommentId != nil

        cell.configure(
            profileImage: comment.imageUrl,
            name: "닉네임",
            comment: comment.content,
            isLastReply: isLastReply(comment: comment),
            commentId: comment.id
        )

        cell.delegate = self
        
        // 대댓글 들여쓰기 처리
        if isReply {
            cell.mainStackView.snp.remakeConstraints { make in
                make.top.bottom.trailing.equalToSuperview().inset(12)
                make.leading.equalToSuperview().inset(40)
            }
        } else {
            cell.mainStackView.snp.remakeConstraints { make in
                make.edges.equalToSuperview().inset(12)
            }
        }
        
        return cell
    }

    private func isLastReply(comment: Comment) -> Bool {
        return !comments.contains { $0.parentCommentId == comment.id }
    }
}
