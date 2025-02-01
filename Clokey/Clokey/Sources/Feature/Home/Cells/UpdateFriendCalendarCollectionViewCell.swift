//
//  UpdateFriendCalendarCollectionViewCell.swift
//  Clokey
//
//  Created by 한금준 on 1/17/25.
//

// 완료

import UIKit
import Then
import SnapKit

class UpdateFriendCalendarCollectionViewCell: UICollectionViewCell {
    static let identifier = "UpdateFriendCalendarCollectionViewCell"
    
    let imageView = UIImageView().then{
        $0.contentMode = .scaleAspectFill
//        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.backgroundColor = .gray
    }
    
    // 아이콘 이미지뷰
    let iconImageView = UIImageView().then {
        $0.contentMode = .center // 이미지가 뷰 중앙에 맞춰 표시되며 잘리지 않음
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "profile_icon") // 아이콘 이미지 설정
        $0.clipsToBounds = false
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true // 둥근 모서리 안쪽에만 이미지 표시
    }
    
    let titleLabel = UILabel().then{
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .black
        $0.text = "티라미수케이크"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(imageView)
        addSubview(iconImageView)
        addSubview(titleLabel)
        
        imageView.snp.makeConstraints{
            $0.top.horizontalEdges.equalToSuperview()
            $0.width.equalTo(171)
            $0.height.equalTo(221)
        }
        
        // 아이콘 이미지 레이아웃 (아래쪽 텍스트 왼쪽)
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(7)
            $0.leading.equalToSuperview().offset(3)
            $0.width.height.equalTo(20) // 아이콘 크기
        }
        
        // 제목 레이블 레이아웃
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(iconImageView) // 아이콘과 수직 정렬
//            $0.top.equalTo(iconImageView.snp.bottom).offset(10)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
//            $0.trailing.equalToSuperview().offset(-8)
        }
    }
}
