//
//  CalendarCommentView.swift
//  Clokey
//
//  Created by 황상환 on 2/1/25.
//

import UIKit
import SnapKit
import Then

class CalendarCommentView: UIView {
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.text = "댓글"
        $0.font = .boldSystemFont(ofSize: 18)
        $0.textAlignment = .center
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .black
    }
    
    let commentTableView = UITableView().then {
        $0.register(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
        $0.separatorStyle = .none
    }
    
    private let inputContainerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    let commentTextField = UITextField().then {
        $0.placeholder = "댓글 달기"
        $0.borderStyle = .roundedRect
    }
    
    private let sendButton = UIButton().then {
        $0.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        $0.tintColor = .orange
    }
    
    // MARK: - Properties
//    var comments: [String] = [] // 댓글 데이터를 저장할 배열
    var comments: [Comment] = Comment.sampleComments // 예제 데이터 추가

    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
        setupKeyboardObservers()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        organizeComments()
        
        addSubview(titleLabel)
        addSubview(closeButton)
        addSubview(commentTableView)
        addSubview(inputContainerView)
        
        inputContainerView.addSubview(commentTextField)
        inputContainerView.addSubview(sendButton)
        
        setupConstraints()
        
        commentTableView.dataSource = self
        commentTableView.delegate = self
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        commentTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(inputContainerView.snp.top)
        }
        
        inputContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(50)
        }
        
        commentTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-8)
            $0.height.equalTo(44)
            $0.centerY.equalToSuperview()
        }

        
        sendButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
    
    // 댓글 정렬
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
    
    // MARK: - Method
    // 댓글창이 키보드에 따라 업다운
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    // 키보드 내리기
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
    }

    
    // MARK: - Setup Actions
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
    }
    
    @objc private func didTapClose() {
        self.removeFromSuperview()
    }
    
    @objc private func didTapSend() {
        if let text = commentTextField.text, !text.isEmpty {
            let newComment = Comment(
                id: comments.count + 1,
                memberId: 999,
                imageUrl: "https://example.com/images/default.jpg",
                content: text,
                parentCommentId: nil
            )

            comments.append(newComment)
            organizeComments() // 댓글 추가 후 재정렬
            commentTableView.reloadData()
            commentTextField.text = ""
        }
    }

    
    // 키보드 올릴 때
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            let safeAreaBottom = safeAreaInsets.bottom
            let suggestionBarHeight: CGFloat = 40
            let totalKeyboardHeight = keyboardHeight + suggestionBarHeight

            inputContainerView.snp.remakeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview().inset(totalKeyboardHeight - safeAreaBottom)
                $0.height.equalTo(50)
            }
            UIView.animate(withDuration: 0.3) { self.layoutIfNeeded() }
        }
    }

    // 키보드 내릴때 댓글창 원래대로
    @objc private func keyboardWillHide(_ notification: Notification) {
        inputContainerView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(50)
        }
        UIView.animate(withDuration: 0.3) { self.layoutIfNeeded() }
    }
    
    // 키보드 내리기
    @objc private func dismissKeyboard() {
        self.endEditing(true)
    }


}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CalendarCommentView: UITableViewDataSource, UITableViewDelegate {
    
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

        // 대댓글이면 들여쓰기 적용
        if isReply {
            cell.contentStackView.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(40)
            }
        }

        return cell
    }

    private func isLastReply(comment: Comment) -> Bool {
        // 부모 댓글(일반 댓글)인 경우에만 답글 달기 버튼 표시
        return comment.parentCommentId == nil
    }
}
