//
//  NewsView.swift
//  Clokey
//
//  Created by 한금준 on 1/11/25.
//

// 완

import UIKit

class NewsView: UIView {
    
    // MARK: - UI Elements
    let scrollView: UIScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    let contentView: UIView = UIView().then {
        $0.backgroundColor = .white
    }
    
    let recommandTitle: UILabel = UILabel().then {
        $0.text = "나를 위한 추천 소식"
        $0.textColor = .black
        $0.font = UIFont.ptdBoldFont(ofSize: 20)
    }
    
    let slideContainerView: UIView = UIView().then {
        $0.backgroundColor = .gray // 슬라이드 뷰 배경은 투명
    }
    
    let friendClothesTitle: UILabel = UILabel().then {
        $0.text = "팔로우 중인 옷장 업데이트 소식"
        $0.textColor = .black
        $0.font = UIFont.ptdBoldFont(ofSize: 20)
    }
    
    let profileContainerView: UIView = UIView().then {
        $0.backgroundColor = UIColor(red: 255/255, green: 238/255, blue: 230/255, alpha: 1) // 연한 베이지색 배경
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    let profileImageView: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "profile_icon")
        $0.tintColor = .gray
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    let usernameLabel: UILabel = UILabel().then {
        $0.text = "Sena_05"
        $0.textColor = .black
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
    }
    
    let dateLabel: UILabel = UILabel().then {
        $0.text = "2024.11.27"
        $0.textColor = .darkGray
        $0.font = UIFont.ptdMediumFont(ofSize: 12)
    }
    
    let imageStackView: UIStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.distribution = .fillEqually
    }
    
    // Image Views for Kingfisher
    let friendClothesImageView1 = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 5
    }
    
    let friendClothesImageView2 = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 5
    }
    
    let friendClothesImageView3 = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 5
    }
    
    let friendClothesBottomButtonLabel: UILabel = UILabel().then {
        $0.text = "더보기"
        $0.textColor = .black
        $0.font = UIFont.ptdBoldFont(ofSize: 12)
    }
    
    let friendClothesBottomArrowIcon: UIImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFit
    }
    
    let followingCalendarUpdateTitle: UILabel = UILabel().then {
        $0.text = "팔로우 중인 캘린더 업데이트 소식"
        $0.textColor = .black
        $0.font = UIFont.ptdBoldFont(ofSize: 20)
    }
    
    let followingCalendarUpdateContainerView: UIView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let followingCalendarUpdateImageView1: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }
    
    let followingCalendarUpdateImageView2: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }
    
    let followingCalendarBottomButtonLabel: UILabel = UILabel().then {
        $0.text = "더보기"
        $0.textColor = .black
        $0.font = UIFont.ptdBoldFont(ofSize: 12)
    }
    
    let followingCalendarBottomArrowIcon: UIImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFit
    }
    
    let hotAccountTitle: UILabel = UILabel().then {
        $0.text = "HOT 계정"
        $0.textColor = .black
        $0.font = UIFont.ptdBoldFont(ofSize: 20)
    }
    
    let hotAccountContainerView: UIView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let hotAccountImageView1: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }
    
    let hotAccountImageView2: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .white
        
        // ScrollView와 ContentView 추가
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(recommandTitle)
        contentView.addSubview(slideContainerView)
        
        contentView.addSubview(friendClothesTitle)
        contentView.addSubview(profileContainerView)
        profileContainerView.addSubview(profileImageView)
        profileContainerView.addSubview(usernameLabel)
        profileContainerView.addSubview(dateLabel)
        profileContainerView.addSubview(imageStackView)
        contentView.addSubview(friendClothesBottomButtonLabel)
        contentView.addSubview(friendClothesBottomArrowIcon)
        
        [friendClothesImageView1, friendClothesImageView2, friendClothesImageView3].forEach { imageView in
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 5
            imageStackView.addArrangedSubview(imageView)
        }
        
        contentView.addSubview(followingCalendarUpdateTitle)
        contentView.addSubview(followingCalendarUpdateContainerView)
        followingCalendarUpdateContainerView.addSubview(followingCalendarUpdateImageView1)
        followingCalendarUpdateContainerView.addSubview(followingCalendarUpdateImageView2)
        contentView.addSubview(followingCalendarBottomButtonLabel)
        contentView.addSubview(followingCalendarBottomArrowIcon)
        
        contentView.addSubview(hotAccountTitle)
        contentView.addSubview(hotAccountContainerView)
        hotAccountContainerView.addSubview(hotAccountImageView1)
        hotAccountContainerView.addSubview(hotAccountImageView2)
        
        
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // 화면 전체에 ScrollView
        }
        
        // ContentView 제약 설정
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView) // ScrollView 내부에 맞춤
            make.width.equalToSuperview() // 가로 크기는 화면 크기와 동일
        }
        
        // Layout using SnapKit
        // 기존 UI 요소 제약 추가
        recommandTitle.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(224)
            make.height.equalTo(24)
        }
        
        // Slide Container View 레이아웃 설정
        slideContainerView.snp.makeConstraints { make in
            make.top.equalTo(recommandTitle.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(300) // 슬라이드 뷰 높이 설정
        }
        
        friendClothesTitle.snp.makeConstraints { make in
            make.top.equalTo(slideContainerView.snp.bottom).offset(50)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(275)
            make.height.equalTo(36)
        }
        
        profileContainerView.snp.makeConstraints { make in
            make.top.equalTo(friendClothesTitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(150)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(40)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.trailing.equalToSuperview().inset(10)
        }
        imageStackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(80)
        }
        
        friendClothesBottomButtonLabel.snp.makeConstraints { make in
            make.top.equalTo(profileContainerView.snp.bottom).offset(5)
            make.trailing.equalToSuperview().inset(30)
        }
        
        friendClothesBottomArrowIcon.snp.makeConstraints { make in
            make.centerY.equalTo(friendClothesBottomButtonLabel.snp.centerY)
            make.leading.equalTo(friendClothesBottomButtonLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(6)
            make.height.equalTo(12)
        }
        
        followingCalendarUpdateTitle.snp.makeConstraints { make in
            make.top.equalTo(friendClothesBottomButtonLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(300)
            make.height.equalTo(36)
        }
        
        followingCalendarUpdateContainerView.snp.makeConstraints { make in
            make.top.equalTo(followingCalendarUpdateTitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(223.22)
        }
        
        followingCalendarUpdateImageView1.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(followingCalendarUpdateContainerView.snp.width).multipliedBy(0.5).offset(-5)
        }
        
        followingCalendarUpdateImageView2.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(followingCalendarUpdateContainerView.snp.width).multipliedBy(0.5).offset(-5)
        }
        
        followingCalendarBottomButtonLabel.snp.makeConstraints { make in
            make.top.equalTo(followingCalendarUpdateContainerView.snp.bottom).offset(5)
            make.trailing.equalToSuperview().inset(30)
        }
        
        followingCalendarBottomArrowIcon.snp.makeConstraints { make in
            make.centerY.equalTo(followingCalendarBottomButtonLabel.snp.centerY)
            make.leading.equalTo(followingCalendarBottomButtonLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(6)
            make.height.equalTo(12)
        }
        
        hotAccountTitle.snp.makeConstraints { make in
            make.top.equalTo(followingCalendarBottomButtonLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(300)
            make.height.equalTo(36)
        }
        
        hotAccountContainerView.snp.makeConstraints { make in
            make.top.equalTo(hotAccountTitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(223.22)
            make.bottom.equalToSuperview().offset(-20) // 스크롤 콘텐츠의 마지막 부분
        }
        
        hotAccountImageView1.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(hotAccountContainerView.snp.width).multipliedBy(0.5).offset(-5)
        }
        
        hotAccountImageView2.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(hotAccountContainerView.snp.width).multipliedBy(0.5).offset(-5)
        }
    }
}
