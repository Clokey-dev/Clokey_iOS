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
    
    // 로딩 인디케이터
    let loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.color = UIColor(named: "pointOrange800")
        $0.hidesWhenStopped = true
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = true
    }
    
    // 터치 차단을 뷰
    let touchBlockingView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.1) // 반투명 배경
        $0.isUserInteractionEnabled = true
        $0.isHidden = true // 기본적으로 숨김
    }

    
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
        addSubview(loadingIndicator)
        addSubview(touchBlockingView)

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
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        touchBlockingView.snp.makeConstraints {
            $0.edges.equalToSuperview() // 전체 화면을 덮음
        }
    }
    
    
    // MARK: - Public Methods
    
    // 갤러리에서 사진 선택 후, 업데이트
    func updateCollectionViewHeight(_ hasImages: Bool) {
        photoTagView.updateCollectionViewHeight(hasImages)
    }
    
    func showTouchBlockingView() {
        touchBlockingView.isHidden = false
        bringSubviewToFront(touchBlockingView) // 최상단으로 올림
        bringSubviewToFront(loadingIndicator) // 로딩 인디케이터도 같이 보이도록 설정
    }

    func hideTouchBlockingView() {
        touchBlockingView.isHidden = true
    }

}
