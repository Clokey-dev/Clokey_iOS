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
    
    // MARK: - Lifecycle
    
    var viewModel = AddProfileViewModel() // AddProfileViewModel 사용
    var isIdChecked = false
    
    var isPublicAccount: Bool? = nil // ✅ 초기값: 선택되지 않음
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = addProfileView
        
        setupNavigation()
        addActions()
        imagePickerController.delegate = self
        validateForm() // 초기 상태에서 유효성 검사 실행
        addProfileView.idTextField.addBottomBorder(color: .black, height: 1.0)
        addProfileView.nicknameTextField.addBottomBorder(color: .black, height: 1.0)
        self.title = "프로필 설정" //  상단 타이틀 추가
        addProfileView.nicknameTextField.delegate = self
        addProfileView.idTextField.delegate = self
        
    }
    // MARK: - UI Setup
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // ✅ 레이아웃이 완료된 후 border 추가 (NaN 방지)
        addProfileView.nicknameTextField.addBottomBorder(color: .black, height: 1.0)
        addProfileView.idTextField.addBottomBorder(color: .black, height: 1.0)
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
        addProfileView.addImageButton2.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        
        addProfileView.nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addProfileView.idTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    @objc private func didTapBackButton() {
        self.dismiss(animated: true, completion: nil)
    }

    // 텍스트 필드 변경 시 호출되는 메서드
    @objc private func textFieldDidChange() {
        addProfileView.idCheckButton.setTitleColor(.black, for: .normal) // 버튼 색 원래대로
        isIdChecked = false // 다시 중복 확인해야 함
        addProfileView.idStatusLabel.text = "" // 중복 메시지 삭제
        validateForm()
    }
    
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

             
    //공개
   
    @objc private func selectPublicAccount() {
        isPublicAccount = true // ✅ 선택됨
        addProfileView.publicButton.backgroundColor = UIColor.brown
        addProfileView.publicButton.setTitleColor(.white, for: .normal)
        addProfileView.privateButton.backgroundColor = .clear
        addProfileView.privateButton.setTitleColor(UIColor.brown, for: .normal)
        validateForm() // ✅ 유효성 검사
    }
//비공개
    @objc private func selectPrivateAccount() {
        isPublicAccount = false // ✅ 선택됨
        addProfileView.privateButton.backgroundColor = UIColor.brown
        addProfileView.privateButton.setTitleColor(.white, for: .normal)
        addProfileView.publicButton.backgroundColor = .clear
        addProfileView.publicButton.setTitleColor(UIColor.brown, for: .normal)
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
        addProfileView.completeButton.backgroundColor = addProfileView.completeButton.isEnabled ? UIColor.brown : UIColor.lightGray
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
            self?.addProfileView.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
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
            addProfileView.profileImageView.image = editedImage // 편집된 이미지 사용
        } else if let originalImage = info[.originalImage] as? UIImage {
            addProfileView.profileImageView.image = originalImage // 원본 이미지 사용
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
