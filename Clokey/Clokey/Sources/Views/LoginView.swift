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
        $0.font = .systemFont(ofSize: 24, weight: .bold)
    }
    
    // 소셜 로그인 스택뷰
    private let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.distribution = .fillEqually
    }
    
    // 카카오 로그인
    let kakaoLoginButton = UIButton().then {
        $0.setImage(UIImage(named: "kakao_login_large_wide_en"), for: .normal)
        $0.imageView?.contentMode = .scaleToFill
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }
    
    // 애플 로그인
    let appleLoginButton = UIButton().then {
        $0.setImage(UIImage(named: "appleid_button_bk"), for: .normal)
        $0.imageView?.contentMode = .scaleToFill
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
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
        
        buttonStackView.addArrangedSubview(kakaoLoginButton)
        buttonStackView.addArrangedSubview(appleLoginButton)
        
        // 클로키 소개 타이틀
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(40)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        // 소셜 로그인 버튼 스택
        buttonStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-40)
        }
        
        // 카카오 로그인
        kakaoLoginButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        // 애플로그인
        appleLoginButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
    }
}
