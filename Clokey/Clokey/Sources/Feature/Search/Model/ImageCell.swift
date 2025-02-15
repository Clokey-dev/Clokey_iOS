//
//  ImageCell.swift
//  Clokey
//
//  Created by 소민준 on 2/10/25.
//


//
//  ImageCell.swift
//  ClothingAdd
//
//  Created by 소민준 on 2/8/25.
//


import UIKit
import SnapKit

class ImageCell: UICollectionViewCell {
    static let identifier = "ImageCell"

        let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

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

    func configure(with image: UIImage) {
        imageView.image = image
    }
}
