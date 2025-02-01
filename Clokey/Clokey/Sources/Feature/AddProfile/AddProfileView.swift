//
//  AddProfileView.swift
//  Clokey
//
//  Created by 한금준 on 2/1/25.
//

import UIKit
import SnapKit
import Then

class AddProfileView: UIView {
    /// 세로 스크롤을 지원하는 ScrollView
    let scrollView: UIScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    /// ScrollView 내부 콘텐츠를 담는 ContentView
    let contentView: UIView = UIView().then {
        $0.backgroundColor = .white // 배경색 흰색
    }
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = UIColor.brown
        return button
    }()
    
    let profileSettingLabel = UILabel().then {
        $0.text = "프로필 설정"
        $0.font = UIFont.ptdMediumFont(ofSize: 20)
        $0.textAlignment = .center
    }
    
    let backgroundImageView = UIImageView().then {
        $0.image = UIImage(named: "profile_background")
        $0.backgroundColor = .systemGray6
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    let addImageButton1: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus_image"), for: .normal)
        return button
    }()
    
    let profileContainer: UIView = UIView().then {
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 50 // 원형으로 만들기 위해 반지름을 절반으로 설정
        $0.layer.masksToBounds = true // 자식 콘텐츠가 코너를 넘지 않도록 설정
    }
    
    // MARK: - UI Components
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile_test") // 기본 이미지
        imageView.tintColor = UIColor.brown
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let addImageButton2: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus_image"), for: .normal)
        return button
    }()
    
    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임*"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .gray
        return label
    }()
    
    let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "닉네임을 입력하세요."
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.textColor = .gray
        return textField
    }()
    
    let idLabel: UILabel = {
        let label = UILabel()
        label.text = "아이디*"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .gray
        return label
    }()
    
    let idTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.textColor = .gray
        textField.font = UIFont.systemFont(ofSize: 20)

        let fullText = "ex) cky111 (대문자, 특수문자 입력 불가)"
        let mainTextRange = (fullText as NSString).range(of: "ex) cky111")
        let subTextRange = (fullText as NSString).range(of: "(대문자, 특수문자 입력 불가)")

        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 20), range: mainTextRange)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: subTextRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, fullText.count))

        textField.attributedPlaceholder = attributedString
        return textField
    }()
    
    let idCheckButton: UIButton = {
        let button = UIButton()
        button.setTitle("중복 확인", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        return button
    }()
    
    let idStatusLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .green
        return label
    }()
    
    let accountTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "계정 공개 여부*"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .brown
        return label
    }()
    
    let publicButton: UIButton = {
        let button = UIButton()
        button.setTitle("공개", for: .normal)
        button.setTitleColor(UIColor.brown, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.brown.cgColor
        button.layer.cornerRadius = 8
        button.backgroundColor = .clear
        return button
    }()
    
    let privateButton: UIButton = {
        let button = UIButton()
        button.setTitle("비공개", for: .normal)
        button.setTitleColor(UIColor.brown, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.brown.cgColor
        button.layer.cornerRadius = 8
        button.backgroundColor = .clear
        return button
    }()
    
    let completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("가입 완료", for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 8
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Initialization
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
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        
        contentView.addSubview(backButton)
        contentView.addSubview(profileSettingLabel)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(addImageButton1)
        contentView.addSubview(profileContainer)
        profileContainer.addSubview(profileImageView)
        contentView.addSubview(addImageButton2)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(nicknameTextField)
        contentView.addSubview(idLabel)
        contentView.addSubview(idTextField)
        contentView.addSubview(idCheckButton)
        contentView.addSubview(idStatusLabel)
        contentView.addSubview(accountTypeLabel)
        contentView.addSubview(publicButton)
        contentView.addSubview(privateButton)
        contentView.addSubview(completeButton)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // 화면 전체에 ScrollView
        }
        
        // ContentView 제약 설정
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView) // ScrollView 내부에 맞춤
            make.width.equalTo(scrollView) // 가로 크기는 화면 크기와 동일
            make.bottom.equalTo(completeButton.snp.bottom).offset(20)
        }
        
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(8)
            $0.width.height.equalTo(24)
        }
        
        profileSettingLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        backgroundImageView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(200)
        }
        addImageButton1.snp.makeConstraints { make in
            make.width.height.equalTo(36) // 버튼 크기
            make.trailing.equalTo(backgroundImageView.snp.trailing).inset(12)
            make.top.equalTo(backgroundImageView.snp.top).offset(12)
        }
        
        profileContainer.snp.makeConstraints { make in
            make.top.equalTo(backgroundImageView.snp.bottom).offset(-50)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // profileContainer 내부에 딱 맞게 배치
        }
        
        addImageButton2.snp.makeConstraints {
            $0.width.height.equalTo(36) // 버튼 크기를 조금 키움
            $0.trailing.equalTo(profileImageView.snp.trailing).offset(6)
            $0.bottom.equalTo(profileImageView.snp.bottom).offset(6)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(profileContainer.snp.bottom).offset(32) // 프로필 아래로 간격 조정
            $0.leading.equalToSuperview().inset(16)
        }

        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }

        idLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(16)
        }

        idTextField.snp.makeConstraints {
            $0.top.equalTo(idLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }

        idCheckButton.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.top)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.equalTo(76)
            $0.height.equalTo(44)
        }
        idStatusLabel.snp.makeConstraints {
            $0.top.equalTo(idCheckButton.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(16)
        }
        accountTypeLabel.snp.makeConstraints {
            $0.top.equalTo(idStatusLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(16)
        }
        publicButton.snp.makeConstraints {
            $0.top.equalTo(accountTypeLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(40)
            $0.width.equalTo(100)
        }
        privateButton.snp.makeConstraints {
            $0.top.equalTo(accountTypeLabel.snp.bottom).offset(8)
            $0.leading.equalTo(publicButton.snp.trailing).offset(16)
            $0.height.equalTo(40)
            $0.width.equalTo(100)
        }
        completeButton.snp.makeConstraints {
//            $0.bottom.equalToSuperview().offset(-16)
            $0.top.equalTo(publicButton.snp.bottom).offset(95)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
    }
}
