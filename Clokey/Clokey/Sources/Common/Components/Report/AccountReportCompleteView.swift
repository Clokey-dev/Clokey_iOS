//
//  AccountReportCompleteView.swift
//  Report
//
//  Created by 한금준 on 3/5/25.
//

import UIKit

protocol AccountReportCompleteViewDelegate: AnyObject {
    func contentInputView(_ view: AccountReportCompleteView, shouldMoveWithKeyboard offset: CGFloat)
    func contentInputView(_ view: AccountReportCompleteView, didUpdateText text: String)
}

class AccountReportCompleteView: UIView, UITextFieldDelegate {
    weak var delegate: AccountReportCompleteViewDelegate?

    private let reasonTitle = UILabel().then {
        $0.text = "신고 사유"
        $0.font = .ptdSemiBoldFont(ofSize: 16)
        $0.textColor = .black
    }
    
    private let reasonSubtitle = UILabel().then {
        $0.text = "스팸 홍보 및 도배 계정입니다."
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = .black
    }
    
    let textAddBox = UITextView().then {
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.mainBrown600.cgColor
        $0.backgroundColor = .white
        $0.font = .ptdRegularFont(ofSize: 12)
        $0.textContainerInset = UIEdgeInsets(top: 9, left: 12, bottom: 9, right: 12)
        $0.text = "신고 내용을 입력해주세요."
        $0.textColor = .placeholderText
        $0.isScrollEnabled = true
    }
    
    private let warningImage1 = UIImageView().then {
        $0.image = UIImage(systemName: "exclamationmark.circle")
        $0.tintColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
        $0.contentMode = .scaleAspectFit
    }
    
    private let warningText1 = UILabel().then {
        $0.text = "신고 접수 후 패널티 조치까지 영업일 기준 최소 3일에서 최대 5일까지 소요될 수 있습니다."
        $0.font = .ptdRegularFont(ofSize: 14)
        $0.textColor = .gray
        $0.numberOfLines = 0
    }
    
    private let warningImage2 = UIImageView().then {
        $0.image = UIImage(systemName: "exclamationmark.circle")
        $0.tintColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
        $0.contentMode = .scaleAspectFit
    }
    
    private let warningText2 = UILabel().then {
        $0.text = "신고 내용에 대한 사실 관계 확인이 필요할 경우, Clokey 고객센터 측에서 신고자에게 객관적 자료 제출을 요청할 수 있습니다."
        $0.font = .ptdRegularFont(ofSize: 14)
        $0.textColor = .gray
        $0.numberOfLines = 0
    }
    
    private let warningImage3 = UIImageView().then {
        $0.image = UIImage(systemName: "exclamationmark.circle")
        $0.tintColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
        $0.contentMode = .scaleAspectFit
    }
    
    private let warningText3 = UILabel().then {
        $0.text = "허위 신고롤 확인된 경우 Clokey 고객 센터 측에서 회원관리정책에 명시한 바와 같이 사용자의 활동을 제한할 수 있습니다."
        $0.font = .ptdRegularFont(ofSize: 14)
        $0.textColor = .gray
        $0.numberOfLines = 0
    }
    
    let completeButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.backgroundColor = UIColor.pointOrange800
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 20)
        $0.layer.cornerRadius = 10
//        $0.isEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        textAddBox.delegate = self
        
        setupKeyboardNotifications()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
        setupKeyboardNotifications()
    }
    
    private func setupView() {
        backgroundColor = .white
        
        addSubview(reasonTitle)
        addSubview(reasonSubtitle)
        addSubview(textAddBox)
        addSubview(warningImage1)
        addSubview(warningText1)
        addSubview(warningImage2)
        addSubview(warningText2)
        addSubview(warningImage3)
        addSubview(warningText3)
        addSubview(completeButton)
    }
    
    private func setupConstraints() {
        reasonTitle.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(18)
            $0.leading.equalToSuperview().offset(20)
        }
        
        reasonSubtitle.snp.makeConstraints {
            $0.top.equalTo(reasonTitle.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
        }
        
        textAddBox.snp.makeConstraints {
            $0.top.equalTo(reasonSubtitle.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(109)
        }
        
        warningImage1.snp.makeConstraints {
            $0.top.equalTo(textAddBox.snp.bottom).offset(21)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(16)
        }
        
        warningText1.snp.makeConstraints {
            $0.top.equalTo(warningImage1.snp.top)
            $0.leading.equalTo(warningImage1.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        warningImage2.snp.makeConstraints {
            $0.top.equalTo(warningImage1.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(16)
        }
        
        warningText2.snp.makeConstraints {
            $0.top.equalTo(warningImage2.snp.top)
            $0.leading.equalTo(warningImage2.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        warningImage3.snp.makeConstraints {
            $0.top.equalTo(warningImage2.snp.bottom).offset(62)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(16)
        }
        
        warningText3.snp.makeConstraints {
            $0.top.equalTo(warningImage3.snp.top)
            $0.leading.equalTo(warningImage3.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(54)
            $0.width.equalTo(353)
        }
    }

    func getTextContent() -> String {
        return textAddBox.text
    }
    
    // 키보드 자동조정
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        let overlap = fieldBottom - keyboardY + 50 // 여유공간
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
}

extension AccountReportCompleteView: UITextViewDelegate {
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
    
    // 텍스트 줄바꿈
    func textViewDidChange(_ textView: UITextView) {
        delegate?.contentInputView(self, didUpdateText: textView.text)
    }
}
