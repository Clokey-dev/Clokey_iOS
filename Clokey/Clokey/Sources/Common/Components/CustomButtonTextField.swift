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
        textField.textColor = UIColor.mainBrown600

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
        addSubview(textField)
        addSubview(actionButton)
        addSubview(bottomLine)
        
        // SnapKit으로 레이아웃 설정
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        requiredIndicator.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(2)
            make.centerY.equalTo(titleLabel)
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview()
            make.trailing.equalTo(actionButton.snp.leading).offset(-8)
            make.height.equalTo(40)
        }
        
        actionButton.snp.makeConstraints { make in
            make.centerY.equalTo(textField)
            make.trailing.equalToSuperview()
            make.width.equalTo(76)
            make.height.equalTo(28)
        }
        
        bottomLine.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 버튼 활성화/비활성화
    func setButtonEnabled(_ isEnabled: Bool) {
        actionButton.isEnabled = isEnabled
        actionButton.backgroundColor = isEnabled ? UIColor.mainBrown800 : UIColor.white
        actionButton.setTitleColor(isEnabled ? UIColor.white : UIColor.textGray800, for: .normal)
        actionButton.layer.borderColor = isEnabled ? UIColor.mainBrown800.cgColor : UIColor.textGray800.cgColor
    }
    
    // 버튼 텍스트 설정
    func setButtonText(_ text: String) {
        actionButton.setTitle(text, for: .normal)
    }
    
    // 플레이스홀더 변경 메서드
    func setPlaceholder(_ placeholder: String) {
        textField.placeholder = placeholder
    }
}
