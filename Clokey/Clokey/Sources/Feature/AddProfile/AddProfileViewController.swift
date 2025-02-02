//
//  AddProfileViewController.swift
//  Clokey
//
//  Created by 소민준 on 1/18/25.
//


import UIKit
import SnapKit

class AddProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let addProfileView = AddProfileView()
    
    private let imagePickerController = UIImagePickerController()
    private var selectedProfileImageURL: String?
    private var selectedBackgroundImageURL: String?
    
    // MARK: - Lifecycle
    
    var viewModel = AddProfileViewModel() // AddProfileViewModel 사용
    var isIdChecked = false
    
    var isPublicAccount: Bool? = nil // ✅ 초기값: 선택되지 않음
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = addProfileView
        addProfileView.addImageButton2.addTarget(self, action: #selector(showProfileImageOptions), for: .touchUpInside)
        addProfileView.addImageButton1.addTarget(self, action: #selector(showBackgroundImageOptions), for: .touchUpInside)
        
        
        setupNavigation()
        addActions()
        imagePickerController.delegate = self
        validateForm() // 초기 상태에서 유효성 검사 실행
        addProfileView.idTextField.addBottomBorder(color: .black, height: 1.0)
        addProfileView.nicknameTextField.addBottomBorder(color: .black, height: 1.0)
        self.title = "프로필 설정" //  상단 타이틀 추가
        addProfileView.nicknameTextField.delegate = self
        addProfileView.idTextField.delegate = self
        addProfileView.bioTextField.addTarget(self, action: #selector(limitBioLength), for: .editingChanged)
        
        DispatchQueue.main.async {
            self.addProfileView.contentView.bringSubviewToFront(self.addProfileView.addImageButton2)
        }
        
        // 🔹 화면 탭하면 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true) // 🔥 현재 화면에서 키보드 내리기
    }
    
    // MARK: - UI Setup
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        addProfileView.scrollView.contentSize = CGSize(width: view.frame.width, height: addProfileView.contentView.frame.height)
        
        
        // ✅ 닉네임, 아이디, 한줄소개 필드 각각 적용
        addProfileView.nicknameTextField.addBottomBorder(color: .black, height: 1.0)
        addProfileView.idTextField.addBottomBorder(color: .black, height: 1.0)
        addProfileView.bioTextField.addBottomBorder(color: .black, height: 1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if addProfileView.superview == nil {
            print("⚠️ AddProfileView가 superview에 추가되지 않음! 강제 추가함.")
            view.addSubview(addProfileView)
            addProfileView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            print("✅ AddProfileView가 정상적으로 추가됨.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //뒤로가기 버튼
    private func setupNavigation() {
        addProfileView.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    // MARK: - Actions
    private func addActions() {
        addProfileView.idCheckButton.addTarget(self, action: #selector(checkIdAvailability), for: .touchUpInside)
        addProfileView.publicButton.addTarget(self, action: #selector(selectPublicAccount), for: .touchUpInside)
        addProfileView.privateButton.addTarget(self, action: #selector(selectPrivateAccount), for: .touchUpInside)
        addProfileView.completeButton.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
        
        addProfileView.addImageButton2.addTarget(self, action: #selector(showProfileImageOptions), for: .touchUpInside)
        addProfileView.nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addProfileView.idTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addProfileView.nicknameTextField.addTarget(self, action: #selector(validateNickname), for: .editingChanged)
        
        
        
    }
    @objc private func didTapBackButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //스크롤할때 키보드 사라지기 방지
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            addProfileView.scrollView.contentInset.bottom = keyboardHeight + 20
            addProfileView.scrollView.scrollIndicatorInsets.bottom = keyboardHeight + 20
        }
    }
    
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        addProfileView.scrollView.contentInset.bottom = 0
        addProfileView.scrollView.scrollIndicatorInsets.bottom = 0
    }
    
    // 텍스트 필드 변경 시 호출되는 메서드
    @objc private func textFieldDidChange() {
        addProfileView.idCheckButton.setTitleColor(.black, for: .normal) // 버튼 색 원래대로
        isIdChecked = false // 다시 중복 확인해야 함
        addProfileView.idStatusLabel.text = "" // 중복 메시지 삭제
        validateForm()
    }
    
    @objc private func validateNickname() {
        guard let text = addProfileView.nicknameTextField.text, !text.isEmpty else {
            addProfileView.nicknameStatusLabel.text = ""
            addProfileView.nicknameStatusLabel.isHidden = true // 입력 없으면 숨김
            return
        }
        
        if text.count > 6 {
            addProfileView.nicknameStatusLabel.text = "6글자 이내로 입력해주세요."
            addProfileView.nicknameStatusLabel.textColor = .pointOrange800
            addProfileView.nicknameStatusLabel.isHidden = false // 🚀 오류 메시지 보이게 설정
        } else {
            addProfileView.nicknameStatusLabel.text = "사용 가능한 닉네임입니다."
            addProfileView.nicknameStatusLabel.textColor = .pointOrange800
            addProfileView.nicknameStatusLabel.isHidden = false // 🚀 유효한 경우에도 표시
        }
        
        validateForm() // 🚀 폼 유효성 검사 실행
    }
    
    // 아이디 중복 확인
    //    @objc private func checkIdAvailability() {
    //        guard let id = addProfileView.idTextField.text, !id.isEmpty else {
    //            self.addProfileView.idStatusLabel.text = "아이디를 입력해주세요."
    //            self.addProfileView.idStatusLabel.textColor = .red
    //            return
    //        }
    //
    //        let membersService = MembersService() // MembersService 객체 생성
    //
    //        // ✅ MembersService의 checkIdAvailability 호출
    //        membersService.checkIdAvailability(id: id) { [weak self] result in
    //            guard let self = self else { return }
    //
    //            DispatchQueue.main.async {
    //                switch result {
    //                case .success(let isAvailable):
    //                    if isAvailable {
    //                        self.addProfileView.idStatusLabel.text = "사용 가능한 아이디입니다."
    //                        self.addProfileView.idStatusLabel.textColor = .pointOrange800
    //                        self.isIdChecked = true // ✅ 중복 확인 완료
    //                    } else {
    //                        self.addProfileView.idStatusLabel.text = "이미 사용 중인 아이디입니다."
    //                        self.addProfileView.idStatusLabel.textColor = .red
    //                        self.isIdChecked = false // ❌ 중복된 아이디
    //                    }
    //                case .failure(let error):
    //                    self.addProfileView.idStatusLabel.text = "아이디 확인 실패: \(error.localizedDescription)"
    //                    self.addProfileView.idStatusLabel.textColor = .red
    //                    self.isIdChecked = false // 중복 확인 실패로 간주
    //                }
    //
    //                // 버튼 상태 변경 및 폼 유효성 검증
    //                self.addProfileView.idCheckButton.setTitleColor(.gray, for: .normal)
    //                self.validateForm()
    //            }
    //        }
    //    }
    
    // 아이디 중복 확인
    @objc private func checkIdAvailability() {
        guard let id = addProfileView.idTextField.text, !id.isEmpty else { return }
        
        // ✅ 네트워크 요청 실행
        checkDuplicateIdFromServer(id: id) { [weak self] isDuplicated, message in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if isDuplicated {
                    self.addProfileView.idStatusLabel.text = message // 서버 응답 메시지 표시
                    self.addProfileView.idStatusLabel.textColor = .red
                    self.isIdChecked = false // ❌ 중복이므로 다시 확인 필요
                } else {
                    self.addProfileView.idStatusLabel.text = "사용 가능한 아이디입니다."
                    self.addProfileView.idStatusLabel.textColor = .pointOrange800
                    self.isIdChecked = true // ✅ 중복 확인 완료
                }
                
                self.addProfileView.idCheckButton.setTitleColor(.gray, for: .normal) // ✅ 버튼 색 변경
                self.validateForm()
            }
        }
    }
    
    
    @objc private func showProfileImageOptions() {
        print("📌 showProfileImageOptions 실행됨!") // ✅ 실행 확인용 로그
        
        let alertController = UIAlertController(title: "프로필 사진", message: "선택하세요.", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "기본 프로필", style: .default, handler: { [weak self] _ in
            print("📌 기본 프로필 선택됨") // ✅ 선택 확인
            self?.addProfileView.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }))
        
        alertController.addAction(UIAlertAction(title: "사진 선택", style: .default, handler: { [weak self] _ in
            print("📌 사진 선택 눌림") // ✅ 선택 확인
            self?.selectProfileImage()
        }))
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alertController, animated: true) {
            print("📌 UIAlertController 화면에 표시됨") // ✅ 표시 확인
        }
    }
    // ✅ 배경 이미지 선택 옵션 (기본 이미지 or 사진 선택)
    @objc private func showBackgroundImageOptions() {
        let alertController = UIAlertController(title: "배경 사진", message: "선택하세요.", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "기본 배경", style: .default, handler: { [weak self] _ in
            self?.addProfileView.backgroundImageView.image = UIImage(named: "default_background") // 기본 배경 이미지 적용
            self?.selectedBackgroundImageURL = nil // 기본 배경 선택 시 업로드 없음
        }))
        
        alertController.addAction(UIAlertAction(title: "사진 선택", style: .default, handler: { [weak self] _ in
            self?.selectBackgroundImage() // 갤러리에서 선택
        }))
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    @objc private func selectProfileImage() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        picker.view.tag = 1
        present(picker, animated: true)
    }
    
    @objc private func selectBackgroundImage() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        picker.view.tag = 2 // ✅ 배경 이미지 구분용
        present(picker, animated: true)
    }
    // ✅ 한줄 소개 입력을 20자로 제한하는 함수
    @objc private func limitBioLength() {
        if let text = addProfileView.bioTextField.text, text.count > 20 {
            let index = text.index(text.startIndex, offsetBy: 20)
            addProfileView.bioTextField.text = String(text[..<index]) // 20자까지만 남김
        }
    }
    
    
    //공개
    
    @objc private func selectPublicAccount() {
        isPublicAccount = true // ✅ 선택됨
        addProfileView.publicButton.backgroundColor = UIColor.mainBrown800
        addProfileView.publicButton.setTitleColor(.white, for: .normal)
        addProfileView.privateButton.backgroundColor = .clear
        addProfileView.privateButton.setTitleColor(UIColor.mainBrown800, for: .normal)
        validateForm() // ✅ 유효성 검사
    }
    //비공개
    @objc private func selectPrivateAccount() {
        isPublicAccount = false // ✅ 선택됨
        addProfileView.privateButton.backgroundColor = UIColor.mainBrown800
        addProfileView.privateButton.setTitleColor(.white, for: .normal)
        addProfileView.publicButton.backgroundColor = .clear
        addProfileView.publicButton.setTitleColor(UIColor.mainBrown800, for: .normal)
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
        let isNicknameValid = !(addProfileView.nicknameTextField.text?.isEmpty ?? true)
        let isIdValid = !(addProfileView.idTextField.text?.isEmpty ?? true) && isIdChecked
        let isProfileImageSet = addProfileView.profileImageView.image != UIImage(named: "AddprofileMan")
        let isAccountSelected = isPublicAccount != nil // ✅ 공개/비공개 중 하나 선택 필수
        
        addProfileView.completeButton.isEnabled = isNicknameValid && isIdValid && isProfileImageSet && isAccountSelected
        addProfileView.completeButton.backgroundColor = addProfileView.completeButton.isEnabled ? UIColor.mainBrown800 : UIColor.lightGray
    }
    @objc private func didTapCompleteButton() {
        guard let nickname = addProfileView.nicknameTextField.text, !nickname.isEmpty,
              let id = addProfileView.idTextField.text, !id.isEmpty,
              let isPublic = isPublicAccount else {
            print("🚨 필수 정보가 입력되지 않음")
            return
        }
        
        let visibility = isPublic ? "PUBLIC" : "PRIVATE"
        let bioText = addProfileView.bioTextField.text ?? ""
        
        // ✅ 서버 없이 JSON 데이터 확인 (선택한 사진의 URL 반영됨)
        let profileData: [String: Any] = [
            "nickname": nickname,
            "clokeyId": id,
            "profileImageUrl": selectedProfileImageURL ?? "https://example.com/profile/default.jpg",
            "bio": bioText,
            "profileBackImageUrl": selectedBackgroundImageURL ?? "https://example.com/profile/default-background.jpg",
            "visibility": visibility
        ]
        
        // ✅ JSON 출력
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: profileData, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📡 준비된 API 요청 데이터:\n\(jsonString)")
            }
        } catch {
            print("🚨 JSON 변환 오류:", error.localizedDescription)
        }
        
        
        // ✅ JSON 출력 후 홈 화면으로 이동 (기능 유지)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.switchToMain()
            } else {
                print("🚨 SceneDelegate를 찾을 수 없음")
            }
        }
    }
    
    
    //    @objc private func didTapCompleteButton() {
    //        guard let nickname = addProfileView.nicknameTextField.text, !nickname.isEmpty,
    //              let id = addProfileView.idTextField.text, !id.isEmpty,
    //              let isPublic = isPublicAccount else {
    //            print("🚨 필수 정보가 입력되지 않음")
    //            return
    //        }
    //
    //        let visibility = isPublic ? "PUBLIC" : "PRIVATE"
    //        let bioText = addProfileView.bioTextField.text ?? ""
    //
    //        // `ProfileUpdateRequestDTO` 객체 생성
    //            let profileUpdateData = ProfileUpdateRequestDTO(
    //                nickname: nickname,
    //                clokeyId: id,
    //                profileImageUrl: selectedProfileImageURL ?? "https://example.com/default-profile.jpg",
    //                bio: bioText,
    //                profileBackImageUrl: selectedBackgroundImageURL ?? "https://example.com/default-background.jpg"
    //            )
    //
    //        let membersService = MembersService()
    //
    //            // 서버로 프로필 업데이트 요청
    //        membersService.updateProfile(data: profileUpdateData) { [weak self] result in
    //                guard let self = self else { return }
    //
    //                DispatchQueue.main.async {
    //                    switch result {
    //                    case .success(let response):
    //                        print("✅ 프로필 업데이트 성공: \(response)")
    //
    //                        // 홈 화면으로 이동
    //                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
    //                            sceneDelegate.switchToMain()
    //                        } else {
    //                            print("🚨 SceneDelegate를 찾을 수 없음")
    //                        }
    //
    //                    case .failure(let error):
    //                        print("🚨 프로필 업데이트 실패: \(error.localizedDescription)")
    //                    }
    //                }
    //            }
    //
    //    }
    // ✅ JSON 출력 후 홈 화면으로 이동 (기능 유지)
    
    // 이미지 선택
    @objc private func selectImage() {
        print("📌 selectImage() 호출됨") // ✅ 호출 확인
        
        let alertController = UIAlertController(title: "사진 선택", message: "프로필 사진을 선택하세요.", preferredStyle: .actionSheet)
        
        print("📌 UIAlertController 생성됨") // ✅ 생성 확인
        
        alertController.addAction(UIAlertAction(title: "기본 프로필", style: .default, handler: { [weak self] _ in
            print("📌 기본 프로필 선택됨") // ✅ 선택 확인
            self?.addProfileView.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
            self?.selectedProfileImageURL = nil
        }))
        
        alertController.addAction(UIAlertAction(title: "사진 선택", style: .default, handler: { [weak self] _ in
            print("📌 사진 선택 눌림") // ✅ 선택 확인
            self?.selectProfileImage()
        }))
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alertController, animated: true, completion: {
            print("📌 UIAlertController 화면에 표시됨") // ✅ 표시 확인
        })
    }
    // UIImagePickerControllerDelegate 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            if picker.view.tag == 1 { // ✅ 프로필 사진 선택
                addProfileView.profileImageView.image = selectedImage
                selectedProfileImageURL = "local://profileImage-\(UUID().uuidString)" // ✅ UUID로 고유한 URL 생성
            } else if picker.view.tag == 2 { // ✅ 배경 사진 선택
                addProfileView.backgroundImageView.image = selectedImage
                selectedBackgroundImageURL = "local://backgroundImage-\(UUID().uuidString)" // ✅ UUID로 고유한 URL 생성
            }
        }
        dismiss(animated: true)
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
        DispatchQueue.main.async { // ✅ UI 업데이트를 비동기적으로 실행
            self.layoutIfNeeded()
            
            // ✅ 기존 보더 제거 (중복 방지)
            self.layer.sublayers?.filter { $0.name == "bottomBorder" }.forEach { $0.removeFromSuperlayer() }
            
            // ✅ 텍스트 필드 크기가 0이면 보더 추가 안 함
            guard self.bounds.width > 0 else {
                print("⚠️ addBottomBorder: \(self.placeholder ?? "TextField") width is 0. Skipping border.")
                return
            }
            
            let border = CALayer()
            border.name = "bottomBorder"
            border.backgroundColor = color.cgColor
            
            // ✅ yOffset 수정 (bounds.height 활용)
            let yOffset = self.bounds.height - height
            
            border.frame = CGRect(x: 0, y: yOffset, width: self.bounds.width, height: height)
            self.layer.addSublayer(border)
        }
    }
    
}
