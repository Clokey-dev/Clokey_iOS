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
    
    // 댓글 쓰기 버튼 눌렀을 때
    @objc private func didTapSend() {
        guard let text = commentView.commentTextField.text, !text.isEmpty else { return }
        
        let requestDTO = HistoryCommentWriteRequestDTO(
            content: text,
            commentId: nil
        )
        
        historyService.historyCommentWrite(
            historyId: historyId,
            data: requestDTO
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                // 성공시 댓글창 비우고 새로고침
                DispatchQueue.main.async {
                    self.commentView.commentTextField.text = ""
                    self.currentPage = 1 // 페이지 초기화
                    self.comments = [] // 댓글 초기화
                    self.fetchComments() // 댓글 새로 불러오기
                }
                
            case .failure(let error):
                print("댓글 작성 실패: \(error)")
                // 에러 처리
            }
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
            isLastReply: comment.parentCommentId == nil, // parentCommentId가 nil인 경우에만 답글 달기 표시
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
    
    // swipe 기능 추가
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // 모든 셀 swipe 가능
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commentToDelete = comments[indexPath.row]
            
            historyService.historyCommentDelete(commentId: commentToDelete.id) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self.comments.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                case .failure(let error):
                    print("댓글 삭제 실패: \(error)")
                    // 에러 처리
                }
            }
        }
    }
}
