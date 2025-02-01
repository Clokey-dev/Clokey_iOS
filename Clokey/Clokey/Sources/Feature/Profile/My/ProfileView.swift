//
//  ProfileView.swift
//  Clokey
//
//  Created by 황상환 on 1/10/25.
//

import Foundation
import UIKit
import SnapKit
import Then

final class ProfileView: UIView {
    /// 세로 스크롤을 지원하는 ScrollView
    let scrollView: UIScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    /// ScrollView 내부 콘텐츠를 담는 ContentView
    let contentView: UIView = UIView().then {
        $0.backgroundColor = .white // 배경색 흰색
    }
    
    let usernameLabel = UILabel().then {
        $0.text = "cake123"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    let editButton = UIButton().then {
        $0.setImage(UIImage(named: "write_icon"), for: .normal)
        $0.tintColor = .black
    }
    
    let settingButton = UIButton().then {
        $0.setImage(UIImage(named: "setting_icon"), for: .normal)
        $0.tintColor = .black
    }
    
    let backgroundImageView = UIImageView().then {
        $0.image = UIImage(named: "profile_background")
        $0.backgroundColor = UIColor(red: 255/255, green: 248/255, blue: 235/255, alpha: 1.0)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    let profileContainer: UIView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 50 // 원형으로 만들기 위해 반지름을 절반으로 설정
        $0.layer.masksToBounds = true // 자식 콘텐츠가 코너를 넘지 않도록 설정
    }
    
    let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 50
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "profile_test")
    }
    
    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "초키(닉네임란)"
        label.font = UIFont.ptdMediumFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    let profileDetailContainer: UIView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let writeLabel = UILabel().then {
        $0.text = "게시글"
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    let writeCountLabel = UILabel().then {
        $0.text = "000"
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    let followerLabel = UILabel().then {
        $0.text = "팔로워"
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    let followerCountButton = UIButton().then {
        $0.setTitle("000", for: .normal)
        $0.titleLabel?.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.textAlignment = .center
        //        $0.addTarget(self, action: #selector(followingCountTapped), for: .touchUpInside)
    }
    
    let followingLabel = UILabel().then {
        $0.text = "팔로잉"
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    let followingCountButton = UIButton().then {
        $0.setTitle("000", for: .normal)
        $0.titleLabel?.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.textAlignment = .center
        //        $0.addTarget(self, action: #selector(followingCountTapped), for: .touchUpInside)
    }
    
    let descriptionLabel = UILabel().then {
        $0.text = "한줄소개란입니다아아아아아아아아"
        $0.font = UIFont.ptdRegularFont(ofSize: 14)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    let clothesLabel = UILabel().then {
        $0.text = "옷장"
        $0.font = UIFont.ptdRegularFont(ofSize: 20)
        $0.textAlignment = .left
    }
    
    /// 날씨에 따른 추천 의류 이미지 컨테이너 뷰
    let clothesImageContainerView: UIView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    /// 첫 번째 의류 추천 이미지
    let clothesImageView1: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }
    
    /// 두 번째 의류 추천 이미지
    let clothesImageView2: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }
    
    /// 세 번째 의류 추천 이미지
    let clothesImageView3: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }
    
    /// '내 옷 보러가기' 버튼 텍스트 레이블
    let bottomButtonLabel: UILabel = UILabel().then {
        $0.text = "옷장 구경하기" // 버튼 텍스트
        $0.textColor = .black // 텍스트 색상
        $0.font = UIFont.systemFont(ofSize: 12) // 폰트 크기
    }
    
    /// 버튼 옆의 화살표 아이콘
    let bottomArrowIcon: UIImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right") // 오른쪽 화살표
        $0.tintColor = .black // 색상 설정
        $0.contentMode = .scaleAspectFill // 크기 비율 유지
    }
    
    let recordLabel = UILabel().then {
        $0.text = "기록"
        $0.font = UIFont.ptdRegularFont(ofSize: 20)
        $0.textAlignment = .left
    }
    
    let calendarView = CalendarView()
    
    let recordContainerView: UIView = UIView().then {
        $0.backgroundColor = .gray
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(editButton)
        contentView.addSubview(settingButton)
        contentView.addSubview(profileContainer)
        profileContainer.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(profileDetailContainer)
        profileDetailContainer.addSubview(writeLabel)
        profileDetailContainer.addSubview(writeCountLabel)
        profileDetailContainer.addSubview(followerLabel)
        profileDetailContainer.addSubview(followerCountButton)
        profileDetailContainer.addSubview(followingLabel)
        profileDetailContainer.addSubview(followingCountButton)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(clothesLabel)
        contentView.addSubview(clothesImageContainerView)
        clothesImageContainerView.addSubview(clothesImageView1)
        clothesImageContainerView.addSubview(clothesImageView2)
        clothesImageContainerView.addSubview(clothesImageView3)
        contentView.addSubview(bottomButtonLabel)
        contentView.addSubview(bottomArrowIcon)
        contentView.addSubview(recordLabel)
        contentView.addSubview(recordContainerView)
        
        recordContainerView.addSubview(calendarView)
    }
    
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // 화면 전체에 ScrollView
        }
        
        // ContentView 제약 설정
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView) // ScrollView 내부에 맞춤
            make.width.equalToSuperview() // 가로 크기는 화면 크기와 동일
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.width.equalTo(393)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(72)
            make.leading.equalToSuperview().offset(20)
        }
        
        editButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(72)
            make.trailing.equalToSuperview().inset(67)
            make.width.equalTo(19)
            make.height.equalTo(20)
        }
        
        settingButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(72)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        profileContainer.snp.makeConstraints { make in
            make.top.equalTo(backgroundImageView.snp.bottom).offset(-50)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(13)
            make.centerX.equalToSuperview()
            make.height.equalTo(24)
        }
        
        profileDetailContainer.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.height.equalTo(24)
        }
        
        writeLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        writeCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(writeLabel.snp.trailing).offset(8)
            make.centerY.equalTo(writeLabel)
        }
        
        followerLabel.snp.makeConstraints { make in
            make.leading.equalTo(writeCountLabel.snp.trailing).offset(20)
            make.centerY.equalTo(writeCountLabel)
        }
        
        followerCountButton.snp.makeConstraints { make in
            make.leading.equalTo(followerLabel.snp.trailing).offset(8)
            make.centerY.equalTo(followerLabel)
        }
        
        followingLabel.snp.makeConstraints { make in
            make.leading.equalTo(followerCountButton.snp.trailing).offset(20)
            make.centerY.equalTo(followerCountButton)
        }
        
        followingCountButton.snp.makeConstraints { make in
            make.leading.equalTo(followingLabel.snp.trailing).offset(8)
            make.centerY.equalTo(followingLabel)
            make.trailing.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(profileDetailContainer.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        clothesLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(36)
            make.leading.equalToSuperview().offset(20)
        }
        
        clothesImageContainerView.snp.makeConstraints { make in
            make.top.equalTo(clothesLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(164) // 고정 높이 설정
        }
        
        clothesImageView1.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview() // 상하 배치 고정
            make.leading.equalToSuperview() // 좌측 고정
            make.width.equalTo(112) // 고정 너비 설정
        }
        
        clothesImageView2.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview() // 상하 배치 고정
            make.leading.equalTo(clothesImageView1.snp.trailing).offset(9)
            make.width.equalTo(112) // 고정 너비 설정
        }
        
        clothesImageView3.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview() // 상하 배치 고정
            make.leading.equalTo(clothesImageView2.snp.trailing).offset(9)
            make.width.equalTo(112) // 고정 너비 설정
            make.trailing.equalToSuperview() // 우측 고정
        }
        
        bottomButtonLabel.snp.makeConstraints { make in
            make.top.equalTo(clothesImageContainerView.snp.bottom).offset(8)
            make.trailing.equalToSuperview().inset(30)
        }
        
        bottomArrowIcon.snp.makeConstraints { make in
            make.centerY.equalTo(bottomButtonLabel.snp.centerY)
            make.leading.equalTo(bottomButtonLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(6)
            make.height.equalTo(12)
        }
        
        recordLabel.snp.makeConstraints { make in
            make.top.equalTo(bottomButtonLabel.snp.bottom).offset(36)
            make.leading.equalToSuperview().offset(20)
        }
        
        recordContainerView.snp.makeConstraints { make in
            make.top.equalTo(recordLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(520)
            make.bottom.equalToSuperview().offset(-40) // 스크롤 콘텐츠의 마지막 부분
        }
        
        calendarView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10) // 내부 패딩 적용
        }
    }
}
