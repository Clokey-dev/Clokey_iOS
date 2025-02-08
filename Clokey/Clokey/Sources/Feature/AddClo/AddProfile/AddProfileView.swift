//
//  AddProfileView.swift
//  Clokey
//
//  Created by 한금준 on 2/1/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class AddProfileView: UIView {
    
    /// 세로 스크롤을 지원하는 ScrollView
    let scrollView: UIScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    /// ScrollView 내부 콘텐츠를 담는 ContentView
    let contentView: UIView = UIView().then {
        $0.backgroundColor = .white // 배경색 흰색
    }
    
    let backButton: UIButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = UIColor.brown
    }
    
    let profileSettingLabel = UILabel().then {
        $0.text = "프로필 설정"
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textAlignment = .center
    }
    
    var backgroundImageView = UIImageView().then {
        $0.image = UIImage(named: "profile_background")
        $0.backgroundColor = .systemGray6
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    let addImageButton1 = UIButton().then {
        $0.setImage(UIImage(named: "plus_image"), for: .normal)
    }
    
    let profileContainer: UIView = UIView().then {
        $0.layer.cornerRadius = 50 // 원형으로 만들기 위해 반지름을 절반으로 설정
        $0.layer.masksToBounds = true // 자식 콘텐츠가 코너를 넘지 않도록 설정
    }
    
    // MARK: - UI Components
    var profileImageView = UIImageView().then {
        $0.image = UIImage(named: "profile_test") // 기본 이미지
        $0.tintColor = UIColor.brown
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 50
        $0.layer.masksToBounds = true
    }
    
    let addImageButton2 = UIButton().then {
        $0.setImage(UIImage(named: "plus_image"), for: .normal)
        $0.isUserInteractionEnabled = true
    }
    
    let nicknameLabel = UILabel().then {
        $0.text = "닉네임*"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .black
    }
    
    let nicknameTextField = UITextField().then {
        $0.placeholder = "6글자 이내"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .gray
    }
    
    let nicknameStatusLabel = UILabel().then {
        $0.text = "6글자 이내로 입력해주세요" // 기본적으로 숨김
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.isHidden = true
        $0.textColor = .orange // 오류 시 빨간색
    }
    
    let idLabel = UILabel().then {
        $0.text = "아이디*"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .black
    }
    
    let idTextField = UITextField().then {
        $0.borderStyle = .none
        $0.textColor = .gray
        $0.font = UIFont.systemFont(ofSize: 16)
        
        let fullText = "ex) cky111 (대문자, 특수문자 입력 불가)"
        let mainTextRange = (fullText as NSString).range(of: "ex) cky111")
        let subTextRange = (fullText as NSString).range(of: "(대문자, 특수문자 입력 불가)")
        
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: mainTextRange)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 12), range: subTextRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, fullText.count))
        
        $0.attributedPlaceholder = attributedString
    }
    
    let idStatusLabel = UILabel().then {
        $0.text = ""
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .green
    }
    
    let idCheckButton = UIButton().then {
        $0.setTitle("중복 확인", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
    }
    
    let bioLabel = UILabel().then {
        $0.text = "한줄소개"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .black
    }
    
    let bioTextField = UITextField().then {
        $0.placeholder = "20자 이내"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .gray
    }
    
    let accountTypeLabel = UILabel().then {
        $0.text = "계정 공개 여부*"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .black
    }
    
    let publicButton = UIButton().then {
        $0.setTitle("공개", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .clear
    }
    
    let privateButton = UIButton().then {
        $0.setTitle("비공개", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .clear
    }
    
    let completeButton = UIButton().then {
        $0.setTitle("설정 완료", for: .normal)
        $0.backgroundColor = UIColor.lightGray
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.layer.cornerRadius = 10
        $0.isEnabled = false
    }
    
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 밑줄 추가 함수
    private func addUnderline(to textField: UITextField) {
        let underline = CALayer()
        underline.frame = CGRect(x: 0, y: textField.frame.height - 1, width: textField.frame.width, height: 1)
        underline.backgroundColor = UIColor.lightGray.cgColor // 밑줄 색상
        textField.layer.addSublayer(underline)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addUnderline(to: nicknameTextField)
        addUnderline(to: idTextField)
        addUnderline(to: bioTextField)
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
        contentView.addSubview(nicknameStatusLabel)
        contentView.addSubview(idLabel)
        contentView.addSubview(idTextField)
        contentView.addSubview(idStatusLabel)
        contentView.addSubview(idCheckButton)
        contentView.addSubview(bioLabel)
        contentView.addSubview(bioTextField)
        contentView.addSubview(accountTypeLabel)
        contentView.addSubview(publicButton)
        contentView.addSubview(privateButton)
        contentView.addSubview(completeButton)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalToSuperview()
            make.bottom.equalTo(completeButton.snp.bottom)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(11)
            make.width.height.equalTo(24)
        }
        
        profileSettingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }
        
        // 4. Background Image
        backgroundImageView.snp.makeConstraints { make in
            make.top.equalTo(profileSettingLabel.snp.bottom).offset(11)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(393) // 이미지 높이 조정 (원하는 값으로)
        }
        
        addImageButton1.snp.makeConstraints { make in
            make.size.equalTo(28)
            make.trailing.equalTo(backgroundImageView).inset(20)
            make.top.equalTo(backgroundImageView).offset(20)
        }
        
        profileContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(backgroundImageView.snp.bottom).offset(-50)
            make.size.equalTo(CGSize(width: 100, height: 100)) // 원형 크기 지정
        }
        
        profileImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addImageButton2.snp.makeConstraints { make in
            make.size.equalTo(24) // 버튼 크기
            make.trailing.equalTo(profileContainer.snp.trailing).offset(-6) // ✅ 오른쪽 아래 정렬
            make.bottom.equalTo(profileContainer.snp.bottom).offset(-6)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(backgroundImageView.snp.bottom).offset(67)
            make.leading.equalToSuperview().offset(20)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        nicknameStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(6)
            make.leading.equalTo(nicknameTextField.snp.leading)
        }
        
        idLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(20)
        }
        
        idTextField.snp.makeConstraints { make in
            make.top.equalTo(idLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        idCheckButton.snp.makeConstraints { make in
            make.centerY.equalTo(idTextField)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(76)
            make.height.equalTo(30)
        }
        
        idStatusLabel.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom).offset(6)
            $0.leading.equalTo(idTextField.snp.leading)
        }
        
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(idTextField.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(20)
        }
        
        bioTextField.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        accountTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(bioTextField.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(20)
        }
        
        publicButton.snp.makeConstraints { make in
            make.top.equalTo(accountTypeLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(20)
            make.width.equalTo(76)
            make.height.equalTo(30)
        }
        
        privateButton.snp.makeConstraints { make in
            make.centerY.equalTo(publicButton)
            make.leading.equalTo(publicButton.snp.trailing).offset(10)
            make.width.equalTo(76)
            make.height.equalTo(30)
        }
        
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(privateButton.snp.bottom).offset(80)
            //            make.bottom.equalTo(contentView.safeAreaLayoutGuide).offset(-20) // ✅ contentView의 끝을 completeButton에 맞춤
            make.centerX.equalToSuperview()
            make.height.equalTo(54)
            make.width.equalTo(353)
        }
    }
}
