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
    
    let title: UILabel = UILabel().then {
        $0.text = "친구의 캘린더 업데이트 소식"
        $0.font = UIFont.ptdMediumFont(ofSize: 20)
        $0.textColor = .black
    }
    
    let subTitle: UILabel = UILabel().then {
        $0.text = "24.01.08"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .mainBrown400
    }
    
    let updateFriendCalendarCollectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.estimatedItemSize = .init(width: 171, height: 248)
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
        
        // 데이터를 로드한 후 컬렉션 뷰 갱신
        DispatchQueue.main.async { [weak self] in
            self?.updateFriendCalendarCollectionView.reloadData()
            self?.updateCollectionViewHeight()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(title)
        contentView.addSubview(subTitle)
        contentView.addSubview(updateFriendCalendarCollectionView)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // 화면 전체에 ScrollView
        }
        
        // ContentView 제약 설정
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView) // ScrollView 내부에 맞춤
            make.width.equalToSuperview() // 가로 크기는 화면 크기와 동일
            make.bottom.equalTo(updateFriendCalendarCollectionView.snp.bottom).offset(20)
            
        }
        
        // Layout using SnapKit
        // 기존 UI 요소 제약 추가
        title.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(224)
            make.height.equalTo(24)
        }
        subTitle.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(233)
            make.height.equalTo(16)
        }
        
        updateFriendCalendarCollectionView.snp.makeConstraints{ make in
            make.top.equalTo(subTitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1) // 초기 높이 (1로 설정하여 콘텐츠 크기 업데이트 유도)
            
        }
    }
    
    private func updateCollectionViewHeight() {
        updateFriendCalendarCollectionView.layoutIfNeeded()
        let contentHeight = updateFriendCalendarCollectionView.contentSize.height
        print("Content Height: \(contentHeight)") // 디버깅용 출력
        
        updateFriendCalendarCollectionView.snp.updateConstraints { make in
            make.height.equalTo(contentHeight)
        }
    }
    
}
