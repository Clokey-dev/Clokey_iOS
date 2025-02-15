//
//  CustomButtonTextField.swift
//  Test
//
//  Created by 황상환 on 1/14/25.
//

import Foundation
import UIKit
import SnapKit

class CustomButtonTextField: UIView {

    // 상단 라벨
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ptdMediumFont(ofSize: 20)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    // 강조 표시 (별표)
    private let requiredIndicator: UILabel = {
        let label = UILabel()
        label.text = "*"
        label.font = UIFont.ptdMediumFont(ofSize: 16)
        label.textColor = UIColor.pointOrange800
        label.isHidden = true // 기본적으로 숨김
        return label
    }()
    
    // 텍스트 필드
    private let textField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.borderStyle = .none
        textField.font = UIFont.ptdMediumFont(ofSize: 20)
        textField.textColor = UIColor.black

        // placeholder 스타일 설정
        let placeholderText = " "
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray, // 플레이스홀더 색상
            .font: UIFont.ptdMediumFont(ofSize: 18) // 플레이스홀더 폰트 크기
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)

        return textField
    }()

    
    // 버튼
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("중복 확인", for: .normal)
        button.setTitleColor(.textGray800, for: .normal)
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 16)
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.mainBrown800.cgColor
        button.layer.borderWidth = 1
        button.isEnabled = false // 기본적으로 비활성화
        return button
    }()
    
    // 하단 선
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    // 초기화 메서드
    init(title: String, placeholder: String? = nil, isRequired: Bool = false) {
        super.init(frame: .zero)
        
        // 라벨 설정
        titleLabel.text = title
        requiredIndicator.isHidden = !isRequired
        textField.placeholder = placeholder
        
        // 레이아웃 구성
        addSubview(titleLabel)
        addSubview(requiredIndicator)
        
        // 텍스트 필드
        textField.placeholder = placeholder
        addSubview(textField)
        
        addSubview(actionButton)
        addSubview(bottomLine)
        
        // SnapKit으로 레이아웃 설정
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        requiredIndicator.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(2)
            $0.centerY.equalTo(titleLabel)
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(actionButton.snp.leading).offset(-8)
            $0.height.equalTo(40)
        }
        
        actionButton.snp.makeConstraints {             $0.centerY.equalTo(textField)
            $0.trailing.equalToSuperview()
            $0.width.equalTo(76)
            $0.height.equalTo(28)
        }
        
        bottomLine.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 버튼
    // 커스텀 버튼
    var customButton: UIButton {
        return actionButton
    }
    
    // 버튼 활성화/비활성화
    func setButtonEnabled(_ isEnabled: Bool) {
        actionButton.isEnabled = isEnabled
        actionButton.backgroundColor = isEnabled ? UIColor.mainBrown800 : UIColor.white
        actionButton.setTitleColor(isEnabled ? UIColor.white : UIColor.textGray800, for: .normal)
        actionButton.layer.borderColor = isEnabled ? UIColor.mainBrown800.cgColor : UIColor.textGray800.cgColor
    }
    
    // 버튼 텍스트 설정
    func setButtonText(_ text: String, fontSize: CGFloat? = nil, color: UIColor? = nil) {
        actionButton.setTitle(text, for: .normal)
        if let fontSize = fontSize {
            actionButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: fontSize)
        }
        if let color = color {
            actionButton.setTitleColor(color, for: .normal)
        }
    }
    
    // 버튼 텍스트 크기 설정
    func setButtonFontSize(_ size: CGFloat) {
        actionButton.titleLabel?.font = UIFont.ptdMediumFont(ofSize: size)
    }
    
    // 버튼 텍스트 크기
    func setTextFieldFontSize(_ size: CGFloat) {
        textField.font = UIFont.ptdMediumFont(ofSize: size)
    }
    
    // 버튼 액션
    func addTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        textField.addTarget(target, action: action, for: event)
    }
        
    // MARK: - 텍스트 필드
    // 플레이스홀더 변경 메서드
    func setPlaceholder(_ placeholder: String) {
        textField.placeholder = placeholder
    }
    
    // 텍스트 필드의 텍스트
    var text: String? {
        get { return textField.text }
        set { textField.text = newValue }
    }
    
    // 텍스트 델리게이트
    var delegate: UITextFieldDelegate? {
        get { return textField.delegate }
        set { textField.delegate = newValue}
    }

}
