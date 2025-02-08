//
//  UpdateFriendClothesView.swift
//  Clokey
//
//  Created by 한금준 on 1/26/25.
//

import UIKit
import Then
import SnapKit

class UpdateFriendClothesView: UIView {
    
    /// 세로 스크롤을 지원하는 ScrollView
    let scrollView: UIScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false // 세로 스크롤바 숨김
    }

    /// ScrollView 내부 콘텐츠를 담는 ContentView
    let contentView: UIView = UIView().then {
        $0.backgroundColor = .white // 배경색 흰색
    }
    
    let titleLabel: UILabel = UILabel().then {
        let fullText = "친구의 옷장 업데이트 소식"
        let targetText = "옷장"
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
    
    /// 구분 선
    private let lineView = UIView().then {
        $0.backgroundColor = .systemGray5
    }
    
    let updateFriendClothesCollectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.itemSize = CGSize(width: 317, height: 154) // 셀 크기 설정
            $0.minimumInteritemSpacing = 8
            $0.minimumLineSpacing = 16 // 셀 간의 세로 간격
            $0.scrollDirection = .vertical // 세로 스크롤
            $0.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16) // 섹션 여백
        }
    ).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = true
        $0.register(UpdateFriendClothesCollectionViewCell.self, forCellWithReuseIdentifier: UpdateFriendClothesCollectionViewCell.identifier)
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
        backgroundColor = .white // 배경색 설정
        
        // ScrollView와 ContentView 추가
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(lineView)
//        contentView.addSubview(container)
        contentView.addSubview(updateFriendClothesCollectionView)

    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // 화면 전체에 ScrollView
        }
        
        // ContentView 제약 설정
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView) // ScrollView 내부에 맞춤
            make.width.equalToSuperview() // 가로 크기는 화면 크기와 동일
            make.bottom.equalTo(updateFriendClothesCollectionView.snp.bottom).offset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(21)
            make.leading.equalToSuperview().offset(20)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)  // 화면 전체 너비
            make.height.equalTo(1)  // 높이 1포인트
        }
        
//        container.snp.makeConstraints { make in
//            make.top.equalTo(lineView.snp.bottom) // 구분선 아래
//            make.leading.trailing.bottom.equalToSuperview() // 화면의 좌우 및 아래쪽 끝까지 확장
//        }
        
        updateFriendClothesCollectionView.snp.makeConstraints{ make in
            make.top.equalTo(lineView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(300) // 초기 높이 (1로 설정하여 콘텐츠 크기 업데이트 유도)
            
        }
        
    }

}
