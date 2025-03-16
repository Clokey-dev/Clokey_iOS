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

    let updateFriendClothesCollectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.itemSize = CGSize(width: 317, height: 176) // 셀 크기 설정
            $0.minimumInteritemSpacing = 8
            $0.minimumLineSpacing = 16 // 셀 간의 세로 간격
            $0.scrollDirection = .vertical // 세로 스크롤
            $0.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0) // 섹션 여백
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
        contentView.addSubview(updateFriendClothesCollectionView)

    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
//            make.edges.equalToSuperview() // 화면 전체에 ScrollView
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        // ContentView 제약 설정
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView) // ScrollView 내부에 맞춤
            make.width.equalToSuperview() // 가로 크기는 화면 크기와 동일
            make.bottom.equalTo(updateFriendClothesCollectionView.snp.bottom).offset(20)
        }
        
        
        updateFriendClothesCollectionView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(300) // 초기 높이 (1로 설정하여 콘텐츠 크기 업데이트 유도)

        }
        
    }

}
