//
//  CustomButton.swift
//  Clokey
//
//  Created by 황상환 on 1/14/25.
//

import UIKit
import SnapKit

class CustomButton: UIButton {
    // isEnabled 상태를 추적하기 위한 프로퍼티
    private var buttonEnabled: Bool = false
    
    // 커스텀 가능 요소들
    init(
        title: String = "",
        titleColor: UIColor = .white,
        isEnabled: Bool = false
    ) {
        super.init(frame: .zero)
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.layer.cornerRadius = 10
        self.titleLabel?.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        self.snp.makeConstraints {
            $0.height.equalTo(54)
        }
        
        // 초기 상태 설정
        setEnabled(isEnabled)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 활성화/비활성화 스타일
    func setEnabled(_ isEnabled: Bool) {
        self.buttonEnabled = isEnabled  // 내부 상태 추적
        super.isEnabled = isEnabled     // UIButton의 isEnabled도 설정
        self.backgroundColor = isEnabled ? .mainBrown800 : .mainBrown400
        self.setTitleColor(.white, for: .normal)
    }
    
    // isEnabled 오버라이드
    override var isEnabled: Bool {
        get {
            return buttonEnabled
        }
        set {
            setEnabled(newValue)
        }
    }
}
