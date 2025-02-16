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
        guard let slideModel = slideModel else { return } // ✅ slideModel이 nil이면 함수 종료
        
        if let imageUrlString = slideModel.image,
           let imageURL = URL(string: imageUrlString),
           !imageUrlString.isEmpty {
            // ✅ 유효한 URL인지 체크
            imageView.imageView.kf.setImage(with: imageURL)
        } else {
            // ✅ 기본 이미지 설정 (플레이스홀더)
            imageView.imageView.image = UIImage(named: "placeholder")
        }
        
        imageView.titleLabel.text = slideModel.title ?? "제목 없음" // ✅ nil 방어 코드
        imageView.hashtagLabel.text = slideModel.hashtag ?? "해시태그 없음" // ✅ nil 방어 코드
    }
    
//    private func updateUI() {
//        let homeService = HomeService()
//
//        homeService.fetchGetIssuesData { result in
//            switch result {
//            case .success(let responseDTO):
//                DispatchQueue.main.async {
//                    // ✅ recommend 배열이 비어있는지 확인
//                    guard !responseDTO.recommend.isEmpty else {
//                        print("🚨 No recommend data available.")
//                        return
//                    }
//
//                    // ✅ 여러 개의 recommend 데이터를 처리
//                    responseDTO.recommend.forEach { recommendItem in
//                        if let imageUrlString = recommendItem.imageUrl, let imageUrl = URL(string: imageUrlString) {
//                            self.imageView.imageView.kf.setImage(with: imageUrl)
//                        } else {
//                            self.imageView.imageView.image = UIImage(named: "placeholder") // 기본 이미지 설정
//                        }
//                        
//                        self.imageView.titleLabel.text = recommendItem.subTitle
//                        self.imageView.hashtagLabel.text = recommendItem.hashtag
//                    }
//                }
//                
//            case .failure(let error):
//                print("❌ Failed to load recommend data: \(error.localizedDescription)")
//            }
//        }
//    }
                                        
    
    // 외부에서 데이터를 설정할 메서드
    func configureView(with model: RecommandNewsSlideModel) {
        self.slideModel = model
    }
}
