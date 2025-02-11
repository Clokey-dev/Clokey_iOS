//
//  EmptyStackView.swift
//  Clokey
//
//  Created by 한금준 on 2/8/25.
//

import UIKit

class PrivateStackView: UIView {

    
    /// 빈 상태 아이콘
    let privateIcon: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "Profile_Private")
        $0.tintColor = .gray
    }
    
    /// 빈 상태 메시지 제목
    let privateMessageTitle: UILabel = UILabel().then {
        $0.text = "비공계 계정입니다"
        $0.textColor = .gray
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
   
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = .white
        addSubview(privateIcon)
        addSubview(privateMessageTitle)
    }
    
    private func setupConstraints() {
        privateIcon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(48)
        }
        
        privateMessageTitle.snp.makeConstraints { make in
            make.top.equalTo(privateIcon.snp.bottom).offset(16)
            make.centerX.equalTo(privateIcon)
        }
    }
}
