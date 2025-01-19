//
//  LoginView.swift
//  Clokey
//
//  Created by 황상환 on 1/8/25.
//

import Foundation
import UIKit
import SnapKit
import Then

final class LoginView: UIView {
    // MARK: - UI Components
    
    // 클로키 소개 라벨
    private let titleLabel = UILabel().then {
        $0.text = "Clokey와 함께\n스마트한 옷장 관리를\n시작해보세요!"
        $0.numberOfLines = 3
        $0.textAlignment = .left
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 24)
    }
    
    // 로그인 메인 이미지
    private let mainImageView = UIImageView().then {
        $0.image = UIImage(named: "login_main")
        $0.contentMode = .scaleAspectFit
    }
    
    // 소셜 로그인 스택뷰
    private let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.distribution = .fillEqually
    }
    
    // 카카오 로그인 버튼
    let kakaoLoginButton = UIButton().then {
        var configuration = UIButton.Configuration.filled()
        // 고화질을 위해.. 이미지 리사이징
        if let kakaoOriginalImage = UIImage(named: "kakao_logo2") {
            let resizedImage = kakaoOriginalImage.resizeImageTo(size: CGSize(width: 32, height: 32))
            configuration.image = resizedImage
        }

        configuration.baseBackgroundColor = UIColor(hexCode: "FDDC3F")
        configuration.baseForegroundColor = UIColor.black
        var attText = AttributedString("카카오톡으로 시작하기")
        attText.font = UIFont.ptdMediumFont(ofSize: 16)
        configuration.attributedTitle = attText
        configuration.background.cornerRadius = 10
        configuration.imagePadding = 30

        let button = UIButton(configuration: configuration, primaryAction: nil)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: -30, bottom: 10, trailing: 30)

        $0.configuration = configuration
    }

    let appleLoginButton = UIButton().then {
        var configuration = UIButton.Configuration.filled()
        // 고화질을 위해.. 이미지 리사이징
        if let appleOriginalImage = UIImage(named: "apple_logo2") {
            let resizedImage = appleOriginalImage.resizeImageTo(size: CGSize(width: 32, height: 32))
            configuration.image = resizedImage
        }

        configuration.baseBackgroundColor = UIColor.black
        configuration.baseForegroundColor = UIColor.white
        var attText = AttributedString("애플로 시작하기")
        attText.font = UIFont.ptdMediumFont(ofSize: 16)
        configuration.attributedTitle = attText
        configuration.background.cornerRadius = 10
        configuration.imagePadding = 50

        let button = UIButton(configuration: configuration, primaryAction: nil)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: -40, bottom: 10, trailing: 43)

        $0.configuration = configuration
    }

    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    // UI 셋업
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(titleLabel)
        addSubview(buttonStackView)
        addSubview(mainImageView)
        
        buttonStackView.addArrangedSubview(kakaoLoginButton)
        buttonStackView.addArrangedSubview(appleLoginButton)
        
        // 클로키 소개 타이틀
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(75)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        // 로그인 메인 이미지
        mainImageView.snp.makeConstraints {
            $0.width.equalTo(259)
            $0.height.equalTo(243)
            $0.top.equalTo(titleLabel.snp.bottom).offset(74)
            $0.centerX.equalToSuperview()
        }
        
        // 소셜 로그인 버튼 스택
        buttonStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-40)
        }
        
        kakaoLoginButton.snp.makeConstraints {
            $0.height.equalTo(50) // 버튼 높이
            $0.top.equalToSuperview().offset(100) // 상단 여백
        }

        appleLoginButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(kakaoLoginButton.snp.bottom).offset(16) // 카카오 버튼 아래에 배치
        }

    }
}

extension UIColor {
    
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}

extension UIImage {
    func resizeImageTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
