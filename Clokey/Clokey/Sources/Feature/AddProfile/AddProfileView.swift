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
        
     
        
        button.isUserInteractionEnabled = true // 🚀 터치 가능하게 설정
        return button
    }()
    
    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임*"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "6글자 이내"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .gray
        return textField
    }()
    
    let idLabel: UILabel = {
        let label = UILabel()
        label.text = "아이디*"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    let bioLabel: UILabel = {
        let label = UILabel()
        label.text = "한줄소개"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    let bioTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "20자 이내"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .gray
        return textField
    }()
    
    
    let idTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.textColor = .gray
        textField.font = UIFont.systemFont(ofSize: 16)
        
        let fullText = "ex) cky111 (대문자, 특수문자 입력 불가)"
        let mainTextRange = (fullText as NSString).range(of: "ex) cky111")
        let subTextRange = (fullText as NSString).range(of: "(대문자, 특수문자 입력 불가)")
        
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: mainTextRange)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 12), range: subTextRange)
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
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .green
        return label
    }()
    
    let accountTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "계정 공개 여부*"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    let publicButton: UIButton = {
        let button = UIButton()
        button.setTitle("공개", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 10
        button.backgroundColor = .clear
        return button
    }()
    
    let privateButton: UIButton = {
        let button = UIButton()
        button.setTitle("비공개", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 10
        button.backgroundColor = .clear
        return button
    }()
    let nicknameStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "6글자 이내로 입력해주세요" // 기본적으로 숨김
        label.font = UIFont.systemFont(ofSize: 16)
        label.isHidden = true
        label.textColor = .pointOrange800 // 오류 시 빨간색
        return label
    }()
    
    let completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("설정 완료", for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 10
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
        
        profileContainer.layer.cornerRadius = 50
            profileContainer.clipsToBounds = true // ✅ 컨테이너 내부 자식 뷰가 넘치지 않도록

            // ✅ 프로필 이미지 설정
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.clipsToBounds = true // ✅ 프로필 이미지가 원형을 유지하도록!

            // ✅ 프로필 컨테이너 내부에 프로필 이미지 추가
            profileContainer.addSubview(profileImageView)
            profileImageView.snp.remakeConstraints { make in
                make.edges.equalToSuperview() // ✅ 컨테이너와 동일한 크기로 설정
            }
        
        contentView.addSubview(addImageButton2)
        contentView.bringSubviewToFront(addImageButton2)

        addSubview(scrollView)
       
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nicknameStatusLabel)
        contentView.addSubview(backButton)
        contentView.addSubview(profileSettingLabel)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(addImageButton1)
        contentView.addSubview(profileContainer)
        profileContainer.addSubview(profileImageView)
    
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
        contentView.addSubview(bioLabel)
        contentView.addSubview(bioTextField)
        contentView.bringSubviewToFront(addImageButton2)
        
    }
    
    // AddProfileView.swift
    private func setupConstraints() {
        // 1. ScrollView 제약 조건
        scrollView.snp.remakeConstraints { make in
            make.edges.equalToSuperview() // 전체 화면 채우기
        }
        
        // 2. ContentView 제약 조건 (✅ 가장 중요!)
        contentView.snp.remakeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
            make.bottom.equalTo(completeButton.snp.bottom).offset(100) // 하단에 여유 공간 추가
        }
        
        // 3. BackButton & Title
        backButton.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.width.height.equalTo(24)
        }
        
        profileSettingLabel.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }
        
        // 4. Background Image
        backgroundImageView.snp.remakeConstraints { make in
            make.top.equalTo(profileSettingLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(393) // 이미지 높이 조정 (원하는 값으로)
        }
        
        addImageButton1.snp.remakeConstraints { make in
            make.size.equalTo(28)
            make.trailing.equalTo(backgroundImageView).inset(20)
            make.top.equalTo(backgroundImageView).offset(20)
        }
        addImageButton2.snp.remakeConstraints { make in
            make.size.equalTo(24) // 버튼 크기
            make.trailing.equalTo(profileContainer.snp.trailing).offset(-6) // ✅ 오른쪽 아래 정렬
            make.bottom.equalTo(profileContainer.snp.bottom).offset(-6)
        }

        // ✅ 즉시 오토레이아웃 적용
        self.layoutIfNeeded()

        // ✅ 2초 뒤에도 다시 확인
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.layoutIfNeeded()
            print("📌 addImageButton2 위치 재확인: \(self?.addImageButton2.frame ?? .zero)")
        }
        
        
        // 5. Profile Container
        profileContainer.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(backgroundImageView.snp.bottom).offset(-50) // 🔥 자연스럽게 배치
            make.size.equalTo(CGSize(width: 100, height: 100)) // 원형 크기 지정
        }

        profileImageView.snp.remakeConstraints { make in
            make.edges.equalToSuperview() // ✅ profileContainer와 크기 동일하게 설정
        }
        
        
        
        // 6. 닉네임 입력 필드
        nicknameLabel.snp.remakeConstraints { make in
            make.top.equalTo(profileContainer.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(20)
        }
        
        nicknameTextField.snp.remakeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        nicknameStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(8) // 닉네임 필드 아래 여백
            make.leading.equalTo(nicknameTextField.snp.leading)
            make.trailing.equalTo(nicknameTextField.snp.trailing)
        }
        
        // 7. 아이디 입력 필드
        idLabel.snp.remakeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(50)
            make.leading.equalToSuperview().inset(20)
        }
        
        idTextField.snp.remakeConstraints { make in
            make.top.equalTo(idLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        idCheckButton.snp.remakeConstraints { make in
            make.centerY.equalTo(idTextField)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(76)
            make.height.equalTo(28)
        }
        
        idStatusLabel.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom).offset(8)
            $0.leading.equalTo(idTextField.snp.leading)
            $0.trailing.equalTo(idTextField.snp.trailing)
        }
        
        // 8. 한줄 소개
        bioLabel.snp.remakeConstraints { make in
            make.top.equalTo(idTextField.snp.bottom).offset(50)
            make.leading.equalToSuperview().inset(20)
        }
        
        bioTextField.snp.remakeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        // 9. 계정 공개 여부
        accountTypeLabel.snp.remakeConstraints { make in
            make.top.equalTo(bioTextField.snp.bottom).offset(24)
            make.leading.equalToSuperview().inset(20)
        }
        
        publicButton.snp.remakeConstraints { make in
            make.top.equalTo(accountTypeLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(20)
            make.width.equalTo(76)
            make.height.equalTo(30)
        }
        
        privateButton.snp.remakeConstraints { make in
            make.centerY.equalTo(publicButton)
            make.leading.equalTo(publicButton.snp.trailing).offset(20)
            make.width.equalTo(76)
            make.height.equalTo(30)
        }
        
        // 10. 완료 버튼
        completeButton.snp.remakeConstraints { make in
            make.top.equalTo(privateButton.snp.bottom).offset(140)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(54)
        }
    }
}

extension UIImageView {
    // ✅ Kingfisher를 사용하여 이미지를 로드하고 URL을 저장하는 메서드
    func setImageWithURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            self.kf.setImage(with: url) { result in
                switch result {
                case .success(_):
                    self.accessibilityIdentifier = urlString // ✅ 이미지 URL 저장
                case .failure(let error):
                    print("🚨 Kingfisher 이미지 로드 실패:", error.localizedDescription)
                }
            }
        }
    }

    
    // ✅ 저장된 이미지 URL 가져오기
    func getImageURL() -> String? {
        return self.accessibilityIdentifier
    }
}
extension UIView {
    func debugPrintHitTest() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(debugTap))
        self.addGestureRecognizer(tapGesture)
    }

    @objc private func debugTap() {
        print("📌 \(String(describing: self)) 터치 감지됨!")
    }
}
