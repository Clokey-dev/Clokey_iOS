//
//  EditProfileViewController.swift
//  Clokey
//
//  Created by 한금준 on 2/4/25.
//

import UIKit
import TOCropViewController

final class EditProfileViewController: UIViewController, TOCropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let editProfileView = EditProfileView()
    private var isSelectingProfileImage = false
    
    var isIdChecked = false
    var isPublicAccount: Bool? = nil // ✅ 초기값: 선택되지 않음
    var isDuplicated: Bool = false
    
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
    }
    
    @objc internal override func dismissKeyboard() {
        view.endEditing(true) // 🔥 현재 화면에서 키보드 내리기
    }
    
    @objc private func didTapAddImageButton(_ sender: UIButton) {
        isSelectingProfileImage = (sender == editProfileView.addImageButton2)

        let bottomSheetVC = CustomBottomSheetViewController()
        bottomSheetVC.delegate = self // Delegate 연결
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        present(bottomSheetVC, animated: false)
    }

    
    private func setDefaultProfileImage() {
        let defaultImage = UIImage(named: "AddprofileMan") // 기본 이미지 설정
        if isSelectingProfileImage {
            editProfileView.profileImageView.image = defaultImage
        } else {
            editProfileView.backgroundImageView.image = defaultImage
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
    @objc private func textFieldDidChange() {
        editProfileView.idCheckButton.setTitleColor(.black, for: .normal) // 버튼 색 원래대로
        isIdChecked = false // 다시 중복 확인해야 함
        editProfileView.idStatusLabel.text = "" // 중복 메시지 삭제
        validateForm()
    }
    
    @objc private func validateNickname() {
        guard let text = editProfileView.nicknameTextField.text, !text.isEmpty else {
            editProfileView.nicknameStatusLabel.text = ""
            editProfileView.nicknameStatusLabel.isHidden = true // 입력 없으면 숨김
            return
        }
        
        if text.count > 6 {
            editProfileView.nicknameStatusLabel.text = "6글자 이내로 입력해주세요."
            editProfileView.nicknameStatusLabel.textColor = .orange
            editProfileView.nicknameStatusLabel.isHidden = false // 🚀 오류 메시지 보이게 설정
        } else {
            editProfileView.nicknameStatusLabel.text = "사용 가능한 닉네임입니다."
            editProfileView.nicknameStatusLabel.textColor = .orange
            editProfileView.nicknameStatusLabel.isHidden = false // 🚀 유효한 경우에도 표시
        }
        
        validateForm() // 🚀 폼 유효성 검사 실행
    }
    
    
    // 아이디 중복 확인
    @objc private func checkIdAvailability() {
        guard let id = editProfileView.idTextField.text, !id.isEmpty else { return }

        if isDuplicated {
            editProfileView.idStatusLabel.text = "중복된 아이디입니다."
            editProfileView.idStatusLabel.textColor = .red
            isIdChecked = false
        } else {
            editProfileView.idStatusLabel.text = "사용 가능한 아이디입니다."
            editProfileView.idStatusLabel.textColor = .red
            isIdChecked = true
        }
        
        editProfileView.idCheckButton.setTitleColor(.gray, for: .normal) // ✅ 버튼 색 변경
        validateForm()
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
        editProfileView.publicButton.backgroundColor = UIColor.brown
        editProfileView.publicButton.setTitleColor(.white, for: .normal)
        editProfileView.privateButton.backgroundColor = .clear
        editProfileView.privateButton.setTitleColor(UIColor.brown, for: .normal)
        validateForm()
    }
    //비공개
    @objc private func selectPrivateAccount() {
        isPublicAccount = false // ✅ 선택됨
        editProfileView.privateButton.backgroundColor = UIColor.brown
        editProfileView.privateButton.setTitleColor(.white, for: .normal)
        editProfileView.publicButton.backgroundColor = .clear
        editProfileView.publicButton.setTitleColor(UIColor.brown, for: .normal)
        validateForm()
    }
    
    private func validateForm() {
        let isNicknameValid = !(editProfileView.nicknameTextField.text?.isEmpty ?? true)
        let isIdValid = !(editProfileView.idTextField.text?.isEmpty ?? true) && isIdChecked
        let isProfileImageSet = editProfileView.profileImageView.image != UIImage(named: "AddprofileMan")
        let isAccountSelected = isPublicAccount != nil // ✅ 공개/비공개 중 하나 선택 필수
        
        editProfileView.completeButton.isEnabled = isNicknameValid && isIdValid && isProfileImageSet && isAccountSelected
        editProfileView.completeButton.backgroundColor = editProfileView.completeButton.isEnabled ? UIColor.brown : UIColor.lightGray
    }
    
    @objc private func didTapCompleteButton() {
        guard let nickname = editProfileView.nicknameTextField.text, !nickname.isEmpty,
              let id = editProfileView.idTextField.text, !id.isEmpty,
              let isPublic = isPublicAccount else {
            print("🚨 필수 정보가 입력되지 않음")
            return
        }
        
        let visibility = isPublic ? "PUBLIC" : "PRIVATE"
        let bioText = editProfileView.bioTextField.text ?? ""
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
//            sceneDelegate.switchToMain()
        } else {
            print("🚨 SceneDelegate를 찾을 수 없음")
        }
    }
}
extension EditProfileViewController: CustomBottomSheetDelegate {
    func didTapChoosePhoto() {
        print("📸 showImagePicker() 호출됨")
        showImagePicker()
    }

    func didTapDefaultProfile() {
        print("👤 기본 프로필 설정 호출됨")
        setDefaultProfileImage()
    }
}



// 갤러리에서 이미지 선택 버튼
//    @objc private func didTapAddImageButton(_ sender: UIButton) {
//        isSelectingProfileImage = (sender == editProfileView.addImageButton2)
//        showImagePicker()
//    }

