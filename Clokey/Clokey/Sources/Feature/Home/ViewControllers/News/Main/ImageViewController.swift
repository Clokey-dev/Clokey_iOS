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
    
    // UI 업데이트
//    private func updateUI() {
//        if let slideModel = slideModel {
//            if let imageURL = URL(string: slideModel.image) {
//                imageView.imageView.kf.setImage(with: imageURL) // URL을 통해 이미지 로드
//            }
//            imageView.titleLabel.text = slideModel.title // 제목 설정
//            imageView.hashtagLabel.text = slideModel.hashtag // 해시태그 설정
//        }
//    }
    
    private func updateUI() {
        let homeService = HomeService()
        
        homeService.fetchGetIssuesData { result in
            switch result {
            case .success(let responseDTO):
                DispatchQueue.main.async {
                    // ✅ recommend 배열이 비어있는지 확인
                    guard let firstRecommend = responseDTO.recommend.first else {
                        print("🚨 No recommend data available.")
                        return
                    }
                    
                    // ✅ 이미지 설정 (Kingfisher 사용)
                    if let imageUrlString = firstRecommend.imageUrl, let imageUrl = URL(string: imageUrlString) {
                        self.imageView.imageView.kf.setImage(with: imageUrl)
                    } else {
                        self.imageView.imageView.image = UIImage(named: "placeholder") // 기본 이미지 설정
                    }
                    
                    // ✅ 제목과 해시태그 설정
                    self.imageView.titleLabel.text = firstRecommend.subTitle
                    self.imageView.hashtagLabel.text = firstRecommend.hashtag
                }
                
            case .failure(let error):
                print("❌ Failed to load recommend data: \(error.localizedDescription)")
            }
        }
    }
                                        
    
    // 외부에서 데이터를 설정할 메서드
    func configureView(with model: RecommandNewsSlideModel) {
        self.slideModel = model
    }
}
