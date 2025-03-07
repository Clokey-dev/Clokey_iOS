import UIKit
import TOCropViewController

class LastAddViewController: UIViewController, TOCropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    private let navBarManager = NavigationBarManager()
    
    var clothId: Int64 = 0 {
        didSet {
            isEditingMode = (clothId != 0) // clothId가 0이면 추가, 0이 아니면 수정 모드
        }
    }
    var isEditingMode: Bool = false
    
    var editClothUrl: String?
    var editBrand: String?
    var editImageUrl: String?
    
    
    var clothName: String? // 전달받은 옷 이름
    var categoryName: String?
    var categoryCloth: String?
    var categoryId: Int64?
    var selectedSeasons: Set<String> = []
    var minTemp: Int?
    var maxTemp: Int?
    var thickCount: Int?
    var isPublicSelected: Bool?
    
    private let lastAddView = LastAddView()
    private var isSelectingProfileImage = false
    
    override func loadView() {
        view = lastAddView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        lastAddView.isUserInteractionEnabled = true
        lastAddView.addButton.isUserInteractionEnabled = true
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        setupActions()
        
        //  화면 탭하면 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        //  키보드 이벤트 감지
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        applyExistingValues()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    // 네비게이션 설정
    private func setupNavigationBar() {
        navBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(didTapBackButton)
        )
        
        if isEditingMode == true {
            navBarManager.setTitle(
                to: navigationItem,
                title: "옷수정",
                font: .ptdSemiBoldFont(ofSize: 20),
                textColor: .black
            )
        } else {
            navBarManager.setTitle(
                to: navigationItem,
                title: "옷추가",
                font: .ptdSemiBoldFont(ofSize: 20),
                textColor: .black
            )
        }
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
    
    // 버튼 액션 설정
    private func setupActions() {
//        lastAddView.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        lastAddView.addButton.addTarget(self, action: #selector(didTapAddImageButton(_:)), for: .touchUpInside)
        
        lastAddView.endButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
    }
    
    
    @objc private func didTapAddImageButton(_ sender: UIButton) {
        isSelectingProfileImage = true
        showImagePicker() // 이미지 선택 기능 호출
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
                lastAddView.imageView.image = selectedImage
            }
            showCropViewController()
        }
    }
    
    
    // 크롭 화면 호출
    private func showCropViewController() {
        guard let imageToCrop = lastAddView.imageView.image else { return } // 선택된 이미지 가져오기
        
        let cropViewController = TOCropViewController(croppingStyle: .default, image: imageToCrop)
        cropViewController.delegate = self
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.customAspectRatio = CGSize(width: 3, height: 4)
        
        present(cropViewController, animated: true)
    }
    
    // 크롭 완료 후 이미지 설정
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        lastAddView.imageView.image = image // 크롭된 이미지를 프로필 이미지로 설정
        print("이미지 크롭 완료!")
        cropViewController.dismiss(animated: true)
    }
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        print("사용자가 크롭을 취소했습니다.")
        isSelectingProfileImage = false //  프로필 이미지 선택 상태 해제
        lastAddView.imageView.image = UIImage(named: "beforeaddimage") //  기존 이미지 유지 또는 nil 처리
        cropViewController.dismiss(animated: true)
    }
    
    
    
    @objc private func didTapNextButton() {
        let popupVC = PopupViewController()
        
        if isEditingMode {
            popupVC.clothId = clothId
            popupVC.clothName = clothName // 값 전달
            popupVC.categoryName = categoryName
            popupVC.categoryCloth = categoryCloth
            popupVC.categoryId = categoryId
            popupVC.selectedSeasons = selectedSeasons
            popupVC.minTemp = minTemp
            popupVC.maxTemp = maxTemp
            popupVC.thickCount = thickCount
            popupVC.isPublicSelected = isPublicSelected
            popupVC.imageUrl = lastAddView.urlTextField.text
            popupVC.brand = lastAddView.brandTextField.text
            
            //  선택한 이미지를 전달
            if let selectedImage = lastAddView.imageView.image,
               let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
                popupVC.cloth = selectedImage
                popupVC.clothImage = imageData
            } else {
                popupVC.clothImage = nil // 이미지가 없을 경우 nil 전달
            }
            
            navigationController?.pushViewController(popupVC, animated: true)
        } else {
            popupVC.clothName = clothName // 값 전달
            popupVC.categoryName = categoryName
            popupVC.categoryCloth = categoryCloth
            popupVC.categoryId = categoryId
            popupVC.selectedSeasons = selectedSeasons
            popupVC.minTemp = minTemp
            popupVC.maxTemp = maxTemp
            popupVC.thickCount = thickCount
            popupVC.isPublicSelected = isPublicSelected
            popupVC.imageUrl = lastAddView.urlTextField.text
            popupVC.brand = lastAddView.brandTextField.text
            
            //  선택한 이미지를 전달
            if let selectedImage = lastAddView.imageView.image,
               let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
                popupVC.cloth = selectedImage
                popupVC.clothImage = imageData
            } else {
                popupVC.clothImage = nil // 이미지가 없을 경우 nil 전달
            }
            navigationController?.pushViewController(popupVC, animated: true)
        }
    }
    
    private func applyExistingValues() {
        //  clothUrl 적용
        if let clothUrl = editClothUrl {
            lastAddView.urlTextField.text = clothUrl
            print("clothUrl 적용됨: \(clothUrl)")
        }
        
        //  브랜드명 적용
        if let brand = editBrand {
            lastAddView.brandTextField.text = brand
            print("브랜드명 적용됨: \(brand)")
        }
        
        //  이미지 적용
        if let imageUrl = editImageUrl, let url = URL(string: imageUrl) {
            print("최종 이미지 URL: \(imageUrl)")
            
            lastAddView.imageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholderImage"),
                options: [.forceRefresh],
                completionHandler: { result in
                    switch result {
                    case .success(let value):
                        print("Kingfisher 이미지 다운로드 성공")
                        self.lastAddView.imageView.image = value.image
                    case .failure(let error):
                        print("Kingfisher 이미지 다운로드 실패: \(error.localizedDescription)")
                    }
                }
            )
        } else {
            print("editImageUrl이 nil 또는 URL 변환 실패")
        }
    }
}
