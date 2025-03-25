//
//  ImagePickViewController.swift
//  Clokey
//
//  Created by 한금준 on 3/20/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

class ImagePickViewController: UIViewController {
    var image: String = .init()
    
    let profileImageView: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "profile_icon")
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 130
        $0.clipsToBounds = true
    }
    
    init(image: String) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        viewProfile()
        dismissImage()
    }
    
    private func setupUI() {
        // 블러 이펙트 생성
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)

        // 블러 뷰 추가 (전체 화면)
        view.addSubview(blurEffectView)
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // 화면 전체
        }

        view.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(260)
        }
    }
    
    private func viewProfile(){
        self.profileImageView.kf.setImage(with: URL(string: image))
    }
    
    private func dismissImage() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissPopup(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
