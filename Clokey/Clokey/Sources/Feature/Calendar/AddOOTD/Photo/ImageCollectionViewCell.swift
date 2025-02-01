//
//  ImageCollectionViewCell.swift
//  Clokey
//
//  Created by 황상환 on 1/21/25.
//

import Foundation
import UIKit
import SnapKit
import Then

final class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier = "ImageCollectionViewCell"
    
    var deleteButtonTapHandler: (() -> Void)?
    
    // MARK: - UI Component
    
    // 이미지 뷰
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .systemGray6
    }
    
    // 이미지 삭제 버튼
    private let deleteButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.2
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 8
        $0.tintColor = .white
    }
    
    // 첫 번째 이미지 뱃지
    private let clothingIconView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
        contentView.addSubview(clothingIconView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().offset(-4)
            $0.width.height.equalTo(24)
        }
        
        clothingIconView.snp.makeConstraints {
            $0.bottom.leading.equalToSuperview().inset(8)
            $0.width.height.equalTo(24)
        }
    }
    
    private func setupActions() {
        // deleteButtonTapped 호출
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    func hideDeleteButton() {
        deleteButton.isHidden = true
    }
   
    func showDeleteButton() {
        deleteButton.isHidden = false
    }
    
    func configure(with image: UIImage, isFirstImage: Bool = false) {
        imageView.image = image
        clothingIconView.isHidden = !isFirstImage
        
        if isFirstImage {
            clothingIconView.image = UIImage(named: "tag_icon")
        }
    }
    
    // MARK: - Action
    @objc private func deleteButtonTapped() {
        deleteButtonTapHandler?()
    }
    
    // MARK: - Configuration
    func configure(with image: UIImage) {
        imageView.image = image
    }
    
    // MARK: - Reuse
    
    // 셀을 재사용할 때 호출되는 메서드
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        deleteButtonTapHandler = nil
        clothingIconView.isHidden = true
    }
    
}
