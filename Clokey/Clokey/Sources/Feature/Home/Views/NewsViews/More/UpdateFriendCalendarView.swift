//
//  UpdateFriendCalendarView.swift
//  Clokey
//
//  Created by 한금준 on 1/17/25.
//

// 완료

import UIKit
import Then
import SnapKit

class UpdateFriendCalendarView: UIView {
    
    // MARK: - UI Elements
    let scrollView: UIScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    let contentView: UIView = UIView().then {
        $0.backgroundColor = .white
    }
    
    let updateFriendCalendarCollectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.estimatedItemSize = .init(width: 171, height: 251)
            $0.minimumInteritemSpacing = 8
        }
    ).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = true
        $0.register(UpdateFriendCalendarCollectionViewCell.self, forCellWithReuseIdentifier: UpdateFriendCalendarCollectionViewCell.identifier)
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
        contentView.addSubview(updateFriendCalendarCollectionView)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        // ContentView 제약 설정
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView) // ScrollView 내부에 맞춤
            make.width.equalToSuperview() // 가로 크기는 화면 크기와 동일
            make.bottom.equalTo(updateFriendCalendarCollectionView.snp.bottom).offset(20)
            
        }
        
        updateFriendCalendarCollectionView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(300) // 초기 높이 (1로 설정하여 콘텐츠 크기 업데이트 유도)
            
        }
    }
}
