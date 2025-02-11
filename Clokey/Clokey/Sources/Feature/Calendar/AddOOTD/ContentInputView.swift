//
//  ContentInputView.swift
//  Clokey
//
//  Created by 황상환 on 1/22/25.
//

import Foundation
import UIKit
import SnapKit
import Then


// 해시태그 추가/삭제
protocol ContentInputViewDelegate: AnyObject {
    func contentInputView(_ view: ContentInputView, didAddHashtag hashtag: String)
    func contentInputView(_ view: ContentInputView, didRemoveHashtag: String)
    func contentInputView(_ view: ContentInputView, shouldMoveWithKeyboard offset: CGFloat)
    func contentInputView(_ view: ContentInputView, didUpdateText text: String)
    func contentInputView(_ view: ContentInputView, didTogglePublic isPublic: Bool)
}

class ContentInputView: UIView, UITextFieldDelegate {
    
    weak var delegate: ContentInputViewDelegate?
    private var hashtags: [String] = []
    
    // MARK: - UI Components
    
    // big textView
    let textAddBox = UITextView().then {
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.mainBrown600.cgColor
        $0.backgroundColor = .white
        $0.font = .systemFont(ofSize: 16)
        $0.textContainerInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        $0.text = "텍스트를 입력하세요"
        $0.textColor = .placeholderText
        $0.isScrollEnabled = true
    }
    
    // 해시태그 입력 텍스트 필드
    let HashtagTextField: CustomTextField = {
        let textField = CustomTextField(title: "", placeholder: "#해시태그", isRequired: false)
        textField.setTextFieldFontSize(16)
        return textField
    }()
    
    // 해시태그 스택 뷰
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .leading
        $0.distribution = .fill
    }
    
    // 해시태그 스크롤 뷰
    private let scrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = true // 스크롤 가능하게 설정
        $0.isScrollEnabled = true
        $0.alwaysBounceHorizontal = true
        $0.alwaysBounceVertical = false // 수직 스크롤은 비활성화
    }
    
    // 공개 범위 라벨
    private let publicLabel = UILabel().then {
        $0.text = "공개 범위"
        $0.textColor = UIColor.black
        $0.font = .ptdMediumFont(ofSize: 20)
    }
    
    let publicButton = ToggleButton(title: "공개")
    let privateButton = ToggleButton(title: "비공개")
    
    private let publicInfoLabel = UILabel().then {
        let text = "* 비공개 계정은 기록을 공개해도 다른 사용자에게 노출되지 않습니다.\n이후 계정을 공개로 전환할 시, 해당 기록은 전체 공개 상태가 됩니다!"
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.ptdRegularFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        
        $0.attributedText = NSAttributedString(string: text, attributes: attributes)
        $0.numberOfLines = 0
    }
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        textAddBox.delegate = self
        
        setupKeyboardNotifications()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupKeyboardNotifications()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(textAddBox)
        addSubview(HashtagTextField)
        HashtagTextField.textField.delegate = self
        
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        addSubview(publicLabel)
        addSubview(publicButton)
        addSubview(privateButton)
        addSubview(publicInfoLabel)

        
        setupConstraints()
        setupActions()
    }
    
    private func setupConstraints() {
        
        // 설명 텍스트 뷰
        textAddBox.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(125)
        }
        
        // 해시태그 텍스트 필드 + 입력 버튼
        HashtagTextField.snp.makeConstraints {
            $0.top.equalTo(textAddBox.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(42)
        }
        
        // 해시태그 스크롤 뷰
        scrollView.snp.makeConstraints {
            $0.top.equalTo(HashtagTextField.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(0).priority(.high)
        }
        
        // 해시태그 스택
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
        
        // 공개 범위 라벨
        publicLabel.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        // 공개 버튼
        publicButton.snp.makeConstraints {
            $0.top.equalTo(publicLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(55)
            $0.height.equalTo(30)
        }
        
        // 비공개 버튼
        privateButton.snp.makeConstraints {
            $0.top.equalTo(publicButton)
            $0.leading.equalTo(publicButton.snp.trailing).offset(8)
            $0.width.equalTo(67)
            $0.height.equalTo(30)
        }
        
        // 공개 범위 설명
        publicInfoLabel.snp.makeConstraints {
            $0.top.equalTo(publicButton.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview()
        }
    }
    
    // 해시태그 텍스트 추가 메서드
    func addHashtag(_ hashtag: String) {
        let tagView = createTagView(with: hashtag)
        stackView.addArrangedSubview(tagView)
        
        // 해시태그 리스트에 추가
        hashtags.append(hashtag)
        
        DispatchQueue.main.async {
            self.updateScrollViewContentSize()
        }
    }

    // 해시태그 스크롤 뷰에서 각 텍스트 삭제
    func removeHashtag(_ hashtag: String) {
        for view in stackView.arrangedSubviews {
            if let label = view.subviews.first(where: { $0 is UILabel }) as? UILabel,
                label.text == hashtag {
                
                // 해시태그 삭제 디버깅
                print("Removing hashtag view: \(hashtag)")
                
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
                
                if let index = hashtags.firstIndex(of: hashtag) {
                    hashtags.remove(at: index)
                }
                
                updateScrollViewContentSize()
                
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }

                print("Current hashtags: \(hashtags)")
                print("Remaining views in stackView: \(stackView.arrangedSubviews.count)")
                break
            }
        }
    }
    
    // 해시태그 스크롤 뷰에 따라 heigt 값 유동적
    private func updateScrollViewContentSize() {
        stackView.layoutIfNeeded()

        var totalWidth: CGFloat = 0
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            totalWidth += view.frame.width
            if index < stackView.arrangedSubviews.count - 1 {
                totalWidth += stackView.spacing
            }
        }

        scrollView.contentSize = CGSize(width: max(totalWidth, scrollView.frame.width), height: scrollView.frame.height)

        DispatchQueue.main.async {
            self.scrollView.snp.updateConstraints {
                $0.height.equalTo(self.stackView.arrangedSubviews.isEmpty ? 0 : 35).priority(.high)
            }

            // 필요할 때만 layoutIfNeeded 호출
            if !self.stackView.arrangedSubviews.isEmpty {
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            }
        }
    }

    
    // 해시태그 텍스트 생성뷰
    private func createTagView(with text: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .mainBrown50
        containerView.layer.cornerRadius = 10
        
        let label = UILabel()
        label.text = text
        label.textColor = .pointOrange800
        label.font = .ptdRegularFont(ofSize: 14)
        label.sizeToFit()

        let deleteButton = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 8, weight: .medium)
        deleteButton.setImage(UIImage(systemName: "xmark", withConfiguration: configuration), for: .normal)
        deleteButton.tintColor = .black
        deleteButton.accessibilityLabel = text
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)

        // 스택뷰에 라벨과 x버튼
        let innerStackView = UIStackView(arrangedSubviews: [label, deleteButton])
        innerStackView.axis = .horizontal
        innerStackView.spacing = 4
        innerStackView.alignment = .top

        containerView.addSubview(innerStackView)

        // 내부 스택뷰의 제약조건 설정
        innerStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().inset(8)
        }

        // deleteButton top
        deleteButton.snp.makeConstraints {
            $0.width.height.equalTo(12)
        }

        return containerView
    }
    
    func getTextContent() -> String {
        return textAddBox.text
    }

    func isPublic() -> Bool {
        return publicButton.isSelected
    }

    // 액션 셋업
    private func setupActions() {
        publicButton.addTarget(self, action: #selector(toggleButtons(_:)), for: .touchUpInside)
        privateButton.addTarget(self, action: #selector(toggleButtons(_:)), for: .touchUpInside)
        
        publicButton.isSelected = true
        privateButton.isSelected = false

    }
    
    // 키보드 자동조정
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 해시태그 텍스트필드 엔터 처리
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            if let text = textField.text, !text.isEmpty {
                let hashtag = text.hasPrefix("#") ? text : "#\(text)"
                addHashtag(hashtag)
                delegate?.contentInputView(self, didAddHashtag: hashtag)
                textField.text = ""
            }
        }
        return true
    }
    
    // MARK: - Actions
    
    // 공개/비공개 버튼
    @objc private func toggleButtons(_ sender: UIButton) {
        guard let sender = sender as? ToggleButton else { return }
        
        publicButton.isSelected = (sender == publicButton)
        privateButton.isSelected = (sender == privateButton)
        
        // 델리게이트 호출 추가
        delegate?.contentInputView(self, didTogglePublic: publicButton.isSelected)
    }
    
    // 키보드 설정
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            let hashtag = text.hasPrefix("#") ? text : "#\(text)"
            addHashtag(hashtag)
            delegate?.contentInputView(self, didAddHashtag: hashtag)
            textField.text = ""
        }
        return false
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardHeight = keyboardFrame.cgRectValue.height
        let keyboardY = UIScreen.main.bounds.height - keyboardHeight

        // 현재 활성화된 필드 찾기
        guard let activeField = getActiveTextInput() else { return }

        // 활성화된 필드의 전체 화면 기준 위치
        let fieldFrame = activeField.convert(activeField.bounds, to: nil)
        let fieldBottom = fieldFrame.origin.y + fieldFrame.size.height

        // 겹치는 부분 계산
        let overlap = fieldBottom - keyboardY + 10 // 여유공간
        let offset = overlap > 0 ? -overlap : 0

        // 키보드 애니메이션 적용
        UIView.animate(withDuration: 0.3, animations: {
            if let scrollView = self.superview as? UIScrollView {
                scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y - offset)
            } else {
                self.superview?.transform = CGAffineTransform(translationX: 0, y: offset)
            }
        })
    }

    // 현재 포커스된 UITextView 또는 UITextField 찾기
    private func getActiveTextInput() -> UIView? {
        if textAddBox.isFirstResponder {
            return textAddBox
        } else if HashtagTextField.textField.isFirstResponder {
            return HashtagTextField
        }
        return nil
    }

    // 키보드 가려지면서 뷰 원상복귀
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3, animations: {
            if let scrollView = self.superview as? UIScrollView {
                scrollView.setContentOffset(.zero, animated: true)
            } else {
                self.superview?.transform = .identity
            }
        })
    }
    
    // 해시테그 삭제
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        guard let hashtagText = sender.accessibilityLabel else { return }
        
        // 스택뷰에서 해당하는 컨테이너 뷰를 찾아 제거
        if let containerView = sender.superview?.superview {
            UIView.animate(withDuration: 0.3, animations: {
                containerView.alpha = 0
            }) { _ in
                self.stackView.removeArrangedSubview(containerView)
                containerView.removeFromSuperview()
                
                // 해시태그 배열에서도 제거
                if let index = self.hashtags.firstIndex(of: hashtagText) {
                    self.hashtags.remove(at: index)
                }
                
                // 스크롤뷰 컨텐츠 크기 업데이트
                self.updateScrollViewContentSize()
                
                // 델리게이트 호출
                self.delegate?.contentInputView(self, didRemoveHashtag: hashtagText)
            }
        }
    }
}

// MARK: - UITextViewDelegate

// UITextView 상태 처리 코드
// placeholder 처리
extension ContentInputView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "텍스트를 입력하세요"
            textView.textColor = .placeholderText
        }
        // 델리게이트 호출 추가
        delegate?.contentInputView(self, didUpdateText: textView.text)
    }
}

// MARK: - ToggleButton
// 공개/비공개 토글 고통 버튼 구현
class ToggleButton: UIButton {
    override var isSelected: Bool {
        didSet {
            updateStyle()
        }
    }
    
    convenience init(title: String) {
        self.init(frame: .zero)
        setup(title: title)
    }
    
    private func setup(title: String) {
        setTitle(title, for: .normal)
        layer.cornerRadius = 10
        layer.borderWidth = 1
        
        titleLabel?.font = .ptdMediumFont(ofSize: 14)
        updateStyle()
    }
    
    private func updateStyle() {
        backgroundColor = isSelected ? .mainBrown800 : .white
        setTitleColor(isSelected ? .white : .mainBrown800, for: .normal)
        layer.borderColor = isSelected ? UIColor.mainBrown800.cgColor : UIColor.mainBrown200.cgColor
    }
}

