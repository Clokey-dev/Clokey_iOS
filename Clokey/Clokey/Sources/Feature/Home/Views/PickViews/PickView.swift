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
    // EmptyStackView 선언
    private let emptyStackView = EmptyStackView()
    
    
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

    /// 어제와 비교한 기온 변화를 표시하는 레이블
    let temperatureChangeLabel: UILabel = UILabel().then {
        $0.text = "어제에 비해 기온이 변화 중..." // 기본 텍스트
        $0.textColor = .black // 텍스트 색상
        $0.backgroundColor = .clear
        $0.layer.borderColor = UIColor.brown.cgColor // 경계선 색상
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textAlignment = .center // 텍스트 중앙 정렬
        $0.layer.borderWidth = 1 // 경계선 두께
        $0.layer.cornerRadius = 10 // 모서리 둥글게 처리
        $0.clipsToBounds = true // 코너 반경 적용
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
        $0.layer.cornerRadius = 5 // 원하는 반경 설정
        $0.layer.masksToBounds = true // cornerRadius 적용 보장
    }
    
    let weatherImageName1: UILabel = UILabel().then {
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = .black // 텍스트 색상
        $0.textAlignment = .center // 텍스트 중앙 정렬
        $0.text = "회색 울 코트" // 기본 텍스트
    }

    /// 두 번째 의류 추천 이미지
    let weatherImageView2: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 5 // 원하는 반경 설정
        $0.layer.masksToBounds = true // cornerRadius 적용 보장
    }
    
    let weatherImageName2: UILabel = UILabel().then {
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = .black // 텍스트 색상
        $0.textAlignment = .center // 텍스트 중앙 정렬
        $0.text = "앙고라 패턴 니트" // 기본 텍스트
    }

    /// 세 번째 의류 추천 이미지
    let weatherImageView3: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 5 // 원하는 반경 설정
        $0.layer.masksToBounds = true // cornerRadius 적용 보장
    }
    
    let weatherImageName3: UILabel = UILabel().then {
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = .black // 텍스트 색상
        $0.textAlignment = .center // 텍스트 중앙 정렬
        $0.text = "스웨이드 자켓" // 기본 텍스트
    }
    
    /// '내 옷 보러가기' 버튼 텍스트 레이블
    let bottomButtonLabel: UILabel = UILabel().then {
        $0.text = "내 옷 보러가기" // 버튼 텍스트
        $0.textColor = .black // 텍스트 색상
        $0.font = UIFont.ptdMediumFont(ofSize: 12) // 폰트 크기
    }

    /// 버튼 옆의 화살표 아이콘
    let bottomArrowIcon: UIImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right") // 오른쪽 화살표
        $0.tintColor = .black // 색상 설정
        $0.contentMode = .scaleAspectFill // 크기 비율 유지
    }

    /// Recap 섹션의 타이틀 레이블
    let recapTitleLabel: UILabel = UILabel().then {
        $0.text = "Recap" // 타이틀 텍스트
        $0.textColor = .black // 텍스트 색상
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20) // 큰 폰트 크기
    }

    /// Recap 섹션의 부제목 레이블
    let recapSubtitleLabel1: UILabel = UILabel().then {
        $0.text = "1년 전 오늘, 00님의 기록이 없어요!"
        $0.textColor = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0) // 텍스트 색상
        $0.font = UIFont.ptdMediumFont(ofSize: 14) // 작은 폰트 크기
        $0.numberOfLines = 0 // 여러 줄 허용
    }
    
    let recapSubtitleLabel2: UILabel = UILabel().then {
        $0.text = "다른사용자들은 어떤 옷을 입었을까요?"
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
        $0.layer.cornerRadius = 5 // 원하는 반경 설정
        $0.layer.masksToBounds = true // cornerRadius 적용 보장
    }

    /// Recap 섹션의 두 번째 이미지
    let recapImageView2: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill // 비율 유지
        $0.clipsToBounds = true // 이미지가 뷰를 벗어나지 않게
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 5 // 원하는 반경 설정
        $0.layer.masksToBounds = true // cornerRadius 적용 보장
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
        contentView.addSubview(temperatureChangeLabel)
        contentView.addSubview(weatherImageContainerView)
        weatherImageContainerView.addSubview(weatherImageView1)
        weatherImageContainerView.addSubview(weatherImageName1)
        weatherImageContainerView.addSubview(weatherImageView2)
        weatherImageContainerView.addSubview(weatherImageName2)
        weatherImageContainerView.addSubview(weatherImageView3)
        weatherImageContainerView.addSubview(weatherImageName3)
        contentView.addSubview(bottomButtonLabel)
        contentView.addSubview(bottomArrowIcon)
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
            make.width.height.equalTo(26)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.centerY.equalTo(weatherIconView.snp.centerY)
            make.leading.equalTo(weatherIconView.snp.trailing).offset(0.89)
        }
        
        tempDetailsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(weatherIconView.snp.centerY)
            make.leading.equalTo(temperatureLabel.snp.trailing).offset(3)
        }
        
        temperatureChangeLabel.snp.makeConstraints { make in
            make.top.equalTo(tempDetailsLabel.snp.bottom).offset(10.89)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        weatherImageContainerView.snp.makeConstraints { make in
            make.top.equalTo(temperatureChangeLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(170)/*.priority(.medium) // 우선순위를 낮춤*/
        }
        
        weatherImageView1.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(weatherImageView2)
            make.height.equalTo(148) // 적절한 높이 설정
        }

        weatherImageName1.snp.makeConstraints { make in
            make.top.equalTo(weatherImageView1.snp.bottom).offset(5)
            make.leading.equalTo(weatherImageView1.snp.leading).offset(2)
        }

        weatherImageView2.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(weatherImageView1.snp.trailing).offset(10)
            make.width.equalTo(weatherImageView3)
            make.height.equalTo(weatherImageView1)
        }

        weatherImageName2.snp.makeConstraints { make in
            make.top.equalTo(weatherImageView2.snp.bottom).offset(5)
            make.leading.equalTo(weatherImageView2.snp.leading)
        }

        weatherImageView3.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(weatherImageView2.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
            make.width.equalTo(weatherImageView1)
            make.height.equalTo(weatherImageView1)
        }

        weatherImageName3.snp.makeConstraints { make in
            make.top.equalTo(weatherImageView3.snp.bottom).offset(5)
            make.leading.equalTo(weatherImageView3.snp.leading)
        }
        
        bottomButtonLabel.snp.makeConstraints { make in
            make.top.equalTo(weatherImageName3.snp.bottom).offset(15)
            make.trailing.equalToSuperview().inset(30)
        }
        
        bottomArrowIcon.snp.makeConstraints { make in
            make.centerY.equalTo(bottomButtonLabel.snp.centerY)
            make.leading.equalTo(bottomButtonLabel.snp.trailing).offset(5)
//            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(6)
            make.height.equalTo(12)
        }
        
        recapTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(bottomButtonLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
        }
        
        recapSubtitleLabel1.snp.makeConstraints { make in
            make.top.equalTo(recapTitleLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(20)
        }
        
        recapSubtitleLabel2.snp.makeConstraints { make in
            make.top.equalTo(recapSubtitleLabel1.snp.bottom).offset(4)
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
    
    /// Recap 섹션에 이미지와 데이터를 설정하는 메서드
        func updateRecapImages(with imageUrls: [String]) {
            if imageUrls.count > 0 {
                recapImageView1.image = loadImage(from: imageUrls[0])
            }
            if imageUrls.count > 1 {
                recapImageView2.image = loadImage(from: imageUrls[1])
            }
        }
        
        /// URL에서 이미지를 로드하는 헬퍼 메서드
        private func loadImage(from urlString: String) -> UIImage? {
            guard let url = URL(string: urlString),
                  let data = try? Data(contentsOf: url) else {
                return nil
            }
            return UIImage(data: data)
        }
    
    /// 데이터 상태에 따라 EmptyStackView 표시/숨김
    func updateEmptyState(isEmpty: Bool) {
        if isEmpty {
            // 데이터가 없으면 EmptyStackView 추가하고 관련 요소 숨김
            weatherImageContainerView.addSubview(emptyStackView)
            emptyStackView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            temperatureChangeLabel.isHidden = true
            bottomButtonLabel.isHidden = true
            bottomArrowIcon.isHidden = true
        } else {
            // 데이터가 있으면 EmptyStackView 제거하고 관련 요소 표시
            emptyStackView.removeFromSuperview()
            
            temperatureChangeLabel.isHidden = false
            bottomButtonLabel.isHidden = false
            bottomArrowIcon.isHidden = false
        }
    }
    
    func recapNotMe(hidden: Bool) {
        recapSubtitleLabel2.isHidden = hidden
        recapImageContainerView.snp.remakeConstraints { make in
            if hidden {
                make.top.equalTo(recapSubtitleLabel1.snp.bottom).offset(9)
            }
            else {
                recapImageContainerView.snp.remakeConstraints { make in
                    make.top.equalTo(recapSubtitleLabel2.snp.bottom).offset(9)
                }
            }
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(223.22)
            make.bottom.equalToSuperview().offset(-20) // 스크롤 콘텐츠의 마지막 부분
        }
    }
}


