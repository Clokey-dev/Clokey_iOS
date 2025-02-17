//
//  NewsView.swift
//  Clokey
//
//  Created by 한금준 on 1/11/25.
//

// 완

import UIKit

class NewsView: UIView {
    private let emptyStackView1 = EmptyStackView()
    private let emptyStackView2 = EmptyStackView()
    
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
        $0.font = UIFont.ptdMediumFont(ofSize: 20)
    }
    
    let slideContainerView: UIView = UIView().then {
        $0.backgroundColor = .gray // 슬라이드 뷰 배경은 투명
        $0.layer.cornerRadius = 8.5
    }
    
    let friendClothesTitle: UILabel = UILabel().then {
        let fullText = "팔로우 중인 옷장 업데이트 소식"
        let targetText = "옷장"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // 전체 텍스트 스타일
        attributedString.addAttributes([
            .font: UIFont.ptdMediumFont(ofSize: 20),
            .foregroundColor: UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0)
        ], range: NSRange(location: 0, length: fullText.count))
        
        // "옷장"에 다른 스타일 적용
        if let targetRange = fullText.range(of: targetText) {
            let nsRange = NSRange(targetRange, in: fullText)
            attributedString.addAttributes([
                .font: UIFont.ptdSemiBoldFont(ofSize: 20), // 예시로 굵게 처리
                .foregroundColor: UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0) // 색상을 변경하려면 여기 설정
            ], range: nsRange)
        }
        
        $0.attributedText = attributedString
    }
    
    let profileContainerView: UIView = UIView().then {
        $0.backgroundColor = UIColor(red: 255/255, green: 248/255, blue: 235/255, alpha: 1) // 연한 베이지색 배경
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    let profileImageView: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "profile_icon")
        $0.tintColor = .gray
        $0.contentMode = .scaleAspectFill
//        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    let usernameLabel: UILabel = UILabel().then {
        $0.text = "Sena_05"
        $0.textColor = .black
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
    }
    
    let dateLabel: UILabel = UILabel().then {
        $0.text = "2024.11.27"
        $0.textColor = .black
        $0.font = UIFont.ptdMediumFont(ofSize: 12)
    }
    
    let imageStackView: UIStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 21
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
        $0.font = UIFont.ptdMediumFont(ofSize: 12)
    }
    
    let friendClothesBottomArrowIcon: UIImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFill
    }
    
    let followingCalendarUpdateTitle: UILabel = UILabel().then {
        let fullText = "팔로우 중인 캘린더 업데이트 소식"
        let targetText = "캘린더"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // 전체 텍스트 스타일
        attributedString.addAttributes([
            .font: UIFont.ptdMediumFont(ofSize: 20),
            .foregroundColor: UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0)
        ], range: NSRange(location: 0, length: fullText.count))
        
        // "캘린더"에 다른 스타일 적용
        if let targetRange = fullText.range(of: targetText) {
            let nsRange = NSRange(targetRange, in: fullText)
            attributedString.addAttributes([
                .font: UIFont.ptdSemiBoldFont(ofSize: 20), // 예시로 굵게 처리
                .foregroundColor: UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0) // 색상을 변경하려면 여기 설정
            ], range: nsRange)
        }
        
        $0.attributedText = attributedString
    }
    
    let followingCalendarUpdateSubTitle: UILabel = UILabel().then {
        $0.text = "2024.11.27" // 부제목 텍스트
        $0.textColor = .black // 텍스트 색상
        $0.font = UIFont.ptdRegularFont(ofSize: 14) // 작은 폰트 크기
        $0.numberOfLines = 0 // 여러 줄 허용
    }
    
    let followingCalendarUpdateContainerView: UIView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let followingCalendarUpdateImageView1: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }
    
    let followingCalendarProfileIcon1: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "profile_icon") // 아이콘 이미지 설정
        $0.clipsToBounds = true
    }
    
    let followingCalendarProfileName1 = UILabel().then{
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .black
        $0.text = "티라미수케이크"
    }
    
    let followingCalendarUpdateImageView2: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }
    
    let followingCalendarProfileIcon2: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "profile_icon") // 아이콘 이미지 설정
        $0.clipsToBounds = true
    }
    
    let followingCalendarProfileName2 = UILabel().then{
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .black
        $0.text = "티라미수케이크"
    }
    
    let followingCalendarBottomButtonLabel: UILabel = UILabel().then {
        $0.text = "더보기"
        $0.textColor = .black
        $0.font = UIFont.ptdMediumFont(ofSize: 12)
    }
    
    let followingCalendarBottomArrowIcon: UIImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .mainBrown800
        $0.contentMode = .scaleAspectFit
    }
    
    let hotAccountTitle: UILabel = UILabel().then {
        $0.text = "HOT 계정"
        $0.textColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0)
        $0.font = UIFont.ptdMediumFont(ofSize: 20)
    }
    
    let hotAccountContainerView: UIView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let hotAccountImageView1: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }
    
    let hotAccountProfileIcon1: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "profile_icon") // 아이콘 이미지 설정
        $0.clipsToBounds = true
    }
    
    let hotAccountProfileName1 = UILabel().then{
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = UIColor(red: 52/255, green: 52/255, blue: 52/255, alpha: 1.0)
        $0.text = "티라미수케이크"
    }
    
    let hotAccountImageView2: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }
    
    let hotAccountProfileIcon2: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "profile_icon") // 아이콘 이미지 설정
        $0.clipsToBounds = true
    }
    
    let hotAccountProfileName2 = UILabel().then{
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0)
        $0.text = "티라미수케이크"
    }
    
    let hotAccountImageView3: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }
    
    let hotAccountProfileIcon3: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "profile_icon") // 아이콘 이미지 설정
        $0.clipsToBounds = true
    }
    
    let hotAccountProfileName3 = UILabel().then{
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0)
        $0.text = "티라미수케이크"
    }
    
    let hotAccountImageView4: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }
    
    let hotAccountProfileIcon4: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "profile_icon") // 아이콘 이미지 설정
        $0.clipsToBounds = true
    }
    
    let hotAccountProfileName4 = UILabel().then{
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0)
        $0.text = "티라미수케이크"
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
            imageView.layer.cornerRadius = 0
            imageStackView.addArrangedSubview(imageView)
        }
        
        contentView.addSubview(followingCalendarUpdateTitle)
        contentView.addSubview(followingCalendarUpdateSubTitle)
        contentView.addSubview(followingCalendarUpdateContainerView)
        followingCalendarUpdateContainerView.addSubview(followingCalendarUpdateImageView1)
        followingCalendarUpdateContainerView.addSubview(followingCalendarProfileIcon1)
        followingCalendarUpdateContainerView.addSubview(followingCalendarProfileName1)
        followingCalendarUpdateContainerView.addSubview(followingCalendarUpdateImageView2)
        followingCalendarUpdateContainerView.addSubview(followingCalendarProfileIcon2)
        followingCalendarUpdateContainerView.addSubview(followingCalendarProfileName2)
        contentView.addSubview(followingCalendarBottomButtonLabel)
        contentView.addSubview(followingCalendarBottomArrowIcon)
        
        contentView.addSubview(hotAccountTitle)
        contentView.addSubview(hotAccountContainerView)
        hotAccountContainerView.addSubview(hotAccountImageView1)
        hotAccountContainerView.addSubview(hotAccountProfileIcon1)
        hotAccountContainerView.addSubview(hotAccountProfileName1)
        hotAccountContainerView.addSubview(hotAccountImageView2)
        hotAccountContainerView.addSubview(hotAccountProfileIcon2)
        hotAccountContainerView.addSubview(hotAccountProfileName2)
        hotAccountContainerView.addSubview(hotAccountImageView3)
        hotAccountContainerView.addSubview(hotAccountProfileIcon3)
        hotAccountContainerView.addSubview(hotAccountProfileName3)
        hotAccountContainerView.addSubview(hotAccountImageView4)
        hotAccountContainerView.addSubview(hotAccountProfileIcon4)
        hotAccountContainerView.addSubview(hotAccountProfileName4)
        
        
        
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
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(21)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(224)
            make.height.equalTo(24)
        }
        
        // Slide Container View 레이아웃 설정
        slideContainerView.snp.makeConstraints { make in
            make.top.equalTo(recommandTitle.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(44)
//            make.width.equalTo(300)
            make.height.equalTo(300) // 슬라이드 뷰 높이 설정
        }
        
        friendClothesTitle.snp.makeConstraints { make in
            make.top.equalTo(slideContainerView.snp.bottom).offset(50)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(275)
            make.height.equalTo(36)
        }
        
        profileContainerView.snp.makeConstraints { make in
            make.top.equalTo(friendClothesTitle.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(179)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(13)
            make.leading.equalToSuperview().offset(27)
            make.width.height.equalTo(24)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(14)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.trailing.equalToSuperview().inset(23)
//            make.width.equalTo(60)
            make.height.equalTo(16)
        }
        
        imageStackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(25) // 부모 뷰의 좌우 간격 유지
            make.height.equalTo(119) // 고정된 높이
        }
        
        friendClothesBottomButtonLabel.snp.makeConstraints { make in
            make.top.equalTo(profileContainerView.snp.bottom).offset(8)
            make.trailing.equalToSuperview().inset(36)
            make.width.equalTo(37)
            make.height.equalTo(21)
        }
        
        friendClothesBottomArrowIcon.snp.makeConstraints { make in
            make.centerY.equalTo(friendClothesBottomButtonLabel.snp.centerY)
//            make.leading.equalTo(friendClothesBottomButtonLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(6)
            make.height.equalTo(12)
        }
        
        followingCalendarUpdateTitle.snp.makeConstraints { make in
            make.top.equalTo(friendClothesBottomButtonLabel.snp.bottom).offset(26)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(326)
            make.height.equalTo(24)
        }
        
        followingCalendarUpdateSubTitle.snp.makeConstraints { make in
            make.top.equalTo(followingCalendarUpdateTitle.snp.bottom).offset(7)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(233)
            make.height.equalTo(16)
        }
        
        
        followingCalendarUpdateContainerView.snp.makeConstraints { make in
            make.top.equalTo(followingCalendarUpdateSubTitle.snp.bottom).offset(11)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(250) // 컨테이너 높이를 늘림
        }

        // 첫 번째 이미지 뷰
        followingCalendarUpdateImageView1.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
//            make.width.equalTo(followingCalendarUpdateImageView2)
            make.width.equalTo(followingCalendarUpdateContainerView.snp.width).multipliedBy(0.5).offset(-5) // 너비의 절반 - 간격
            make.height.equalTo(220) // 고정 높이 설정
        }

        // 첫 번째 프로필 아이콘
        followingCalendarProfileIcon1.snp.makeConstraints { make in
            make.top.equalTo(followingCalendarUpdateImageView1.snp.bottom).offset(10)
            make.leading.equalTo(followingCalendarUpdateImageView1.snp.leading)
            make.width.height.equalTo(20) // 아이콘 크기
        }

        // 첫 번째 이름 레이블
        followingCalendarProfileName1.snp.makeConstraints { make in
            make.centerY.equalTo(followingCalendarProfileIcon1)
            make.leading.equalTo(followingCalendarProfileIcon1.snp.trailing).offset(8)
        }

        // 두 번째 이미지 뷰
        followingCalendarUpdateImageView2.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
//            make.width.equalTo(followingCalendarUpdateImageView1)
            make.width.equalTo(followingCalendarUpdateContainerView.snp.width).multipliedBy(0.5).offset(-5) // 너비의 절반 - 간격
            make.height.equalTo(220) // 고정 높이 설정
        }

        // 두 번째 프로필 아이콘
        followingCalendarProfileIcon2.snp.makeConstraints { make in
            make.top.equalTo(followingCalendarUpdateImageView2.snp.bottom).offset(10)
            make.leading.equalTo(followingCalendarUpdateImageView2.snp.leading)
            make.width.height.equalTo(20) // 아이콘 크기
        }

        // 두 번째 이름 레이블
        followingCalendarProfileName2.snp.makeConstraints { make in
            make.centerY.equalTo(followingCalendarProfileIcon2)
            make.leading.equalTo(followingCalendarProfileIcon2.snp.trailing).offset(8)
        }
        
        followingCalendarBottomButtonLabel.snp.makeConstraints { make in
            make.top.equalTo(followingCalendarProfileName2.snp.bottom)
            make.trailing.equalToSuperview().inset(36)
            make.height.equalTo(16)
        }
        
        followingCalendarBottomArrowIcon.snp.makeConstraints { make in
            make.centerY.equalTo(followingCalendarBottomButtonLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(6)
            make.height.equalTo(12)
        }
        
        hotAccountTitle.snp.makeConstraints { make in
            make.top.equalTo(followingCalendarBottomButtonLabel.snp.bottom).offset(26)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(224)
            make.height.equalTo(24)
        }
        
        hotAccountContainerView.snp.makeConstraints { make in
            make.top.equalTo(hotAccountTitle.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(524)
            make.bottom.equalToSuperview().offset(-40) // 스크롤 콘텐츠의 마지막 부분
        }
        
        hotAccountImageView1.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
//            make.width.equalTo(hotAccountContainerView.snp.width).multipliedBy(0.5).offset(-5)
            make.width.equalTo(160)
            make.height.equalTo(220)
        }
        
        hotAccountProfileIcon1.snp.makeConstraints {
            $0.top.equalTo(hotAccountImageView1.snp.bottom).offset(10)
            $0.leading.equalTo(hotAccountImageView1.snp.leading)
            $0.width.height.equalTo(20) // 아이콘 크기
        }
        
        // 제목 레이블 레이아웃
        hotAccountProfileName1.snp.makeConstraints {
//            $0.centerY.equalTo(hotAccountProfileIcon1) // 아이콘과 수직 정렬
            $0.top.equalTo(hotAccountImageView1.snp.bottom).offset(13)
            $0.leading.equalTo(hotAccountProfileIcon1.snp.trailing).offset(8)
        }
        
        hotAccountImageView2.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
//            make.width.equalTo(hotAccountContainerView.snp.width).multipliedBy(0.5).offset(-5)
            make.width.equalTo(160)
            make.height.equalTo(220)
        }
        
        hotAccountProfileIcon2.snp.makeConstraints {
            $0.top.equalTo(hotAccountImageView2.snp.bottom).offset(10)
            $0.leading.equalTo(hotAccountImageView2.snp.leading)
            $0.width.height.equalTo(20) // 아이콘 크기
        }
        
        // 제목 레이블 레이아웃
        hotAccountProfileName2.snp.makeConstraints {
//            $0.centerY.equalTo(hotAccountProfileIcon2) // 아이콘과 수직 정렬
            $0.top.equalTo(hotAccountImageView2.snp.bottom).offset(13)
            $0.leading.equalTo(hotAccountProfileIcon2.snp.trailing).offset(8)
        }
        
        hotAccountImageView3.snp.makeConstraints { make in
            make.top.equalTo(hotAccountProfileIcon1.snp.bottom).offset(18)
            make.leading.equalToSuperview()
//            make.width.equalTo(hotAccountContainerView.snp.width).multipliedBy(0.5).offset(-5)
            make.width.equalTo(160)
            make.height.equalTo(220)
        }
        
        hotAccountProfileIcon3.snp.makeConstraints {
            $0.top.equalTo(hotAccountImageView3.snp.bottom).offset(10)
            $0.leading.equalTo(hotAccountImageView3.snp.leading)
            $0.width.height.equalTo(20) // 아이콘 크기
        }
        
        // 제목 레이블 레이아웃
        hotAccountProfileName3.snp.makeConstraints {
//            $0.centerY.equalTo(hotAccountProfileIcon2) // 아이콘과 수직 정렬
            $0.top.equalTo(hotAccountImageView3.snp.bottom).offset(13)
            $0.leading.equalTo(hotAccountProfileIcon3.snp.trailing).offset(8)
        }
        
        hotAccountImageView4.snp.makeConstraints { make in
            make.top.equalTo(hotAccountProfileIcon2.snp.bottom).offset(18)
            make.trailing.equalToSuperview()
//            make.width.equalTo(hotAccountContainerView.snp.width).multipliedBy(0.5).offset(-5)
            make.width.equalTo(160)
            make.height.equalTo(220)
        }
        
        hotAccountProfileIcon4.snp.makeConstraints {
            $0.top.equalTo(hotAccountImageView4.snp.bottom).offset(10)
            $0.leading.equalTo(hotAccountImageView2.snp.leading)
            $0.width.height.equalTo(20) // 아이콘 크기
        }
        
        // 제목 레이블 레이아웃
        hotAccountProfileName4.snp.makeConstraints {
//            $0.centerY.equalTo(hotAccountProfileIcon2) // 아이콘과 수직 정렬
            $0.top.equalTo(hotAccountImageView4.snp.bottom).offset(13)
            $0.leading.equalTo(hotAccountProfileIcon2.snp.trailing).offset(8)
        }
    }
    
    /// 데이터 상태에 따라 EmptyStackView 표시/숨김
    func updateFriendClothesEmptyState(isEmpty: Bool) {
        if isEmpty {
            // 데이터가 없으면 EmptyStackView 추가하고 관련 요소 숨김
            profileContainerView.addSubview(emptyStackView1)
            emptyStackView1.emptyClothesMessageTitle.text = "아직 팔로우한 계정이 없어요!"
            emptyStackView1.emptyClothesMessageSubTitle.text = "다른 사용자들을 팔로우하고\n어떤 옷들이 있는지 옷장을 구경해보세요"
            
            profileContainerView.snp.remakeConstraints { make in
                make.top.equalTo(friendClothesTitle.snp.bottom).offset(26)
                make.leading.trailing.equalToSuperview().inset(20)
                make.height.equalTo(179)
            }
            
            emptyStackView1.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            friendClothesBottomButtonLabel.isHidden = true
            friendClothesBottomArrowIcon.isHidden = true

        } else {
            // 데이터가 있으면 EmptyStackView 제거하고 관련 요소 표시
            emptyStackView1.removeFromSuperview()
            friendClothesBottomButtonLabel.isHidden = false
            friendClothesBottomArrowIcon.isHidden = false
            
            profileContainerView.snp.remakeConstraints { make in
                make.top.equalTo(friendClothesTitle.snp.bottom).offset(14)
                make.leading.trailing.equalToSuperview().inset(20)
                make.height.equalTo(179)
            }
        }
    }
    
    func updateFriendCalendarEmptyState(isEmpty: Bool) {
        if isEmpty {
            // 데이터가 없으면 EmptyStackView 추가하고 관련 요소 숨김
            followingCalendarUpdateContainerView.addSubview(emptyStackView2)
            emptyStackView2.emptyClothesMessageTitle.text = "아직 팔로우한 계정이 없어요!"
            emptyStackView2.emptyClothesMessageSubTitle.text = "다른 사용자들을 팔로우하고\n다양한 패션 기록을 구경해보세요"
            
            followingCalendarUpdateContainerView.snp.remakeConstraints { make in
                make.top.equalTo(followingCalendarUpdateTitle.snp.bottom).offset(26)
                make.leading.trailing.equalToSuperview().inset(20)
                make.height.equalTo(250) // 컨테이너 높이를 늘림
            }
            
            emptyStackView2.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            followingCalendarUpdateSubTitle.isHidden = true
            followingCalendarBottomButtonLabel.isHidden = true
            followingCalendarBottomArrowIcon.isHidden = true
            
            hotAccountTitle.snp.remakeConstraints { make in
                make.top.equalTo(followingCalendarUpdateContainerView.snp.bottom) // 기존보다 위로 조정
                make.leading.equalToSuperview().offset(20)
                make.width.equalTo(224)
                make.height.equalTo(24)
            }
            
        } else {
            // 데이터가 있으면 EmptyStackView 제거하고 관련 요소 표시
            emptyStackView2.removeFromSuperview()
            followingCalendarUpdateSubTitle.isHidden = false
            followingCalendarBottomButtonLabel.isHidden = false
            followingCalendarBottomArrowIcon.isHidden = false
            followingCalendarUpdateContainerView.snp.remakeConstraints { make in
                make.top.equalTo(followingCalendarUpdateSubTitle.snp.bottom).offset(11)
                make.leading.trailing.equalToSuperview().inset(20)
                make.height.equalTo(250) // 컨테이너 높이를 늘림
            }
            
            hotAccountTitle.snp.remakeConstraints { make in
                make.top.equalTo(followingCalendarBottomButtonLabel.snp.bottom).offset(26)
                make.leading.equalToSuperview().offset(20)
                make.width.equalTo(224)
                make.height.equalTo(24)
            }
        }
    }
}
