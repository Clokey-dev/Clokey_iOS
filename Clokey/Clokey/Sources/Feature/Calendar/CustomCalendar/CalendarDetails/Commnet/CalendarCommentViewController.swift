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
}

class CalendarCommentViewController: UIViewController, CommentCellDelegate {
    
    weak var delegate: CalendarCommentDelegate?
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        $0.alpha = 0
    }
    
    private let commentView = CalendarCommentView()
    private var comments: [Comment] = Comment.sampleComments
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
    
    @objc func dismissView() {
        self.dismiss(animated: true)
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
            case .success(_):
                DispatchQueue.main.async {
                    // 이전에 선택된 셀의 선택 상태 해제
                    if let oldIndexPath = self.selectedIndexPath {
                       let oldCell = self.commentView.commentTableView.cellForRow(at:   oldIndexPath) as? CommentCell
                        oldCell?.setSelected(false)
                    }
                    
                    self.selectedIndexPath = nil
                    self.commentView.commentTextField.placeholder = "댓글 달기"
                    self.commentView.commentTextField.text = ""
                    self.selectedCommentId = nil
                   
                    // 댓글 목록 새로고침
                    self.currentPage = 1
                    self.comments = []
                    self.isLastPage = false
                    self.fetchComments()
                }
                
            case .failure(let error):
                print("댓글 작성 실패: \(error)")
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
    
    private func findIndexPath(for commentId: Int64) -> IndexPath? {
        if let index = comments.firstIndex(where: { $0.id == commentId }) {
            return IndexPath(row: index, section: 0)
        }
        return nil
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
                self.delegate?.didUpdateComment(count: self.comments.count)
                // Comment 모델로 변환
                let newComments = response.comments.map { comment in
                    let mainComment = Comment(
                        id: comment.commentId,
                        memberId: comment.memberId,
                        imageUrl: comment.userImageUrl,
                        content: comment.content,
                        parentCommentId: nil
                    )
                    
                    // 대댓글 변환
                    let replies = comment.replyResults.map { reply in
                        Comment(
                            id: reply.commentId,
                            memberId: reply.memberId,
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
                   
                   self.isLastPage = response.isLast
                   self.currentPage += 1
               }
                
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // 모든 셀 swipe 가능
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commentToDelete = comments[indexPath.row]
            
            // 삭제할 댓글과 관련된 모든 인덱스를 찾기
            var indexesToDelete = [IndexPath]()
            indexesToDelete.append(indexPath)
            
            // 만약 메인 댓글이라면, 관련된 대댓글들의 인덱스도 찾기
            if commentToDelete.parentCommentId == nil {
                for (index, comment) in comments.enumerated() {
                    if comment.parentCommentId == commentToDelete.id {
                        indexesToDelete.append(IndexPath(row: index, section: 0))
                    }
                }
            }
            
            // 정렬된 인덱스(내림차순)
            let sortedIndexes = indexesToDelete.sorted(by: { $0.row > $1.row })
            
            historyService.historyCommentDelete(commentId: commentToDelete.id) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.delegate?.didDeleteComment()
                    DispatchQueue.main.async {
                        // 내림차순으로 정렬된 인덱스를 사용하여 배열에서 항목들을 제거
                        for indexPath in sortedIndexes {
                            self.comments.remove(at: indexPath.row)
                        }
                        // 테이블뷰에서 해당 행들을 삭제
                        tableView.deleteRows(at: sortedIndexes, with: .fade)
                    }
                    
                case .failure(let error):
                    print("댓글 삭제 실패: \(error)")
                }
            }
        }
    }
}
