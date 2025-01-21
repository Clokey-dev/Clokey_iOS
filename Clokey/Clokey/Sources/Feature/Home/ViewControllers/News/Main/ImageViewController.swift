//
//  ImageViewController.swift
//  PageControl
//
//  Created by 한금준 on 1/14/25.
//

import UIKit

class ImageViewController: UIViewController {
    
    var slideModel: RecommandNewsSlideModel?
    
    let imageView = ImageView() // ImageView 인스턴스 생성
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupImageView()
        updateUI()
    }
    
    // ImageView를 뷰 계층에 추가하고 레이아웃 설정
    private func setupImageView() {
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // ImageView를 전체 화면에 맞게 배치
        }
    }
    
    
    // UI 업데이트
    private func updateUI() {
        if let slideModel = slideModel {
            imageView.imageView.image = UIImage(named: slideModel.image) // 이미지 설정
            imageView.titleLabel.text = slideModel.title // 제목 설정
            imageView.hashtagLabel.text = slideModel.hashtag // 해시태그 설정
        }
    }
    
    // 외부에서 데이터를 설정할 메서드
    func configureView(with model: RecommandNewsSlideModel) {
        self.slideModel = model
    }
}
