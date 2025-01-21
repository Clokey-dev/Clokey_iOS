//
//  ImageView.swift
//  Clokey
//
//  Created by 한금준 on 1/16/25.
//

// 완료

import UIKit
import SnapKit
import Then

class ImageView: UIView {
    
    // 이미지 뷰 생성
    lazy var imageView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    let titleLabel: UILabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.ptdBoldFont(ofSize: 18)
    }

    let hashtagLabel: UILabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.ptdRegularFont(ofSize: 14)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageViews()
    }
    
    // 서브뷰 추가 및 레이아웃 설정
    private func setupImageViews() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(hashtagLabel)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview() // 이미지 뷰를 뷰의 중심에 배치
            make.width.equalToSuperview() // 이미지 뷰 너비를 부모 뷰와 동일하게 설정
            make.height.equalToSuperview() // 이미지 뷰 높이를 부모 뷰와 동일하게 설정
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(40)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        hashtagLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(40)
        }
    }
}
