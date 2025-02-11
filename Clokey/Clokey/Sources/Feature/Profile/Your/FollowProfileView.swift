//
//  FollowProfileView.swift
//  Clokey
//
//  Created by 한금준 on 1/29/25.
//

import UIKit
import SnapKit
import Then

class FollowProfileView: UIView {

    /// 세로 스크롤을 지원하는 ScrollView
    let scrollView: UIScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    /// ScrollView 내부 콘텐츠를 담는 ContentView
    let contentView: UIView = UIView().then {
        $0.backgroundColor = .white // 배경색 흰색
    }
    
    // MARK: - UI Components
    let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = .black
    }
    
    let usernameLabel = UILabel().then {
        $0.text = "cake123(아이디란)"
        $0.font = UIFont.ptdMediumFont(ofSize: 20)
        $0.textAlignment = .center
    }
    
    let backgroundImageView = UIImageView().then {
        $0.image = UIImage(named: "profile_background")
        $0.backgroundColor = .systemGray6
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    let profileContainer: UIView = UIView().then {
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 50 // 원형으로 만들기 위해 반지름을 절반으로 설정
        $0.layer.masksToBounds = true // 자식 콘텐츠가 코너를 넘지 않도록 설정
    }
    
    let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "profile_icon")
    }
    
    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "클루"
        label.font = UIFont.ptdMediumFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    let statsLabel = UILabel().then {
        $0.text = "게시글 008  팔로워 027  팔로잉 032"
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    let descriptionLabel = UILabel().then {
        $0.text = "나는야공주"
        $0.font = UIFont.ptdRegularFont(ofSize: 14)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    let followButton = UIButton().then {
        $0.setTitle("팔로우", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .mainBrown800
        $0.layer.cornerRadius = 10
    }
    
    let clothesLabel = UILabel().then {
        $0.text = "옷장"
        $0.font = UIFont.boldSystemFont(ofSize: 18)
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
        $0.font = UIFont.ptdMediumFont(ofSize: 12) // 폰트 크기
    }
    
    /// 버튼 옆의 화살표 아이콘
    let bottomArrowIcon: UIImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right") // 오른쪽 화살표
        $0.tintColor = .black // 색상 설정
        $0.contentMode = .scaleAspectFill // 크기 비율 유지
    }
    
    let recordLabel = UILabel().then {
        $0.text = "기록"
        $0.font = UIFont.boldSystemFont(ofSize: 18)
        $0.textAlignment = .left
    }
    
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
        contentView.addSubview(backButton)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(profileContainer)
        profileContainer.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(statsLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(followButton)
        contentView.addSubview(clothesLabel)
        contentView.addSubview(clothesImageContainerView)
        clothesImageContainerView.addSubview(clothesImageView1)
        clothesImageContainerView.addSubview(clothesImageView2)
        clothesImageContainerView.addSubview(clothesImageView3)
        contentView.addSubview(bottomButtonLabel)
        contentView.addSubview(bottomArrowIcon)
        contentView.addSubview(recordLabel)
        contentView.addSubview(recordContainerView)
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
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(backgroundImageView.snp.top).offset(60)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(24)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.leading.equalTo(backButton.snp.trailing).offset(15)
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
        }
        
        statsLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(statsLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        followButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(13)
            make.centerX.equalToSuperview()
            make.width.equalTo(76)
            make.height.equalTo(30)
        }
        
        clothesLabel.snp.makeConstraints { make in
            make.top.equalTo(followButton.snp.bottom).offset(36)
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
    }
}
