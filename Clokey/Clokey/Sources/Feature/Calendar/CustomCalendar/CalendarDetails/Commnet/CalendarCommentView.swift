//
//  CalendarCommentView.swift
//  Clokey
//
//  Created by 황상환 on 2/1/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

class CalendarCommentView: UIView, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
     var comments: [Comment] = [] {
         didSet {
             commentTableView.reloadData()
         }
     }
     
     weak var viewController: CalendarCommentViewController? {
         didSet {
             commentTableView.dataSource = self
             commentTableView.delegate = self
         }
     }
    
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
        $0.layer.cornerRadius = 15
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.pointOrange800.cgColor
        $0.clipsToBounds = true
        
        // 왼쪽 패딩 추가
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        $0.leftView = leftPaddingView
        $0.leftViewMode = .always
    }
    
    private let sendButton = UIButton().then {
        $0.setImage(UIImage(named: "comment_enter"), for: .normal)
        $0.tintColor = .orange
    }
   
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
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        commentTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(inputContainerView.snp.top)
        }
        
        inputContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(40)
        }
        
        commentTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-8)
            $0.height.equalTo(38)
            $0.centerY.equalToSuperview()
        }
        
        sendButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(38)
            $0.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
       closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
       sendButton.addTarget(viewController, action: #selector(CalendarCommentViewController.didTapSend), for: .touchUpInside)
    }
    
    // MARK: - Method
    // 댓글창이 키보드에 따라 업다운
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 키보드 내리기 제스처 설정
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapClose() {
        if let viewController = self.findViewController() as? CalendarCommentViewController {
            viewController.dismissView()
        }
    }
    
    @objc private func didTapSend() {
        viewController?.didTapSend()
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
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 터치된 뷰가 입력 컨테이너나 그 하위 뷰인 경우 제스처를 무시
        if touch.view?.isDescendant(of: inputContainerView) ?? false {
            return false
        }
        // 터치된 뷰가 전송 버튼인 경우 제스처를 무시
        if touch.view?.isDescendant(of: sendButton) ?? false {
            return false
        }
        return true
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
            isLastReply: comment.parentCommentId == nil,
            commentId: comment.id
        )
        
        cell.delegate = viewController
        
        // 대댓글 들여쓰기 처리
        if isReply {
            cell.mainStackView.snp.remakeConstraints {
                $0.top.equalToSuperview()
                $0.trailing.equalToSuperview().inset(12)
                $0.bottom.equalToSuperview().inset(20)
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
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
