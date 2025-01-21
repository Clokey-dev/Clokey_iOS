//
//  UpdateFriendClothesCollectionViewCell.swift
//  Clokey
//
//  Created by 한금준 on 1/17/25.
//

import UIKit

class UpdateFriendClothesCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "UpdateFriendClothesCollectionViewCell"
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .gray
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(with imageName: String) {
        imageView.image = UIImage(named: imageName)
    }
    
}
