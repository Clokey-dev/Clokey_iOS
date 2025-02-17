//
//  SettingView.swift
//  Clokey
//
//  Created by 한금준 on 2/4/25.
//

import UIKit
import SnapKit
import Then

final class SettingView: UIView {
    
    let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = .black
    }
    
    let settingLabel = UILabel().then {
        $0.text = "설정"
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textAlignment = .center
    }
    
    let infoTitleLabel = UILabel().then {
        $0.text = "로그인/회원정보"
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textAlignment = .center
    }
    
    let separatorLine1 = UIView().then {
        $0.backgroundColor = UIColor(red: 107/255, green: 107/255, blue: 107/255, alpha: 1)
    }
    
    let kakaoImage = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 20
        $0.image = UIImage(named: "kakao_icon")
    }
    
    let emailLabel = UILabel().then {
        $0.text = "email@xxxxx.com"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .darkGray
    }
    
    let alarmTitleLabel = UILabel().then {
        $0.text = "알림"
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textAlignment = .center
    }
    
    let separatorLine2 = UIView().then {
        $0.backgroundColor = UIColor(red: 107/255, green: 107/255, blue: 107/255, alpha: 1)
    }
    
    let pushLabel = UILabel().then {
        $0.text = "PUSH 알림"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let pushSwitch = UISwitch().then {
        $0.isOn = false
        $0.onTintColor = UIColor.orange
    }
    
    let marketingLabel = UILabel().then {
        $0.text = "마케팅 알림 수신 동의"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let marketingSwitch = UISwitch().then {
        $0.isOn = false
        $0.onTintColor = UIColor.orange
//        $0.transform = CGAffineTransform(scaleX: 1.2, y: 0.8) // 크기를 가로 1.2배, 세로 1.2배로 확대
    }
    
    let supportTitleLabel = UILabel().then {
        $0.text = "고객 지원"
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textAlignment = .center
    }
    
    let separatorLine3 = UIView().then {
        $0.backgroundColor = UIColor(red: 107/255, green: 107/255, blue: 107/255, alpha: 1)
    }
    
    let versionLabel = UILabel().then {
        $0.text = "버전 정보"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let versionInfoLabel = UILabel().then {
        $0.text = "1.0.0"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .gray
    }
    
    // 문의하기 버튼
    let inquiryContainer = UIView().then {
        $0.backgroundColor = .white
    }
    
    let inquiryLabel = UILabel().then {
        $0.text = "문의하기"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let inquiryButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .black
    }
    
    // 로그아웃 버튼
    let logoutContainer = UIView().then {
        $0.backgroundColor = .white
    }
    
    let logoutLabel = UILabel().then {
        $0.text = "로그아웃"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let logoutButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .black
    }
    
    // 계정 탈퇴 버튼
    let deleteContainer = UIView().then {
        $0.backgroundColor = .white
    }
    
    let deleteAccountLabel = UILabel().then {
        $0.text = "계정 탈퇴"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    let deleteAccountButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .black
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubviews(
            backButton, settingLabel, infoTitleLabel, separatorLine1, kakaoImage,
            emailLabel, alarmTitleLabel, separatorLine2, pushLabel, pushSwitch, marketingLabel, marketingSwitch, supportTitleLabel, separatorLine3,
            versionLabel, versionInfoLabel,
            inquiryContainer, logoutContainer, deleteContainer
        )
        
        inquiryContainer.addSubviews(inquiryLabel, inquiryButton)
        logoutContainer.addSubviews(logoutLabel, logoutButton)
        deleteContainer.addSubviews(deleteAccountLabel, deleteAccountButton)
    }
    
    private func setupConstraints(){
        backButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(11)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(CGSize(width: 10, height: 20))
        }
        
        settingLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.leading.equalTo(backButton.snp.trailing).offset(20)
        }
        
        infoTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(45)
            make.leading.equalToSuperview().offset(20)
        }
        
        separatorLine1.snp.makeConstraints { make in
            make.top.equalTo(infoTitleLabel.snp.bottom).offset(9)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        kakaoImage.snp.makeConstraints { make in
            make.top.equalTo(separatorLine1.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
       
        emailLabel.snp.makeConstraints { make in
            make.centerY.equalTo(kakaoImage)
            make.leading.equalTo(kakaoImage.snp.trailing).offset(15)
        }
        
        alarmTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(kakaoImage.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(20)
        }
        
        separatorLine2.snp.makeConstraints { make in
            make.top.equalTo(alarmTitleLabel.snp.bottom).offset(9)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        pushLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorLine2.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
        }
        
        pushSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(pushLabel)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        marketingLabel.snp.makeConstraints { make in
            make.top.equalTo(pushLabel.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(20)
        }
        
        marketingSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(marketingLabel)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        supportTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(marketingLabel.snp.bottom).offset(51)
            make.leading.equalToSuperview().offset(20)
        }
        
        separatorLine3.snp.makeConstraints { make in
            make.top.equalTo(supportTitleLabel.snp.bottom).offset(9)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        versionLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorLine3.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
        }
        
        versionInfoLabel.snp.makeConstraints { make in
            make.centerY.equalTo(versionLabel)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        // 문의하기
        inquiryContainer.snp.makeConstraints { make in
            make.top.equalTo(versionInfoLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        inquiryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        inquiryButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        // 로그아웃
        logoutContainer.snp.makeConstraints { make in
            make.top.equalTo(inquiryContainer.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        logoutLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        logoutButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        // 계정 탈퇴
        deleteContainer.snp.makeConstraints { make in
            make.top.equalTo(logoutContainer.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        deleteAccountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        deleteAccountButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
