//
//  CustomTextField.swift
//  Clokey
//
//  Created by 황상환 on 1/14/25.
//

import UIKit
import SnapKit

class CustomTextField: UIView {
    
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
    let textField: UITextField = {
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

    // 하단 선
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainBrown600
        return view
    }()
    
    // 초기화 메서드
    init(title: String, placeholder: String? = nil, isRequired: Bool = false) {
        super.init(frame: .zero)
        
        // 라벨 설정
        titleLabel.text = title
        requiredIndicator.isHidden = !isRequired
        textField.placeholder = placeholder // 플레이스홀더 설정
        
        // 레이아웃 구성
        addSubview(titleLabel)
        addSubview(requiredIndicator)
        addSubview(textField)
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
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
    
        bottomLine.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        // 텍스트 필드의 상태 변화 감지
        textField.addTarget(self, action: #selector(editingBegan), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(editingEnded), for: .editingDidEnd)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func editingBegan() {
        bottomLine.backgroundColor = UIColor.systemBlue
    }
    
    @objc private func editingEnded() {
        bottomLine.backgroundColor = UIColor.lightGray
    }
    
    // 플레이스홀더 변경 메서드
    func setPlaceholder(_ placeholder: String) {
        textField.placeholder = placeholder
    }
    
    // 글꼴 커스텀
    func setTextFieldFontSize(_ size: CGFloat) {
        textField.font = UIFont.ptdMediumFont(ofSize: size)
    }
}
