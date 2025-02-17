//
//  ImageViewController.swift
//  PageControl
//
//  Created by 한금준 on 1/14/25.
//

import UIKit
import Kingfisher

class ImageViewController: UIViewController {
    
    var slideModel: RecommandNewsSlideModel?
    
    let imageView = ImageView() // ImageView 인스턴스 생성
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupImageView()
        updateUI()
    }

    private func setupImageView() {
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview() // 중앙 정렬
            make.width.equalTo(300) // 너비를 300으로 고정
            make.height.equalTo(300) // 높이도 300으로 설정
        }
    }
    
    private func updateUI() {
        guard let slideModel = slideModel else { return }
        
        if let imageUrlString = slideModel.image,
           let imageURL = URL(string: imageUrlString),
           !imageUrlString.isEmpty {
            imageView.imageView.kf.setImage(with: imageURL)
        } else {
            imageView.imageView.image = UIImage(named: "placeholder")
        }
        
        imageView.titleLabel.text = slideModel.title ?? "제목 없음"
        imageView.hashtagLabel.text = slideModel.hashtag ?? "해시태그 없음"
    }
                                        
    
    // 외부에서 데이터를 설정할 메서드
    func configureView(with model: RecommandNewsSlideModel) {
        self.slideModel = model
    }
}
