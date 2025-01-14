//
//  CustomButton.swift
//  Clokey
//
//  Created by 황상환 on 1/14/25.
//

import UIKit
import SnapKit

class CustomButton: UIButton {
    // 커스텀 가능 요소들
    init(
        title: String = "",
        titleColor: UIColor = .white,
        isEnabled: Bool = false
    ) {
        super.init(frame: .zero)
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.backgroundColor = isEnabled ? .mainBrown800 : .mainBrown400
        self.layer.cornerRadius = 10
        self.titleLabel?.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        self.snp.makeConstraints { make in
            make.height.equalTo(54)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 활성화/비화성화 스타일
    func setEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        self.backgroundColor = isEnabled ? .mainBrown800 : .mainBrown400
        self.setTitleColor(isEnabled ? .white : .white, for: .normal)
    }
}
