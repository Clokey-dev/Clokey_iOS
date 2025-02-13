import UIKit
import TOCropViewController

class LastAddViewController: UIViewController, TOCropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        
        lastAddView.isUserInteractionEnabled = true
        lastAddView.addButton.isUserInteractionEnabled = true
        
        setupActions()
        
        // 🔹 화면 탭하면 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
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
    
    // 버튼 액션 설정
    private func setupActions() {
        lastAddView.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        lastAddView.addButton.addTarget(self, action: #selector(didTapAddImageButton(_:)), for: .touchUpInside)
        
        lastAddView.endButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
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
    
   
    
    @objc private func didTapNextButton() {
        let popupVC = PopupViewController()
        /***/
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
        
        // 🔥 선택한 이미지를 전달
        if let selectedImage = lastAddView.imageView.image,
           let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            popupVC.cloth = selectedImage
            popupVC.clothImage = imageData
        } else {
            popupVC.clothImage = nil // 이미지가 없을 경우 nil 전달
        }
        /***/
        popupVC.modalPresentationStyle = .fullScreen // ✅ 전체 화면 모달
        navigationController?.pushViewController(popupVC, animated: true)
    }
}
