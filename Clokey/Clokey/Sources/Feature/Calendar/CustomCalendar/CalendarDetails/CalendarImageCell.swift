//
//  CalendarImageCell.swift
//  Clokey
//
//  Created by 황상환 on 2/2/25.
//

import Foundation
import UIKit
import SnapKit
import Then
import Kingfisher

class CalendarImageCell: UICollectionViewCell {
    static let identifier = "CalendarImageCell"
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .lightGray
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with imageUrl: String) {
        // 기본 이미지 설정
        imageView.image = UIImage(named: "detail_main_Img")
        
        // URL이 유효한 경우에만 이미지 로드 시도
        if let url = URL(string: imageUrl) {
            imageView.kf.setImage(with: url)
        }
    }
}
