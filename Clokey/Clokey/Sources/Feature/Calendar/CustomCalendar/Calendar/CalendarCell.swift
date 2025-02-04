//
//  CalendarCell.swift
//  StudyUIKit
//
//  Created by 황상환 on 1/5/25.
//

import Foundation
import UIKit

class CalendarCell: UICollectionViewCell {
    
    // 날짜를 표시할 레이블
    private let dayLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .ptdBoldFont(ofSize: 12)
    }
    
    // 오늘 날짜 표시
    private let todayView = UIView().then {
        $0.backgroundColor = .pointOrange800
        $0.isHidden = true
        $0.layer.cornerRadius = 15
    }
   
    // 셀 초기화 메서드
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    // 각 셀의 이미지
    private let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // UI 설정 메서드
    private func setupUI() {
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(todayView) // 원형 뷰를 먼저 추가
        contentView.addSubview(dayLabel) // 레이블을 셀에 추가
//        contentView.layer.borderWidth = 0.5 // 셀 테두리 두께
//        contentView.layer.borderColor = UIColor.white.cgColor // 셀 테두리 색상

        // 셀 이미지
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 오늘 표시
        todayView.snp.makeConstraints {
            $0.center.equalTo(dayLabel)
            $0.width.height.equalTo(28)
        }
        // 레이블을 상하좌우 4포 여백
        dayLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    // 셀 구성 메서드
    func configure(day: Int, isSelected: Bool, isCurrentMonth: Bool, isToday: Bool, image: UIImage?) {
        dayLabel.text = isCurrentMonth ? "\(day)" : ""
        
        if isToday {
            todayView.isHidden = false
            dayLabel.textColor = .white
        } else {
            todayView.isHidden = true
            
            if isSelected {
                contentView.backgroundColor = .systemBlue.withAlphaComponent(0.3)
                dayLabel.textColor = .black
            } else {
                contentView.backgroundColor = .white
                dayLabel.textColor = .black
            }
        }

        // 이미지가 있으면 표시, 없으면 숨김
        if let image = image {
            todayView.isHidden = true
            dayLabel.textColor = .clear
            backgroundImageView.image = image
            backgroundImageView.isHidden = false
        } else {
            backgroundImageView.isHidden = true
        }
    }

}
