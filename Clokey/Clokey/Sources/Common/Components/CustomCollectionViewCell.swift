//
//  Custom3CollectionViewCell.swift
//  Clokey
//
//  Created by 황상환 on 1/24/25.
//

import Foundation
import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CustomCollectionViewCell"
    
    // 체크 기능 on/off
    var isSelectable: Bool = false {
        didSet {
            overlayView.isHidden = !isSelectable
            checkmarkImageView.isHidden = !isSelectable
        }
    }
        
    // 상품 이미지
    let productImageView = UIImageView().then{
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
    }
    
    // 상품 넘버링
    let numberLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        $0.textColor = .white
        $0.backgroundColor = UIColor.mainBrown600
        $0.textAlignment = .center
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
    }
    
    // N회 라벨
    let countLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .white
        $0.backgroundColor = UIColor.mainBrown600
        $0.textAlignment = .center
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        
    }
    
    // 상품 이름 라벨
    let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .black
        $0.textAlignment = .left
    }

    
    // 어두운 배경
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.layer.cornerRadius = 5
        view.isHidden = true
        return view
    }()
    
    // 체크 아이콘
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "check_circle_icon")
        imageView.isHidden = true
        return imageView
    }()
    
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    
    // MARK: - Setup
    func setupViews() {
        // 셀의 콘텐츠 뷰에 추가
        contentView.addSubview(productImageView)
        contentView.addSubview(numberLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(overlayView)
        contentView.addSubview(checkmarkImageView)
        
        // Auto Layout 설정
        productImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(148)
            $0.width.equalTo(111)
        }
        
        numberLabel.snp.makeConstraints {
            $0.top.equalTo(productImageView.snp.top)
            $0.leading.equalTo(productImageView)
            $0.width.equalTo(20)
            $0.height.equalTo(20)
        }
        
        countLabel.snp.makeConstraints {
            $0.bottom.equalTo(productImageView.snp.bottom).offset(-5)
            $0.centerX.equalTo(productImageView)
            $0.width.equalTo(32)
            $0.height.equalTo(17)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(productImageView.snp.bottom).offset(5)
            $0.leading.equalToSuperview()
        }
        
        overlayView.snp.makeConstraints {
            $0.edges.equalTo(productImageView)
        }
        
        checkmarkImageView.snp.makeConstraints {
            $0.center.equalTo(productImageView)
            $0.width.height.equalTo(40)
        }
    }
    
    // 선택/해제 메서드
    func setSelected(_ isSelected: Bool) {
        overlayView.isHidden = !isSelected
        checkmarkImageView.isHidden = !isSelected
    }
}
