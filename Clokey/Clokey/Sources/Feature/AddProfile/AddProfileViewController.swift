//
//  AddProfileViewController.swift
//  Clokey
//
//  Created by 한금준 on 1/18/25.
//


import UIKit
import TOCropViewController
import Moya

final class AddProfileViewController: UIViewController, TOCropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let navBarManager = NavigationBarManager()
    
    private let addProfileView = AddProfileView()
    private var isSelectingProfileImage = false
    
    var isIdChecked = false
    var isPublicAccount: Bool? = nil
    var isDuplicated: Bool = false
    private var isProfileImageSelected = false
    private var isBackgroundImageSelected = false
    
    // 로딩 인디케이터
    
    
    override func loadView() {
        view = addProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        addProfileView.isUserInteractionEnabled = true
        addProfileView.addImageButton1.isUserInteractionEnabled = true
        addProfileView.addImageButton2.isUserInteractionEnabled = true

        addProfileView.addImageButton1.addTarget(self, action: #selector(didTapAddImageButton(_:)), for: .touchUpInside)
        addProfileView.addImageButton2.addTarget(self, action: #selector(didTapAddImageButton(_:)), for: .touchUpInside)
        
        validateForm() // 초기 상태에서 유효성 검사 실행
        addActions()
        
        addProfileView.bioTextField.addTarget(self, action: #selector(limitBioLength), for: .editingChanged)
        
        //  화면 탭하면 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        //  키보드 이벤트 감지
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // 네비게이션 설정
    private func setupNavigationBar() {
        navBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(didTapBackButton)
        )
        
        navBarManager.setTitle(
            to: navigationItem,
            title: "프로필 설정",
            font: .ptdSemiBoldFont(ofSize: 20),
            textColor: .black
        )
    }
    
    // 뒤로가기
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc internal override func dismissKeyboard() {
        view.endEditing(true) //  현재 화면에서 키보드 내리기
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
//        let bottomInset = keyboardHeight - view.safeAreaInsets.bottom
        
        if let activeTextField = view.findFirstResponder() as? UITextField {
            let textFieldFrame = activeTextField.convert(activeTextField.bounds, to: view)
            let visibleHeight = view.frame.height - keyboardHeight
            
            if textFieldFrame.maxY > visibleHeight {
                let offset = textFieldFrame.maxY - visibleHeight
                view.frame.origin.y = -offset - 10 // 여유 공간 추가
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0 // 원래 위치로 복구
    }
    
    
    
    @objc private func didTapAddImageButton(_ sender: UIButton) {
        isSelectingProfileImage = (sender == addProfileView.addImageButton2)
        
        let bottomSheetVC = CustomBottomSheetViewController()
        bottomSheetVC.delegate = self // Delegate 연결
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        present(bottomSheetVC, animated: false)
    }
    
    
    private func setDefaultProfileImage() {
        let defaultImage = UIImage(named: "profile_basic") // 기본 이미지 설정
        let defaultImage2 = UIImage(named: "background_basic")
        if isSelectingProfileImage {
            addProfileView.profileImageView.image = defaultImage
        } else {
            addProfileView.backgroundImageView.image = defaultImage2
        }
        print("기본 프로필 이미지 설정 완료")
    }
    
    // 갤러리에서 이미지 선택하는 기능
    private func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }
    
    // 갤러리에서 이미지를 선택했을 때 호출됨
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            if isSelectingProfileImage {
                addProfileView.profileImageView.image = selectedImage
            } else {
                addProfileView.backgroundImageView.image = selectedImage
            }
            showCropViewController()
        }
    }
    
    // 크롭 화면 호출
    private func showCropViewController() {
        let imageToCrop = isSelectingProfileImage ? addProfileView.profileImageView.image : addProfileView.backgroundImageView.image
        guard let image = imageToCrop else { return }
        
        let cropViewController = TOCropViewController(croppingStyle: .default, image: image)
        cropViewController.delegate = self
        
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.customAspectRatio = CGSize(width: 1, height: 1)
        
        present(cropViewController, animated: true)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        if isSelectingProfileImage {
            addProfileView.profileImageView.image = image
        } else {
            addProfileView.backgroundImageView.image = image
        }
        
        print("이미지 크롭 완료!")
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        print("사용자가 크롭을 취소했습니다.")
        if isSelectingProfileImage {
            addProfileView.profileImageView.image = UIImage(named: "profile_basic")
        } else {
            addProfileView.backgroundImageView.image = UIImage(named: "profile_background")
        } //  기존 이미지 유지 또는 nil 처리
        cropViewController.dismiss(animated: true)
    }
    
    
    private func addActions() {
        
        addProfileView.nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addProfileView.nicknameTextField.addTarget(self, action: #selector(validateNickname), for: .editingChanged)
        
        addProfileView.idTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addProfileView.idCheckButton.addTarget(self, action: #selector(checkIdAvailability), for: .touchUpInside)
        
        addProfileView.publicButton.addTarget(self, action: #selector(selectPublicAccount), for: .touchUpInside)
        addProfileView.privateButton.addTarget(self, action: #selector(selectPrivateAccount), for: .touchUpInside)
        addProfileView.completeButton.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
    }
    
    
    // 텍스트 필드 변경 시 호출되는 메서드
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField == addProfileView.idTextField {
            isIdChecked = false //  아이디 입력이 바뀌면 다시 중복 확인 필요
            addProfileView.idCheckButton.isEnabled = true
            addProfileView.idCheckButton.setTitleColor(.black, for: .normal)
            
            // ID 입력 필드가 비어있다면 오류 메시지를 숨김 처리
            if let text = textField.text, text.isEmpty {
                addProfileView.idError(hidden: true)
            }
        }
        
        validateForm() //  다른 필드가 수정될 때도 완료 버튼 상태 업데이트
    }
    
    @objc private func validateNickname() {
        guard let text = addProfileView.nicknameTextField.text, !text.isEmpty else {
            addProfileView.nickNameError(hidden: true)
            return
        }
        
        addProfileView.nickNameError(hidden: false)
        
        if text.count > 6 {
            addProfileView.nicknameStatusLabel.text = "6글자 이내로 입력해주세요."
            addProfileView.nicknameStatusLabel.textColor = .pointOrange800
            
        } else {
            addProfileView.nicknameStatusLabel.text = "사용 가능한 닉네임입니다."
            addProfileView.nicknameStatusLabel.textColor = .pointOrange800
        }
        
        validateForm() // 🚀 폼 유효성 검사 실행
    }
    
    
    // 아이디 중복 확인
    @objc private func checkIdAvailability() {
        guard let id = addProfileView.idTextField.text, !id.isEmpty else {
            addProfileView.idError(hidden: true)
            return
        }
        
        addProfileView.idError(hidden: false)
        
        // 특수문자 및 대문자가 포함된 경우 중복 확인 진행 불가
        let containsUppercase = id.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
        let containsSpecialCharacter = id.rangeOfCharacter(from: CharacterSet.punctuationCharacters.union(.symbols)) != nil
        
        if containsUppercase || containsSpecialCharacter {
            
            addProfileView.idStatusLabel.text = "잘못 입력했습니다. 소문자와 숫자만 입력하세요."
            addProfileView.idStatusLabel.textColor = .pointOrange800
//            addProfileView.idStatusLabel.isHidden = false
            isIdChecked = false
            validateForm() //  유효성 검사 즉시 실행
            return
        }
        
        //  중복 확인 로직 (임시 더미 데이터 사용)
        let membersService = MembersService()
        membersService.checkIdAvailability(checkId: id) { [weak self] result in
            guard let self = self else { return }
            
            
            DispatchQueue.main.async {
                switch result {
                case .success:
//                    self.addProfileView.idError(hidden: false)
                    self.addProfileView.idStatusLabel.text = "사용 가능한 아이디입니다."
                    self.addProfileView.idStatusLabel.textColor = .pointOrange800
                    self.isIdChecked = true
//                    self.addProfileView.idStatusLabel.isHidden = false
                    self.addProfileView.idCheckButton.setTitleColor(.gray, for: .normal)
                    self.validateForm()
                    
                case .failure(_):
//                    self.addProfileView.idError(hidden: false)
                    self.addProfileView.idStatusLabel.text = "중복된 아이디입니다."
                    self.addProfileView.idStatusLabel.textColor = .pointOrange800
                    self.isIdChecked = false
//                    self.addProfileView.idStatusLabel.isHidden = false
                    self.addProfileView.idCheckButton.setTitleColor(.gray, for: .normal)
                    self.validateForm()
                }
            }
        }
    }
    
    //  한줄 소개 입력을 20자로 제한하는 함수
    @objc private func limitBioLength() {
        if let text = addProfileView.bioTextField.text, text.count > 20 {
            let index = text.index(text.startIndex, offsetBy: 20)
            addProfileView.bioTextField.text = String(text[..<index]) // 20자까지만 남김
        }
    }
    
    //공개
    @objc private func selectPublicAccount() {
        isPublicAccount = true
        addProfileView.publicButton.backgroundColor = UIColor.mainBrown800
        addProfileView.publicButton.setTitleColor(.white, for: .normal)
        addProfileView.privateButton.backgroundColor = .clear
        addProfileView.privateButton.setTitleColor(UIColor.black, for: .normal)
        validateForm()
    }
    //비공개
    @objc private func selectPrivateAccount() {
        isPublicAccount = false //  선택됨
        addProfileView.privateButton.backgroundColor = UIColor.mainBrown800
        addProfileView.privateButton.setTitleColor(.white, for: .normal)
        addProfileView.publicButton.backgroundColor = .clear
        addProfileView.publicButton.setTitleColor(UIColor.black, for: .normal)
        validateForm()
    }
    
    private func validateForm() {
        let nicknameText = addProfileView.nicknameTextField.text ?? ""
        let isNicknameValid = !nicknameText.isEmpty && nicknameText.count <= 6 //  닉네임이 비어있지 않고 6글자 이하인 경우 유효
        let isIdValid = !(addProfileView.idTextField.text?.isEmpty ?? true) && isIdChecked
        let isAccountSelected = isPublicAccount != nil //  공개/비공개 중 하나 선택 필수
//        let isAnyImageSelected = isProfileImageSelected && isBackgroundImageSelected //  프로필 또는 배경 둘 중 하나만 선택되면 OK
        let isAnyImageSelected = true //  사진 선택 여부 상관없이 활성화
        
        let isFormValid = isNicknameValid && isIdValid && isAccountSelected && isAnyImageSelected
        addProfileView.completeButton.isEnabled = isFormValid
        addProfileView.completeButton.backgroundColor = isFormValid ? UIColor.mainBrown800 : UIColor.mainBrown400
    }
    
    var nickName: String?
    
    @objc private func didTapCompleteButton() {
        guard let nickname = addProfileView.nicknameTextField.text, !nickname.isEmpty,
              let id = addProfileView.idTextField.text, !id.isEmpty,
              let isPublic = isPublicAccount else {
            print("🚨 필수 정보가 입력되지 않음")
            return
        }
        
//        let formattedId = "@\(id)"
        let bio = addProfileView.bioTextField.text ?? ""
        let visibility = isPublic ? "PUBLIC" : "PRIVATE"
        
        ProfileViewModel.shared.userId = id
        UserDefaults.standard.set(id, forKey: "userId")
        
        // 프로필 및 배경 이미지가 선택되지 않은 경우 기본 이미지 할당
        let profileImage = addProfileView.profileImageView.image ?? UIImage(named: "profile_basic")!
        let backgroundImage = addProfileView.backgroundImageView.image ?? UIImage(named: "background_basic")!
        
        let resizedProfile = resizeImage(image: profileImage, targetSize: CGSize(width: 800, height: 800))
        let resizedBack = resizeImage(image: backgroundImage, targetSize: CGSize(width: 800, height: 800))
        
        guard let profileData = resizedProfile?.jpegData(compressionQuality: 0.5),
              let backData = resizedBack?.jpegData(compressionQuality: 0.5) else {
            print("🚨 이미지 변환 실패")
            return
        }
        
        //  ProfileUpdateRequestDTO 생성 및 JSON 데이터 확인
        let profileUpdateData = ProfileUpdateRequestDTO(
            nickname: nickname,
            clokeyId: id,
            bio: bio,
            visibility: visibility
        )

        do {
            let jsonData = try JSONEncoder().encode(profileUpdateData)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "JSON 변환 실패"
            print(" 전송될 JSON 데이터: \(jsonString)")
        } catch {
            print("🚨 JSON 인코딩 오류: \(error.localizedDescription)")
        }

        //  API 호출
        let membersService = MembersService()
        membersService.updateProfile(
            data: profileUpdateData,
            imageData1: profileData,
            imageData2: backData
        ) { result in
            switch result {
            case .success(let response):
                print(" 프로필 업데이트 성공: \(response)")
                DispatchQueue.main.async {
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.switchToMain()
                    } else {
                        print("🚨 SceneDelegate를 찾을 수 없음")
                    }
                }
            case .failure(let error):
                print("🚨 프로필 업데이트 실패 - 네트워크 오류: \(error.localizedDescription)")
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = CGSize(width: size.width * min(widthRatio, heightRatio),
                             height: size.height * min(widthRatio, heightRatio))
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
// 
    deinit {
        // 키보드 옵저버 제거
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension AddProfileViewController: CustomBottomSheetDelegate {
    func didTapChoosePhoto() {
        if isSelectingProfileImage {
            isProfileImageSelected = true //  프로필 사진 선택됨
        } else {
            isBackgroundImageSelected = true //  배경 사진 선택됨
        }
        
        showImagePicker()
        validateForm() //  완료 버튼 활성화 여부 체크
    }
    
    func didTapDefaultProfile() {
        if isSelectingProfileImage {
            isProfileImageSelected = true //  기본 프로필 선택됨
        } else {
            isBackgroundImageSelected = true //  기본 배경 선택됨
        }
        
        setDefaultProfileImage()
        validateForm() //  완료 버튼 활성화 여부 체크
    }
}

extension UIView {
    func findFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        
        for subview in subviews {
            if let responder = subview.findFirstResponder() {
                return responder
            }
        }
        
        return nil
    }
}
