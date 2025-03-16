//
//  LikeHistoryView.swift
//  Clokey
//
//  Created by 소민준 on 3/11/25.
//


import UIKit
import SnapKit
import Then
import Kingfisher

class LikeHistoryView: UIView {
    
    // 뒤로가기 버튼과 타이틀은 Safe Area를 기준으로 배치합니다.
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "goback"), for: .normal)
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .black
    }
    
    let titleLabel = UILabel().then {
        $0.text = "좋아요한 기록"
        $0.font = UIFont.ptdBoldFont(ofSize: 20)
        $0.textColor = .black
    }
    
    // 컬렉션 뷰: 셀 크기를 131×171, 여백 0으로 설정
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 131, height: 171)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.alwaysBounceVertical = true      // 항상 수직 바운스 활성화
            cv.isScrollEnabled = true 
        cv.register(LikeHistoryCell.self, forCellWithReuseIdentifier: LikeHistoryCell.identifier)
        if #available(iOS 11.0, *) {
            cv.contentInsetAdjustmentBehavior = .never
        }
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(collectionView)
        
        // 뒤로가기 버튼: safeArea 상단, 좌측 16pt, 크기 30×30
        backButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(10)
            make.height.equalTo(20)
            
        }
        
        // 타이틀: 뒤로가기 버튼 오른쪽 16pt, 가운데 정렬
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.leading.equalTo(backButton.snp.trailing).offset(16)
        }
        
        // 컬렉션 뷰: 뒤로가기 버튼 아래, safeArea 하단까지
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(25)
            make.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}
