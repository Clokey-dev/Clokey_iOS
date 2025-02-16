//
//  UpdateFriendClothesCollectionReusableView.swift
//  Clokey
//
//  Created by 한금준 on 1/17/25.
//

// 완료

import UIKit
import Then
import SnapKit

class UpdateFriendClothesCollectionViewCell: UICollectionViewCell {
    static let identifier = "UpdateFriendClothesCollectionViewCell"
    
    let profileIcon: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "profile_icon")
        $0.backgroundColor = .gray
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 13
        $0.clipsToBounds = true
    }
    
    let nameLabel = UILabel().then {
        $0.text = "닉네임"
        $0.font = .ptdMediumFont(ofSize: 14)
        $0.textColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1)
    }
    
    let dateLabel = UILabel().then {
        $0.text = "날짜"
        $0.font = .ptdMediumFont(ofSize: 12)
        $0.textColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1)
    }
    
    let imageContainer = UIView().then {
        $0.backgroundColor = .clear // ✅ 배경색을 투명하게 유지
    }
    
    // Image Views for Kingfisher
    let image1 = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 5
//        $0.layer.borderWidth = 1
//        $0.layer.borderColor = UIColor.mainBrown800.cgColor
    }
    
    let image2 = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 5
//        $0.layer.borderWidth = 1
//        $0.layer.borderColor = UIColor.mainBrown800.cgColor
    }
    
    let image3 = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 5
//        $0.layer.borderWidth = 1
//        $0.layer.borderColor = UIColor.mainBrown800.cgColor
    }
    
    let separatorLine = UIView().then {
        $0.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func setupUI() {
        
        addSubview(profileIcon)
        addSubview(nameLabel)
        addSubview(dateLabel)
        addSubview(imageContainer)
        imageContainer.addSubview(image1)
        imageContainer.addSubview(image2)
        imageContainer.addSubview(image3)
        addSubview(separatorLine)
        
    }
    
    private func setupConstraints() {
        profileIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview()
//            make.centerY.equalToSuperview()
            make.size.equalTo(26)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileIcon.snp.trailing).offset(8)
            make.centerY.equalTo(profileIcon)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(profileIcon)
        }

        imageContainer.snp.makeConstraints { make in
            make.top.equalTo(profileIcon.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(10)
            make.width.equalTo(295) // ✅ 고정된 너비 설정
            make.height.equalTo(116)
        }

        image1.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(87)
        }

        image2.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(image1.snp.trailing).offset(21)
            make.width.equalTo(87)
        }

        image3.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(image2.snp.trailing).offset(21)
            make.width.equalTo(87)
        }
        
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(imageContainer.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }
}
