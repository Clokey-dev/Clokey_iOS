//
//  SuccessView.swift
//  Clokey
//
//  Created by 한금준 on 2/2/25.
//

import UIKit

class SuccessView: UIView {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "check_circle_icon") // 시스템 아이콘
        imageView.tintColor = UIColor.brown // 갈색 색상
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "옷장에 안전하게\n보관해 드릴게요!"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium) // 기본 폰트
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2 // 두 줄로 표시
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        // Add Subviews
        addSubview(iconImageView)
        addSubview(messageLabel)
        
        // Constraints
        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview() // 화면 중앙
            make.centerY.equalToSuperview().offset(-50) // 중앙에서 위로 약간 이동
            make.width.height.equalTo(80) // 아이콘 크기
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(16) // 아이콘 아래 간격
            make.centerX.equalToSuperview() // 중앙 정렬
        }
    }
    
}
