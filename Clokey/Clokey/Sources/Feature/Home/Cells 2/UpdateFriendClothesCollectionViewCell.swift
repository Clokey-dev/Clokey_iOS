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
    
    //    let containerView: UIView = UIView().then {
    //        $0.backgroundColor = UIColor(red: 255/255, green: 248/255, blue: 235/255, alpha: 1) // 연한 베이지색 배경
    //        $0.layer.cornerRadius = 10
    //        $0.clipsToBounds = true
    //    }
//    let profileContainer: UIView = UIView().then {
//        $0.backgroundColor = .mainBrown800
//        $0.layer.cornerRadius = 10
//        $0.clipsToBounds = true
//    }
    
    let profileIcon: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "profile_icon")
        $0.tintColor = .gray
        $0.contentMode = .scaleAspectFit
                $0.layer.cornerRadius = 10
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
    
    let imageStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 8
    }
    
    // Image Views for Kingfisher
    let image1 = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 0
    }
    
    let image2 = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 0
    }
    
    let image3 = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 0
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
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        image1.image = nil
//        image2.image = nil
//        image3.image = nil
//    }
    
    private func setupUI() {
        
        addSubview(profileIcon)
        addSubview(nameLabel)
        addSubview(dateLabel)
        addSubview(imageStack)
        imageStack.addSubview(image1)
        imageStack.addSubview(image2)
        imageStack.addSubview(image3)
        addSubview(separatorLine)
        
    }
    
    private func setupConstraints() {
        
        
        profileIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview().offset(20)
//            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileIcon.snp.trailing).offset(8)
            make.centerY.equalTo(profileIcon)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(profileIcon)
        }
        imageStack.snp.makeConstraints { make in
            make.top.equalTo(profileIcon.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(116)
        }
        
        image1.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview() // 상하 배치 고정
            make.leading.equalToSuperview() // 좌측 고정
            make.width.equalTo(88) // 고정 너비 설정
        }
        
        image2.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview() // 상하 배치 고정
            make.leading.equalTo(image1.snp.trailing).offset(20)
            make.width.equalTo(88) // 고정 너비 설정
        }
        
        image3.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview() // 상하 배치 고정
            make.leading.equalTo(image2.snp.trailing).offset(20)
            make.width.equalTo(88) // 고정 너비 설정
            make.trailing.equalToSuperview() // 우측 고정
        }
        
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(imageStack.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview().offset(-14)
        }
    }
}
