//
//  EditProfileViewController.swift
//  Clokey
//
//  Created by 한금준 on 2/4/25.
//

import UIKit
import TOCropViewController
import Moya

final class EditProfileViewController: UIViewController, TOCropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let editProfileView = EditProfileView()
    private var isSelectingProfileImage = false
    
    var isIdChecked = false
    var isPublicAccount: Bool? = nil // ✅ 초기값: 선택되지 않음
    var isDuplicated: Bool = false
    private var isProfileImageSelected = false  // ✅ 프로필 사진 선택 여부
    private var isBackgroundImageSelected = false // ✅ 배경 사진 선택 여부
    
    override func loadView() {
        view = editProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editProfileView.isUserInteractionEnabled = true
        editProfileView.addImageButton1.isUserInteractionEnabled = true
        editProfileView.addImageButton2.isUserInteractionEnabled = true
        
        editProfileView.addImageButton1.addTarget(self, action: #selector(didTapAddImageButton(_:)), for: .touchUpInside)
        editProfileView.addImageButton2.addTarget(self, action: #selector(didTapAddImageButton(_:)), for: .touchUpInside)
        
        validateForm() // 초기 상태에서 유효성 검사 실행
        addActions()
        
        editProfileView.bioTextField.addTarget(self, action: #selector(limitBioLength), for: .editingChanged)
        
        // 🔹 화면 탭하면 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // 🔹 키보드 이벤트 감지
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc internal override func dismissKeyboard() {
        view.endEditing(true) // 🔥 현재 화면에서 키보드 내리기
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        let bottomInset = keyboardHeight - view.safeAreaInsets.bottom
        
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
        isSelectingProfileImage = (sender == editProfileView.addImageButton2)
        
        let bottomSheetVC = CustomBottomSheetViewController()
        bottomSheetVC.delegate = self // Delegate 연결
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        present(bottomSheetVC, animated: false)
    }
    
    
    private func setDefaultProfileImage() {
        let defaultImage = UIImage(named: "profile_basic") // 기본 이미지 설정
        let defaultImage2 = UIImage(named: "background_basic")
        if isSelectingProfileImage {
            editProfileView.profileImageView.image = defaultImage
        } else {
            editProfileView.backgroundImageView.image = defaultImage2
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
                editProfileView.profileImageView.image = selectedImage
            } else {
                editProfileView.backgroundImageView.image = selectedImage
            }
            showCropViewController()
        }
    }
    
    // 크롭 화면 호출
    private func showCropViewController() {
        let imageToCrop = isSelectingProfileImage ? editProfileView.profileImageView.image : editProfileView.backgroundImageView.image
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
            editProfileView.profileImageView.image = image
        } else {
            editProfileView.backgroundImageView.image = image
        }
        
        print("이미지 크롭 완료!")
        cropViewController.dismiss(animated: true)
    }
    
    
    private func addActions() {
        
        editProfileView.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        editProfileView.nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        editProfileView.nicknameTextField.addTarget(self, action: #selector(validateNickname), for: .editingChanged)
        
        editProfileView.idTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        editProfileView.idCheckButton.addTarget(self, action: #selector(checkIdAvailability), for: .touchUpInside)
        
        editProfileView.publicButton.addTarget(self, action: #selector(selectPublicAccount), for: .touchUpInside)
        editProfileView.privateButton.addTarget(self, action: #selector(selectPrivateAccount), for: .touchUpInside)
        editProfileView.completeButton.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
    }
    
    
    @objc private func didTapBackButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 텍스트 필드 변경 시 호출되는 메서드
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField == editProfileView.idTextField {
            isIdChecked = false // ✅ 아이디 입력이 바뀌면 다시 중복 확인 필요
            editProfileView.idCheckButton.isEnabled = true
            editProfileView.idCheckButton.setTitleColor(.black, for: .normal)
            
            // ID 입력 필드가 비어있다면 오류 메시지를 숨김 처리
            if let text = textField.text, text.isEmpty {
                editProfileView.idError(hidden: true)
            }
        }
        
        validateForm() // ✅ 다른 필드가 수정될 때도 완료 버튼 상태 업데이트
    }
    
    @objc private func validateNickname() {
        guard let text = editProfileView.nicknameTextField.text, !text.isEmpty else {
//            addProfileView.nicknameStatusLabel.text = ""
//            addProfileView.nicknameStatusLabel.isHidden = true // 입력 없으면 숨김
            editProfileView.nickNameError(hidden: true)
            return
        }
        
        editProfileView.nickNameError(hidden: false)
        
        if text.count > 6 {
            editProfileView.nicknameStatusLabel.text = "6글자 이내로 입력해주세요."
            editProfileView.nicknameStatusLabel.textColor = .pointOrange800
//            addProfileView.nicknameStatusLabel.isHidden = false // 🚀 오류 메시지 보이게 설정
            
        } else {
            editProfileView.nicknameStatusLabel.text = "사용 가능한 닉네임입니다."
            editProfileView.nicknameStatusLabel.textColor = .pointOrange800
//            addProfileView.nicknameStatusLabel.isHidden = false // 🚀 유효한 경우에도 표시
        }
        
        validateForm() // 🚀 폼 유효성 검사 실행
    }
    
    
    // 아이디 중복 확인
    @objc private func checkIdAvailability() {
        guard let id = editProfileView.idTextField.text, !id.isEmpty else {
            editProfileView.idError(hidden: true)
            return
        }
        
        editProfileView.idError(hidden: false)
        
        // 특수문자 및 대문자가 포함된 경우 중복 확인 진행 불가
        let containsUppercase = id.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
        let containsSpecialCharacter = id.rangeOfCharacter(from: CharacterSet.punctuationCharacters.union(.symbols)) != nil
        
        if containsUppercase || containsSpecialCharacter {
            
            editProfileView.idStatusLabel.text = "잘못 입력했습니다. 소문자와 숫자만 입력하세요."
            editProfileView.idStatusLabel.textColor = .pointOrange800
//            addProfileView.idStatusLabel.isHidden = false
            isIdChecked = false
            validateForm() // ✅ 유효성 검사 즉시 실행
            return
        }
        
        // ✅ 중복 확인 로직 (임시 더미 데이터 사용)
        let membersService = MembersService()
        membersService.checkIdAvailability(checkId: id) { [weak self] result in
            guard let self = self else { return }
            
            
            DispatchQueue.main.async {
                switch result {
                case .success:
//                    self.addProfileView.idError(hidden: false)
                    self.editProfileView.idStatusLabel.text = "사용 가능한 아이디입니다."
                    self.editProfileView.idStatusLabel.textColor = .pointOrange800
                    self.isIdChecked = true
//                    self.addProfileView.idStatusLabel.isHidden = false
                    self.editProfileView.idCheckButton.setTitleColor(.gray, for: .normal)
                    self.validateForm()
                    
                case .failure(let error):
//                    self.addProfileView.idError(hidden: false)
                    self.editProfileView.idStatusLabel.text = "중복된 아이디입니다."
                    self.editProfileView.idStatusLabel.textColor = .pointOrange800
                    self.isIdChecked = false
//                    self.addProfileView.idStatusLabel.isHidden = false
                    self.editProfileView.idCheckButton.setTitleColor(.gray, for: .normal)
                    self.validateForm()
                }
            }
        }
    }
    
    // ✅ 한줄 소개 입력을 20자로 제한하는 함수
    @objc private func limitBioLength() {
        if let text = editProfileView.bioTextField.text, text.count > 20 {
            let index = text.index(text.startIndex, offsetBy: 20)
            editProfileView.bioTextField.text = String(text[..<index]) // 20자까지만 남김
        }
    }
    
    //공개
    @objc private func selectPublicAccount() {
        isPublicAccount = true
        editProfileView.publicButton.backgroundColor = UIColor.mainBrown800
        editProfileView.publicButton.setTitleColor(.white, for: .normal)
        editProfileView.privateButton.backgroundColor = .clear
        editProfileView.privateButton.setTitleColor(UIColor.black, for: .normal)
        validateForm()
    }
    //비공개
    @objc private func selectPrivateAccount() {
        isPublicAccount = false // ✅ 선택됨
        editProfileView.privateButton.backgroundColor = UIColor.mainBrown800
        editProfileView.privateButton.setTitleColor(.white, for: .normal)
        editProfileView.publicButton.backgroundColor = .clear
        editProfileView.publicButton.setTitleColor(UIColor.black, for: .normal)
        validateForm()
    }
    
    private func validateForm() {
        let nicknameText = editProfileView.nicknameTextField.text ?? ""
        let isNicknameValid = !nicknameText.isEmpty && nicknameText.count <= 6 // ✅ 닉네임이 비어있지 않고 6글자 이하인 경우 유효
        let isIdValid = !(editProfileView.idTextField.text?.isEmpty ?? true) && isIdChecked
        let isAccountSelected = isPublicAccount != nil // ✅ 공개/비공개 중 하나 선택 필수
//        let isAnyImageSelected = isProfileImageSelected && isBackgroundImageSelected // ✅ 프로필 또는 배경 둘 중 하나만 선택되면 OK
        let isAnyImageSelected = true // ✅ 사진 선택 여부 상관없이 활성화
        
        let isFormValid = isNicknameValid && isIdValid && isAccountSelected && isAnyImageSelected
        editProfileView.completeButton.isEnabled = isFormValid
        editProfileView.completeButton.backgroundColor = isFormValid ? UIColor.mainBrown800 : UIColor.mainBrown400
    }
    
    var nickName: String?
    
    @objc private func didTapCompleteButton() {
        guard let nickname = editProfileView.nicknameTextField.text, !nickname.isEmpty,
              let id = editProfileView.idTextField.text, !id.isEmpty,
              let isPublic = isPublicAccount else {
            print("🚨 필수 정보가 입력되지 않음")
            return
        }
        
        let formattedId = "@\(id)"
        let bio = editProfileView.bioTextField.text ?? ""
        let visibility = isPublic ? "PUBLIC" : "PRIVATE"
        
        ProfileViewModel.shared.userId = id
        
        // ✅ 프로필 이미지와 배경 이미지 크기 조정 및 압축 적용
        guard let profileImage = editProfileView.profileImageView.image,
              let backgroundImage = editProfileView.backgroundImageView.image else {
            print("🚨 이미지가 선택되지 않음")
            return
        }
        
        let resizedProfile = resizeImage(image: profileImage, targetSize: CGSize(width: 800, height: 800))
        let resizedBack = resizeImage(image: backgroundImage, targetSize: CGSize(width: 800, height: 800))
        
        guard let profileData = resizedProfile?.jpegData(compressionQuality: 0.5),
              let backData = resizedBack?.jpegData(compressionQuality: 0.5) else {
            print("🚨 이미지 변환 실패")
            return
        }
        
        // ✅ ProfileUpdateRequestDTO 생성 및 JSON 데이터 확인
        let profileUpdateData = ProfileUpdateRequestDTO(
            nickname: nickname,
            clokeyId: id,
            bio: bio,
            visibility: visibility
        )

        do {
            let jsonData = try JSONEncoder().encode(profileUpdateData)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "JSON 변환 실패"
            print("✅ 전송될 JSON 데이터: \(jsonString)")
        } catch {
            print("🚨 JSON 인코딩 오류: \(error.localizedDescription)")
        }

        // ✅ API 호출
        let membersService = MembersService()
        membersService.updateProfile(
            data: profileUpdateData,
            imageData1: profileData,
            imageData2: backData
        ) { result in
            switch result {
            case .success(let response):
                print("✅ 프로필 업데이트 성공: \(response)")
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
//                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                if let response = (error as? MoyaError)?.response {
                    let responseBody = String(data: response.data, encoding: .utf8) ?? "응답 데이터 없음"
                    print("🚨 프로필 업데이트 실패 - 상태 코드: \(response.statusCode), 응답: \(responseBody)")
                } else {
                    print("🚨 프로필 업데이트 실패 - 네트워크 오류: \(error.localizedDescription)")
                }
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

extension EditProfileViewController: CustomBottomSheetDelegate {
    func didTapChoosePhoto() {
        if isSelectingProfileImage {
            isProfileImageSelected = true // ✅ 프로필 사진 선택됨
        } else {
            isBackgroundImageSelected = true // ✅ 배경 사진 선택됨
        }
        
        showImagePicker()
        validateForm() // ✅ 완료 버튼 활성화 여부 체크
    }
    
    func didTapDefaultProfile() {
        if isSelectingProfileImage {
            isProfileImageSelected = true // ✅ 기본 프로필 선택됨
        } else {
            isBackgroundImageSelected = true // ✅ 기본 배경 선택됨
        }
        
        setDefaultProfileImage()
        validateForm() // ✅ 완료 버튼 활성화 여부 체크
    }
}

//extension UIView {
//    func findFirstResponder() -> UIResponder? {
//        if self.isFirstResponder {
//            return self
//        }
//        
//        for subview in subviews {
//            if let responder = subview.findFirstResponder() {
//                return responder
//            }
//        }
//        
//        return nil
//    }
//}
