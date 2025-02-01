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
    let HashtagTextField: CustomButtonTextField = {
        let textField = CustomButtonTextField(title: "", placeholder: "#해시태그", isRequired: false)
        textField.setButtonText("입력")
        textField.setButtonEnabled(true)
        textField.setButtonFontSize(16)
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
    
    private let publicButton = ToggleButton(title: "공개")
    private let privateButton = ToggleButton(title: "비공개")
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        textAddBox.delegate = self
        HashtagTextField.delegate = self
        
        HashtagTextField.customButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(textAddBox)
        addSubview(HashtagTextField)
                
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        addSubview(publicLabel)
        addSubview(publicButton)
        addSubview(privateButton)

        
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
    }
    
    // 해시태그 텍스트 추가 메서드
    func addHashtag(_ hashtag: String) {
        let tagView = createTagView(with: hashtag)
        stackView.addArrangedSubview(tagView)
        
        // 해시태그 리스트에 추가
        hashtags.append(hashtag)

        // 스크롤 뷰의 콘텐츠 크기 재계산
        let contentWidth = stackView.arrangedSubviews.reduce(0) { partialWidth, view in
            partialWidth + view.frame.width + stackView.spacing
        }

        scrollView.contentSize = CGSize(width: contentWidth, height: scrollView.frame.height)

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
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
        let contentWidth = stackView.arrangedSubviews.reduce(0) { partialWidth, view in
            partialWidth + view.frame.width + stackView.spacing
        }
        scrollView.contentSize = CGSize(width: contentWidth, height: scrollView.frame.height)

        // 스택뷰가 비어있는지 확인하고 높이 조정
        DispatchQueue.main.async {
            self.scrollView.snp.updateConstraints {
                $0.height.equalTo(self.stackView.arrangedSubviews.isEmpty ? 0 : 35).priority(.high)
            }
            
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
    
    // 해시태그 텍스트 생성뷰
    private func createTagView(with text: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .mainBrown50
        containerView.layer.cornerRadius = 15
        
        let label = UILabel()
        label.text = text
        label.textColor = .pointOrange800
        label.font = .ptdRegularFont(ofSize: 14)
        label.sizeToFit()
        
        let deleteButton = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 6, weight: .medium)
        deleteButton.setImage(UIImage(systemName: "xmark", withConfiguration: configuration), for: .normal)
        deleteButton.tintColor = .black
       
        // 삭제 버튼에 태그 텍스트를 저장
        deleteButton.accessibilityLabel = text
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
       
        let innerStackView = UIStackView(arrangedSubviews: [label, deleteButton])
        innerStackView.axis = .horizontal
        innerStackView.spacing = 8
        innerStackView.alignment = .center
        
        containerView.addSubview(innerStackView)
        
        // 내부 스택뷰의 제약조건 설정
        innerStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(20)
            $0.leading.trailing.equalToSuperview().inset(10)
        }

        return containerView
    }
    
    private func setupActions() {
        publicButton.addTarget(self, action: #selector(toggleButtons(_:)), for: .touchUpInside)
        privateButton.addTarget(self, action: #selector(toggleButtons(_:)), for: .touchUpInside)
        
        publicButton.isSelected = false
        privateButton.isSelected = false
    
        HashtagTextField.addTarget(self, action: #selector(hashtagTextFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - Actions
    
    // 공개/비공개 버튼
    @objc private func toggleButtons(_ sender: UIButton) {
        guard let sender = sender as? ToggleButton else { return }
        
        publicButton.isSelected = (sender == publicButton)
        privateButton.isSelected = (sender == privateButton)
    }
    
    // 해시태그 입력 버튼
    @objc private func didTapActionButton() {
        guard let text = HashtagTextField.text, !text.isEmpty else { return }
        
        // #이 없으면 추가
        let hashtag = text.hasPrefix("#") ? text : "#\(text)"
        addHashtag(hashtag)
        delegate?.contentInputView(self, didAddHashtag: hashtag)
        
        // 텍스트 필드 초기화
        HashtagTextField.text = ""
        HashtagTextField.customButton.isEnabled = false
    }
    
    // 해시태그 텍스트 필드에서 입력 활성화/비활성화
    @objc private func hashtagTextFieldDidChange(_ textField: UITextField) {
        HashtagTextField.customButton.isEnabled = !(textField.text?.isEmpty ?? true)
    }
    
    // 키보드 설정
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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

