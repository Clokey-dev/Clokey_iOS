//
//  CalendarCell.swift
//  StudyUIKit
//
//  Created by 황상환 on 1/5/25.
//

import Foundation
import UIKit
import Kingfisher

class CalendarCell: UICollectionViewCell {
    
    // 날짜를 표시할 레이블
    private let dayLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .ptdBoldFont(ofSize: 12)
    }
    
    // OOTD 이미지
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
//        $0.layer.cornerRadius = 10
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // UI 설정 메서드
    private func setupUI() {
        contentView.addSubview(todayView) // 원형 뷰를 먼저 추가
        contentView.addSubview(dayLabel) // 레이블을 셀에 추가
        //        contentView.layer.borderWidth = 0.5 // 셀 테두리 두께
        //        contentView.layer.borderColor = UIColor.white.cgColor // 셀 테두리 색상
        contentView.addSubview(imageView)
        
        // 오늘 표시
        todayView.snp.makeConstraints {
            $0.center.equalTo(dayLabel)
            $0.width.height.equalTo(28)
        }
        
        // 날짜라벨
        dayLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        // OOTD 이미지
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // 셀 구성 메서드
    func configure(day: Int, isSelected: Bool, isCurrentMonth: Bool, isToday: Bool, imageUrl: String?) {
        dayLabel.text = isCurrentMonth ? "\(day)" : ""
        isUserInteractionEnabled = isCurrentMonth
        
        imageView.image = nil
        imageView.isHidden = !isCurrentMonth
        imageView.kf.cancelDownloadTask()

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
        
//        // 로딩 전 셀 리셋
//        imageView.image = nil
//        
//        // 이미지 로딩
//        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
//            todayView.isHidden = true
//            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
//        } else {
//            imageView.image = nil
//        }
        // 현재 달의 셀에만 이미지 표시
        if isCurrentMonth, let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            imageView.isHidden = false
            todayView.isHidden = true
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        }
    }
}
