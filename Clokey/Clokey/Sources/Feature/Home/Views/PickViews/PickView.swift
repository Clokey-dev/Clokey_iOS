//
//  PickView.swift
//  Clokey
//
//  Created by 한금준 on 1/11/25.
//

// 완료

import UIKit
import Then
import SnapKit

/// `PickView`는 사용자가 선택한 날씨와 관련된 의류 추천 화면을 구성
class PickView: UIView {
    
    /// 세로 스크롤을 지원하는 ScrollView
    let scrollView: UIScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false // 세로 스크롤바 숨김
    }

    /// ScrollView 내부 콘텐츠를 담는 ContentView
    let contentView: UIView = UIView().then {
        $0.backgroundColor = .white // 배경색 흰색
    }

    /// 현재 계절 정보를 표시하는 레이블
    let seasonLabel: UILabel = UILabel().then {
        $0.text = "겨울" // 계절명
        $0.textColor = .white // 텍스트 색상
        $0.backgroundColor = .mainBrown800 // 배경색
        $0.textAlignment = .center // 텍스트 중앙 정렬
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.layer.cornerRadius = 10 // 모서리 둥글게 처리
        $0.clipsToBounds = true // 코너 반경 적용
    }

    /// 위치 아이콘을 표시하는 이미지 뷰
    let locationIconView: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "location_icon") // 시스템 이미지 사용
        $0.contentMode = .scaleAspectFit // 이미지 크기 비율 유지
        $0.tintColor = .gray // 색상 변경
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

    /// 시간과 지역 정보를 표시하는 레이블
    let timeLabel: UILabel = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textColor = .gray // 텍스트 색상
        $0.textAlignment = .center // 텍스트 중앙 정렬
        $0.text = "12:00 PM 대한민국 ??? 기준" // 기본 텍스트
    }

    /// 최고/최저 기온을 표시하는 레이블
    let tempDetailsLabel: UILabel = UILabel().then {
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .darkGray // 텍스트 색상
        $0.textAlignment = .center // 텍스트 중앙 정렬
        $0.text = "(최고: 3°, 최저: -3°)" // 기본 텍스트
    }

    /// 어제와 비교한 기온 변화를 표시하는 레이블
    let temperatureChangeLabel: UILabel = UILabel().then {
        $0.text = "어제에 비해 기온이 변화 중..." // 기본 텍스트
        $0.textColor = .white // 텍스트 색상
        $0.backgroundColor = .mainBrown800 // 배경색
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textAlignment = .center // 텍스트 중앙 정렬
        $0.layer.cornerRadius = 10 // 모서리 둥글게 처리
        $0.clipsToBounds = true // 코너 반경 적용
    }
    
    /// '내 옷 보러가기' 버튼 텍스트 레이블
    let bottomButtonLabel: UILabel = UILabel().then {
        $0.text = "내 옷 보러가기" // 버튼 텍스트
        $0.textColor = .black // 텍스트 색상
        $0.font = UIFont.ptdBoldFont(ofSize: 12) // 폰트 크기
    }

    /// 버튼 옆의 화살표 아이콘
    let bottomArrowIcon: UIImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right") // 오른쪽 화살표
        $0.tintColor = .black // 색상 설정
        $0.contentMode = .scaleAspectFit // 크기 비율 유지
    }

    /// 날씨에 따른 추천 의류 이미지 컨테이너 뷰
    let weatherImageContainerView: UIView = UIView().then {
        $0.backgroundColor = .clear
    }

    /// 첫 번째 의류 추천 이미지
    let weatherImageView1: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }

    /// 두 번째 의류 추천 이미지
    let weatherImageView2: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }

    /// 세 번째 의류 추천 이미지
    let weatherImageView3: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
    }

    /// Recap 섹션의 타이틀 레이블
    let recapTitleLabel: UILabel = UILabel().then {
        $0.text = "Recap" // 타이틀 텍스트
        $0.textColor = .black // 텍스트 색상
        $0.font = UIFont.ptdBoldFont(ofSize: 24) // 큰 폰트 크기
    }

    /// Recap 섹션의 부제목 레이블
    let recapSubtitleLabel: UILabel = UILabel().then {
        $0.text = "1년 전 오늘, 00님은 이 옷을 착용하셨네요!" // 부제목 텍스트
        $0.textColor = .darkGray // 텍스트 색상
        $0.font = UIFont.ptdMediumFont(ofSize: 16) // 작은 폰트 크기
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
        contentView.addSubview(seasonLabel)
        contentView.addSubview(locationIconView)
        contentView.addSubview(weatherIconView)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(tempDetailsLabel)
        contentView.addSubview(temperatureChangeLabel)
        contentView.addSubview(weatherImageContainerView)
        weatherImageContainerView.addSubview(weatherImageView1)
        weatherImageContainerView.addSubview(weatherImageView2)
        weatherImageContainerView.addSubview(weatherImageView3)
        contentView.addSubview(bottomButtonLabel)
        contentView.addSubview(bottomArrowIcon)
        contentView.addSubview(recapTitleLabel)
        contentView.addSubview(recapSubtitleLabel)
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
        
        // 기존 UI 요소 제약 추가
        seasonLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(26)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(seasonLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        
        locationIconView.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        weatherIconView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(50)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.centerY.equalTo(weatherIconView.snp.centerY)
            make.leading.equalTo(weatherIconView.snp.trailing).offset(10)
        }
        
        tempDetailsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(weatherIconView.snp.centerY)
            make.leading.equalTo(temperatureLabel.snp.trailing).offset(10)
        }
        
        temperatureChangeLabel.snp.makeConstraints { make in
            make.top.equalTo(tempDetailsLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        weatherImageContainerView.snp.makeConstraints { make in
            make.top.equalTo(temperatureChangeLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(164) // 고정 높이 설정
        }
        
        weatherImageView1.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview() // 상하 배치 고정
            make.leading.equalToSuperview() // 좌측 고정
            make.width.equalTo(112) // 고정 너비 설정
        }
        
        weatherImageView2.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview() // 상하 배치 고정
            make.leading.equalTo(weatherImageView1.snp.trailing).offset(9)
            make.width.equalTo(112) // 고정 너비 설정
        }
        
        weatherImageView3.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview() // 상하 배치 고정
            make.leading.equalTo(weatherImageView2.snp.trailing).offset(9)
            make.width.equalTo(112) // 고정 너비 설정
            make.trailing.equalToSuperview() // 우측 고정
        }
        
        bottomButtonLabel.snp.makeConstraints { make in
            make.top.equalTo(weatherImageContainerView.snp.bottom).offset(10)
            make.trailing.equalToSuperview().inset(30)
        }
        
        bottomArrowIcon.snp.makeConstraints { make in
            make.centerY.equalTo(bottomButtonLabel.snp.centerY)
            make.leading.equalTo(bottomButtonLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(6)
            make.height.equalTo(12)
        }
        
        recapTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(bottomButtonLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        recapSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(recapTitleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        recapImageContainerView.snp.makeConstraints { make in
            make.top.equalTo(recapSubtitleLabel.snp.bottom).offset(10)
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
