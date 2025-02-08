//
//  PickNothingView.swift
//  Clokey
//
//  Created by 한금준 on 1/31/25.
//

import UIKit

class PickNothingView: UIView {

    /// 세로 스크롤을 지원하는 ScrollView
    let scrollView: UIScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false // 세로 스크롤바 숨김
    }

    /// ScrollView 내부 콘텐츠를 담는 ContentView
    let contentView: UIView = UIView().then {
        $0.backgroundColor = .white // 배경색 흰색
    }
    
    /// 시간과 지역 정보를 표시하는 레이블
    let timeLabel: UILabel = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .black // 텍스트 색상
        $0.textAlignment = .center // 텍스트 중앙 정렬
        $0.text = "12:00 PM 대한민국 ??? 기준" // 기본 텍스트
    }

    /// 위치 아이콘을 표시하는 이미지 뷰
    let locationIconView: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "location_icon") // 시스템 이미지 사용
        $0.contentMode = .scaleAspectFit // 이미지 크기 비율 유지
    }

    /// 날씨 상태를 표시하는 이미지 뷰
    let weatherIconView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit // 이미지 비율 유지
    }

    /// 현재 온도를 표시하는 레이블
    let temperatureLabel: UILabel = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 20)
        $0.textAlignment = .center // 텍스트 중앙 정렬
        $0.text = "-1°C" // 기본 텍스트
    }

    /// 최고/최저 기온을 표시하는 레이블
    let tempDetailsLabel: UILabel = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .black // 텍스트 색상
        $0.textAlignment = .center // 텍스트 중앙 정렬
        $0.text = "(최고: 3°, 최저: -3°)" // 기본 텍스트
    }
    
    let emptyIcon: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(systemName: "exclamationmark.circle")
        $0.tintColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1.0)
    }
    
    let emptyClothesMessageTitle: UILabel = UILabel().then {
        $0.text = "아직 추가한 옷이 없어요!"
        $0.textColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1.0)
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }


    /// 추가된 옷이 없을 때 메시지를 표시하는 레이블
    let emptyClothesMessageSubTitle: UILabel = UILabel().then {
        $0.text = "내 옷장에 옷을 추가해서\n기온에 맞는 옷을 매일 추천받아 보세요."
        $0.textColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1.0)
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
 

    /// Recap 섹션의 타이틀 레이블
    let recapTitleLabel: UILabel = UILabel().then {
        $0.text = "Recap" // 타이틀 텍스트
        $0.textColor = .black // 텍스트 색상
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20) // 큰 폰트 크기
    }

    /// Recap 섹션의 부제목 레이블
    let recapSubtitleLabel1: UILabel = UILabel().then {
        $0.text = "1년 전 오늘, 00님의 기록이 없어요!" // 부제목 텍스트
        $0.textColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0) // 텍스트 색상
        $0.font = UIFont.ptdMediumFont(ofSize: 14) // 작은 폰트 크기
        $0.numberOfLines = 0 // 여러 줄 허용
    }
    
    let recapSubtitleLabel2: UILabel = UILabel().then {
        $0.text = "다른 사용자들은 어떤 옷을 입었을까요?" // 부제목 텍스트
        $0.textColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0) // 텍스트 색상
        $0.font = UIFont.ptdMediumFont(ofSize: 14) // 작은 폰트 크기
        $0.numberOfLines = 0 // 여러 줄 허용
    }

    /// Recap 섹션의 이미지 컨테이너 뷰
    let recapImageContainerView: UIView = UIView().then {
        $0.backgroundColor = .clear
    }

    /// Recap 섹션의 첫 번째 이미지
    let recapImageView1: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }

    /// Recap 섹션의 두 번째 이미지
    let recapImageView2: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }
    
    // MARK: - Initializer
    
    /// 초기화 메서드
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI() // UI 구성
        setupConstraints() // 제약 조건 설정
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// UI 구성 요소를 추가하는 메서드
    private func setupUI() {
        backgroundColor = .white // 배경색 설정
        
        // ScrollView와 ContentView 추가
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // ContentView 내부에 기존 UI 요소 추가
        contentView.addSubview(locationIconView)
        contentView.addSubview(weatherIconView)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(tempDetailsLabel)
        contentView.addSubview(emptyIcon)
        contentView.addSubview(emptyClothesMessageTitle)
        contentView.addSubview(emptyClothesMessageSubTitle)
        contentView.addSubview(recapTitleLabel)
        contentView.addSubview(recapSubtitleLabel1)
        contentView.addSubview(recapSubtitleLabel2)
        contentView.addSubview(recapImageContainerView)
        recapImageContainerView.addSubview(recapImageView1)
        recapImageContainerView.addSubview(recapImageView2)
    }
    
    private func setupConstraints() {
        // ScrollView 제약 설정
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // 화면 전체에 ScrollView
        }
        
        // ContentView 제약 설정
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView) // ScrollView 내부에 맞춤
            make.width.equalToSuperview() // 가로 크기는 화면 크기와 동일
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(21)
            make.leading.equalToSuperview().offset(20)
        }
        
        locationIconView.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        weatherIconView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(30)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.centerY.equalTo(weatherIconView.snp.centerY)
            make.leading.equalTo(weatherIconView.snp.trailing).offset(0.89)
        }
        
        tempDetailsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(weatherIconView.snp.centerY)
            make.leading.equalTo(temperatureLabel.snp.trailing).offset(3)
        }
        
        emptyIcon.snp.makeConstraints { make in
            make.top.equalTo(tempDetailsLabel.snp.bottom).offset(47.89)
            make.centerX.equalToSuperview()
            make.size.equalTo(55)
        }
        
        emptyClothesMessageTitle.snp.makeConstraints { make in
            make.top.equalTo(emptyIcon.snp.bottom).offset(20)
            make.centerX.equalTo(emptyIcon)
        }
        
        emptyClothesMessageSubTitle.snp.makeConstraints { make in
            make.top.equalTo(emptyClothesMessageTitle.snp.bottom).offset(13)
            make.centerX.equalTo(emptyClothesMessageTitle)
        }
        
        recapTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyClothesMessageSubTitle.snp.bottom).offset(47)
            make.leading.equalToSuperview().offset(20)
        }
        
        recapSubtitleLabel1.snp.makeConstraints { make in
            make.top.equalTo(recapTitleLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(20)
        }
        recapSubtitleLabel2.snp.makeConstraints { make in
            make.top.equalTo(recapSubtitleLabel1.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
        }
        
        recapImageContainerView.snp.makeConstraints { make in
            make.top.equalTo(recapSubtitleLabel2.snp.bottom).offset(9)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(223.22)
            make.bottom.equalToSuperview().offset(-20) // 스크롤 콘텐츠의 마지막 부분
        }
        
        recapImageView1.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(recapImageContainerView.snp.width).multipliedBy(0.5).offset(-5)
        }
        
        recapImageView2.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(recapImageContainerView.snp.width).multipliedBy(0.5).offset(-5)
        }
    }

}
