//
//  UploadModalView.swift
//  Clokey
//
//  Created by 황상환 on 1/20/25.
//

import UIKit
import Then
import SnapKit

class UploadModalView: UIView {
    
    // MARK: - UI Components
    
    private let selectedDateLabel = UILabel().then {
        $0.text = "2025.01.18 (SAT)"
        $0.font = .ptdRegularFont(ofSize: 16)
        $0.textColor = .black
    }
    
    
    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "erase_icon"), for: .normal)
        $0.tintColor = .black
    }
    
    private let contentImage = UIImageView().then {
        $0.image = UIImage(named: "exclamation_mark_icon")
        $0.contentMode = .scaleAspectFit
    }
    
    private let contentLabel = UILabel().then {
        $0.text = "첫 번째 기록을 추가해보세요!"
        $0.font = .ptdRegularFont(ofSize: 16)
        $0.textColor = .black
    }
    
    private let addButtonStack = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 8
        $0.isUserInteractionEnabled = false
    }
    
    private let plusImageView = UIImageView().then {
        $0.image = UIImage(named: "modalPlus")
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = false
    }
    
    private let addButtonLabel = UILabel().then {
        $0.text = "지금 바로 기록하기"
        $0.font = .ptdRegularFont(ofSize: 16)
        $0.textColor = .white
        $0.isUserInteractionEnabled = false
    }
    
    private let addButton = UIButton().then {
        $0.backgroundColor = .mainBrown800
        $0.layer.cornerRadius = 10
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 20
        clipsToBounds = true // 내부 컨텐츠가 벗어나지 않게 해주는 설정
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        
        addSubview(selectedDateLabel)
        addSubview(closeButton)
        addSubview(contentImage)
        addSubview(contentLabel)
        addSubview(addButton)
        
        // 추가 버튼 스택
        addButtonStack.addArrangedSubview(plusImageView)
        addButtonStack.addArrangedSubview(addButtonLabel)
        addButton.addSubview(addButtonStack)
    }
    
    private func setupLayout() {
        selectedDateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(30)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(30)
        }
        
        contentImage.snp.makeConstraints {
            $0.top.equalTo(selectedDateLabel.snp.bottom).offset(81)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(65)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(contentImage.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        addButton.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(100)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(45)
            $0.width.equalTo(245)
        }
        
        addButtonStack.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        plusImageView.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
    }
    
    // 선택 날짜 가져오기
    func setDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd (E)"
        dateFormatter.locale = Locale(identifier: "en_US")
        selectedDateLabel.text = dateFormatter.string(from: date)
    }
    
    // 기록 추가하기 네비게이션 작업 
    func getAddButton() -> UIButton {
        return addButton
    }
}
