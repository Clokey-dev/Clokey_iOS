//
//  RecordOOTDView.swift
//  Clokey
//
//  Created by 황상환 on 1/20/25.
//

import UIKit
import SnapKit
import Then

class RecordOOTDView: UIView {
    
    // MARK: - UI Components
    // 사진/태그하기 뷰
    let photoTagView = PhotoTagView()
    
    // 그 외 텍스트뷰&태그하기 뷰
    let contentInputView = ContentInputView()
    
    // 전체 스크롤 뷰
    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = true // 인디케이터 표시
        $0.backgroundColor = .white
        $0.alwaysBounceVertical = true // 세로로 스크롤
    }
    
    // 스크롤 뷰 안의 ContentView
    private let contentView = UIView().then {
        $0.backgroundColor = .white
    }
    
    // 커스텀 완료 버튼
    let OOTDButton = CustomButton(title: "완료", isEnabled: false)
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(scrollView)
        addSubview(OOTDButton)  // 스크롤뷰와 별개로 추가
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(photoTagView)
        contentView.addSubview(contentInputView)
        
        setupConstraints()
    }

    private func setupConstraints() {
        // 완료 버튼 (먼저 설정)
        OOTDButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-10)
            $0.height.equalTo(54)
        }
        
        // 스크롤 뷰
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(OOTDButton.snp.top).offset(-20)
        }
        
        // contentView
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        // 사진 태그하기 뷰
        photoTagView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        // 내용 해시태그 공개범위 뷰
        contentInputView.snp.makeConstraints {
            $0.top.equalTo(photoTagView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    
    // MARK: - Public Methods
    
    // 갤러리에서 사진 선택 후, 업데이트
    func updateCollectionViewHeight(_ hasImages: Bool) {
        photoTagView.updateCollectionViewHeight(hasImages)
    }
}
