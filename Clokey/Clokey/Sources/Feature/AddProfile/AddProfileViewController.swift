//
//  AddProfileViewController.swift
//  Clokey
//
//  Created by 소민준 on 1/18/25.
//


import UIKit
import SnapKit

class AddProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UI Components
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "AddprofileMan") // 기본 이미지
        imageView.tintColor = UIColor.brown
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true // ✅ 경계 밖의 내용이 잘리도록 설정
        imageView.layer.cornerRadius = 84 // ✅ 반지름을 이미지의 절반 크기로 설정 (168 / 2 = 84)
        imageView.layer.masksToBounds = true // ✅ 실제로 반영되도록 설정
        return imageView
    }()
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal) // 왼쪽 화살표 아이콘
        button.tintColor = UIColor.brown // 색상 맞추기
        return button
    }()
    
    private let addImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Plus"), for: .normal)
        
        button.frame = CGRect(x: 0, y: 0, width: 36, height: 36) // 버튼 크기 조정
        return button
    }()
    
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임*"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .gray
        return label
    }()
    
    private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "닉네임을 입력하세요."
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.textColor = .gray
    
        return textField
    }()
    
    private let idLabel: UILabel = {
        let label = UILabel()
        label.text = "아이디*"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .gray
        return label
    }()
    
    
    private let idTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none // 기본 테두리 제거
        textField.textColor = .gray
        textField.font = UIFont.systemFont(ofSize: 20) // 기본 글자 크기

        // ✅ placeholder 스타일 적용
        let fullText = "ex) cky111 (대문자, 특수문자 입력 불가)"
        let mainTextRange = (fullText as NSString).range(of: "ex) cky111")
        let subTextRange = (fullText as NSString).range(of: "(대문자, 특수문자 입력 불가)")

        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 20), range: mainTextRange) // ✅ 기본 텍스트 (20)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: subTextRange) // ✅ 작은 텍스트 (14)
        attributedString.addAttribute(.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, fullText.count)) // 색상 적용

        textField.attributedPlaceholder = attributedString // Placeholder 적용

        return textField
    }()
    private let idCheckButton: UIButton = {
        let button = UIButton()
        button.setTitle("중복 확인", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let idStatusLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .green
        return label
    }()
    
    private let accountTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "계정 공개 여부*"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .brown
        return label
    }()
    
    private let publicButton: UIButton = {
        let button = UIButton()
        button.setTitle("공개", for: .normal)
        button.setTitleColor(UIColor.brown, for: .normal) // 기본 색상은 브라운
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.brown.cgColor
        button.layer.cornerRadius = 8
        button.backgroundColor = .clear // ✅ 초기 배경색 없음
        return button
    }()

    private let privateButton: UIButton = {
        let button = UIButton()
        button.setTitle("비공개", for: .normal)
        button.setTitleColor(UIColor.brown, for: .normal) // 기본 색상은 브라운
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.brown.cgColor
        button.layer.cornerRadius = 8
        button.backgroundColor = .clear // ✅ 초기 배경색 없음
        return button
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("가입 완료", for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 8
        button.isEnabled = false
        return button
    }()
    
    private let imagePickerController = UIImagePickerController()
    
    // MARK: - Lifecycle
    
    var viewModel = AddProfileViewModel() // AddProfileViewModel 사용
    var isIdChecked = false
    
    var isPublicAccount: Bool? = nil // ✅ 초기값: 선택되지 않음
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        addActions()
        imagePickerController.delegate = self
        validateForm() // 초기 상태에서 유효성 검사 실행
        idTextField.addBottomBorder(color: .black, height: 1.0)
        nicknameTextField.addBottomBorder(color: .black, height: 1.0)
        self.title = "프로필 설정" //  상단 타이틀 추가
        nicknameTextField.delegate = self
        idTextField.delegate = self
        
    }
    // MARK: - UI Setup
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // ✅ 레이아웃이 완료된 후 border 추가 (NaN 방지)
        nicknameTextField.addBottomBorder(color: .black, height: 1.0)
        idTextField.addBottomBorder(color: .black, height: 1.0)
    }
    private func setupUI() {
        view.backgroundColor = .white
        title = "프로필 설정"
        
        // 프로필 이미지
        view.addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(168)
        }
        
        // 이미지 추가 버튼
        view.addSubview(addImageButton)
        addImageButton.snp.makeConstraints {
            $0.width.height.equalTo(32) // 버튼 크기 설정 (프로필 크기에 맞춰 조정 가능)
            $0.trailing.equalTo(profileImageView.snp.trailing).offset(-4) // 오른쪽으로 겹치도록 조정
            $0.bottom.equalTo(profileImageView.snp.bottom).offset(-4) // 아래쪽으로 겹치도록 조정
}
        
        // 닉네임 필드
        view.addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(16)
        }
        
        view.addSubview(nicknameTextField)
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        
        // 아이디 필드
        view.addSubview(idLabel)
        idLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(16)
        }
        
        view.addSubview(idTextField)
        idTextField.snp.makeConstraints {
            $0.top.equalTo(idLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        
        // 중복 확인 버튼
        view.addSubview(idCheckButton)
        idCheckButton.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.top)
            $0.trailing.equalTo(idTextField.snp.trailing)
            $0.width.equalTo(76)
            $0.height.equalTo(28)
        }
        
        // 중복 확인 상태 레이블
        view.addSubview(idStatusLabel)
        idStatusLabel.snp.makeConstraints {
            $0.top.equalTo(idCheckButton.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(16)
        }
        
        // 계정 공개 여부
        view.addSubview(accountTypeLabel)
        accountTypeLabel.snp.makeConstraints {
            $0.top.equalTo(idStatusLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(16)
        }
        
        // 공개, 비공개 버튼
        view.addSubview(publicButton)
        publicButton.snp.makeConstraints {
            $0.top.equalTo(accountTypeLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(16)
            $0.height.equalTo(40)
            $0.width.equalTo(100)
        }
        
        view.addSubview(privateButton)
        privateButton.snp.makeConstraints {
            $0.top.equalTo(accountTypeLabel.snp.bottom).offset(8)
            $0.leading.equalTo(publicButton.snp.trailing).offset(16)
            $0.height.equalTo(40)
            $0.width.equalTo(100)
        }
        
        // 가입 완료 버튼
        view.addSubview(completeButton)
        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
    }
    //뒤로가기 버튼
    private func setupNavigation() {
        view.addSubview(backButton)
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16) // 왼쪽 여백 16
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8) // 상단 여백
            $0.width.height.equalTo(50) // 버튼 크기
        }
        
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    // MARK: - Actions
    private func addActions() {
        idCheckButton.addTarget(self, action: #selector(checkIdAvailability), for: .touchUpInside)
        publicButton.addTarget(self, action: #selector(selectPublicAccount), for: .touchUpInside)
        privateButton.addTarget(self, action: #selector(selectPrivateAccount), for: .touchUpInside)
        completeButton.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
        addImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        idTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    @objc private func didTapBackButton() {
        self.dismiss(animated: true, completion: nil)
    }

    // 텍스트 필드 변경 시 호출되는 메서드
    @objc private func textFieldDidChange() {
        idCheckButton.setTitleColor(.black, for: .normal) // 버튼 색 원래대로
        isIdChecked = false // 다시 중복 확인해야 함
        idStatusLabel.text = "" // 중복 메시지 삭제
        validateForm()
    }
    
    // 아이디 중복 확인
    @objc private func checkIdAvailability() {
        guard let id = idTextField.text, !id.isEmpty else { return }

        // ✅ 네트워크 요청 실행
        checkDuplicateIdFromServer(id: id) { [weak self] isDuplicated, message in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if isDuplicated {
                    self.idStatusLabel.text = message // 서버 응답 메시지 표시
                    self.idStatusLabel.textColor = .red
                    self.isIdChecked = false // ❌ 중복이므로 다시 확인 필요
                } else {
                    self.idStatusLabel.text = "사용 가능한 아이디입니다."
                    self.idStatusLabel.textColor = .pointOrange800
                    self.isIdChecked = true // ✅ 중복 확인 완료
                }

                self.idCheckButton.setTitleColor(.gray, for: .normal) // ✅ 버튼 색 변경
                self.validateForm()
            }
        }
    }

             
    //공개
   
    @objc private func selectPublicAccount() {
        isPublicAccount = true // ✅ 선택됨
        publicButton.backgroundColor = UIColor.brown
        publicButton.setTitleColor(.white, for: .normal)
        privateButton.backgroundColor = .clear
        privateButton.setTitleColor(UIColor.brown, for: .normal)
        validateForm() // ✅ 유효성 검사
    }
//비공개
    @objc private func selectPrivateAccount() {
        isPublicAccount = false // ✅ 선택됨
        privateButton.backgroundColor = UIColor.brown
        privateButton.setTitleColor(.white, for: .normal)
        publicButton.backgroundColor = .clear
        publicButton.setTitleColor(UIColor.brown, for: .normal)
        validateForm() // ✅ 유효성 검사
    }
    private func checkDuplicateIdFromServer(id: String, completion: @escaping (Bool, String) -> Void) {
        let urlString = "https://yourapi.com/users/\(id)/check" // ✅ 네 API에 맞게 URL 설정
        guard let url = URL(string: urlString) else {
            print("❌ 잘못된 URL")
            completion(false, "잘못된 요청입니다.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 네트워크 오류: \(error.localizedDescription)")
                completion(false, "네트워크 오류 발생")
                return
            }

            guard let data = data else {
                print("❌ 데이터 없음")
                completion(false, "서버에서 데이터를 받지 못했습니다.")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("✅ 서버 응답: \(json)") // 🔥 서버 응답 확인

                    let isSuccess = json["isSuccess"] as? Bool ?? false
                    let message = json["message"] as? String ?? "아이디 중복 확인 실패"

                    if message.lowercased() == "nan" || message.contains("NaN") {
                        print("❌ 서버에서 NaN 값이 포함된 응답이 왔습니다!")
                    }

                    completion(!isSuccess, message)
                    return
                }
            } catch {
                print("❌ JSON 파싱 오류: \(error.localizedDescription)")
                print("❌ 원본 데이터: \(String(data: data, encoding: .utf8) ?? "변환 불가")") // 🔥 원본 응답 출력
            }
            completion(false, "서버 오류 발생") // 기본값
        }
        
        task.resume()
    }
    // 폼 유효성 검사
    // 폼 유효성 검사
    private func validateForm() {
        let isNicknameValid = !(nicknameTextField.text?.isEmpty ?? true)
        let isIdValid = !(idTextField.text?.isEmpty ?? true) && isIdChecked
        let isProfileImageSet = profileImageView.image != UIImage(named: "AddprofileMan")
        let isAccountSelected = isPublicAccount != nil // ✅ 공개/비공개 중 하나 선택 필수
        
        completeButton.isEnabled = isNicknameValid && isIdValid && isProfileImageSet && isAccountSelected
        completeButton.backgroundColor = completeButton.isEnabled ? UIColor.brown : UIColor.lightGray
    }
    // 가입 완료 버튼 클릭
    @objc private func didTapCompleteButton() {
        print("✅ 프로필 설정 완료. 홈 화면으로 이동")

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.switchToMain() // ✅ SceneDelegate에서 홈 화면으로 이동
        } else {
            print("🚨 SceneDelegate를 찾을 수 없음")
        }
    }
    // 이미지 선택
    @objc private func selectImage() {
        let alertController = UIAlertController(title: "사진 선택", message: "프로필 사진을 선택하세요.", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "기본 프로필", style: .default, handler: { [weak self] _ in
            self?.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }))
        
        alertController.addAction(UIAlertAction(title: "사진 선택", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "카메라 촬영", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // UIImagePickerControllerDelegate 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            profileImageView.image = editedImage // 편집된 이미지 사용
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageView.image = originalImage // 원본 이미지 사용
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
extension AddProfileViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 키보드 닫기
        return true
    }
}

extension UITextField {
    func addBottomBorder(color: UIColor, height: CGFloat) {
        self.layoutIfNeeded() // ✅ 레이아웃을 먼저 업데이트
        
        guard self.frame.size.width > 0 else {
            print("❌ addBottomBorder() 호출 시 width가 0입니다. 나중에 다시 시도하세요.")
            return
        }

        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - height, width: self.frame.size.width, height: height)
        self.layer.addSublayer(border)
    }
}
