//
//  HomeView.swift
//  Clokey
//
//  Created by 한금준 on 1/10/25.
//

// 완료

import UIKit
import SnapKit
import Then

/// `HomeView`는 메인 화면의 UI를 구성하는 뷰
final class HomeView: UIView {
    
    /// 'PICK' 버튼 (좌측 탭 버튼)
    let pickButton = UIButton(type: .system).then {
        $0.setTitle("PICK", for: .normal) // 버튼 텍스트
        $0.setTitleColor(.mainBrown800, for: .normal) // 버튼 텍스트 색상
        $0.titleLabel?.font = UIFont.ptdSemiBoldFont(ofSize: 20) // 폰트 설정
        $0.tag = TabType.pick.rawValue // TabType.pick의 값과 연결
    }
    
    /// '소식' 버튼 (우측 탭 버튼)
    let newsButton = UIButton(type: .system).then {
        $0.setTitle("소식", for: .normal) // 버튼 텍스트
        $0.setTitleColor(UIColor(red: 78/255, green: 52/255, blue: 46/255, alpha: 0.5), for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 20) // 폰트 설정
        $0.tag = TabType.news.rawValue // TabType.news의 값과 연결
    }
    
    /// 탭 버튼 아래 구분선을 표시하는 뷰
    let separatorLine = UIView().then {
        $0.backgroundColor = UIColor(red: 52/255, green: 52/255, blue: 52/255, alpha: 0.5) // 구분선 색상
    }
    
    /// 선택된 탭을 표시하는 인디케이터 뷰
    let indicatorView = UIView().then {
        $0.backgroundColor = .mainBrown800 // 기본 색상
        $0.layer.cornerRadius = 2 // 모서리 반경
    }
    
    /// 탭 아래의 컨텐츠를 표시하는 컨테이너 뷰
    let containerView = UIView().then {
        $0.backgroundColor = .white // 배경색
    }
    
    // MARK: - Initializers
    
    /// `HomeView`의 기본 초기화 메서드
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI() // UI 설정
    }
    
    /// 인터페이스 빌더에서 호출되는 초기화 메서드
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI() // UI 설정
    }
    
    // MARK: - UI Setup
    
    /// UI 구성 요소를 추가하고 레이아웃을 설정합니다.
    private func setupUI() {
        backgroundColor = .white // 뷰 배경색 설정
        
        // Subview 추가
        addSubview(pickButton)
        addSubview(newsButton)
        addSubview(separatorLine)
        addSubview(indicatorView)
        addSubview(containerView)
        
        // MARK: - Layout Constraints
        
        // PICK 버튼 레이아웃 설정
        pickButton.snp.makeConstraints { make in
            make.leading.equalToSuperview() // 왼쪽 끝에 배치
            make.top.equalTo(safeAreaLayoutGuide).offset(12) // 안전 영역 위쪽에 배치
            make.width.equalToSuperview().multipliedBy(0.5) // 너비: 화면 절반
            make.height.equalTo(28) // 높이: 50
        }
        
        // 소식 버튼 레이아웃 설정
        newsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview() // 오른쪽 끝에 배치
            make.top.equalTo(safeAreaLayoutGuide).offset(12) // 안전 영역 위쪽에 배치
            make.width.equalToSuperview().multipliedBy(0.5) // 너비: 화면 절반
            make.height.equalTo(28) // 높이: 50
        }
        
        // 구분선 레이아웃 설정
        separatorLine.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20) // 왼쪽에 20px 여백
            make.trailing.equalToSuperview().inset(20) // 오른쪽에 20px 여백
            make.top.equalTo(pickButton.snp.bottom).offset(4) // 버튼 바로 아래
            make.height.equalTo(0.5) // 높이: 0.5 (얇은 선)
        }
        
        // 인디케이터 뷰 레이아웃 설정
        indicatorView.snp.makeConstraints { make in
            make.centerX.equalTo(pickButton.snp.centerX) // PICK 버튼 중앙에 위치
//            make.bottom.equalTo(separatorLine.snp.top) // 구분선 바로 위
            make.bottom.equalTo(pickButton.snp.bottom).offset(6)
            make.height.equalTo(5) // 높이: 5
//            make.width.equalTo(pickButton.snp.width).multipliedBy(0.5) // 너비: PICK 버튼 절반
            make.width.equalTo(88)
        }
        
        // 컨테이너 뷰 레이아웃 설정
        containerView.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom) // 구분선 아래
            make.leading.trailing.bottom.equalToSuperview() // 화면의 좌우 및 아래쪽 끝까지 확장
        }
        
    }
}

