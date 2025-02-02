import UIKit

class LastAddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var clothName: String? // 전달받은 옷 이름
    var selectedSeasons: Set<String> = []
    var minTemp: Int?
    var maxTemp: Int?
    var thickCount: Int?
    var isPublicSelected: Bool?
    
    private let lastAddView = LastAddView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = lastAddView
        setupActions()
        
        lastAddView.endButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        
        // 🔹 화면 탭하면 키보드 내리기
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(tapGesture)
    }
    
    
    @objc private func dismissKeyboard() {
            view.endEditing(true) // 🔥 현재 화면에서 키보드 내리기
        }
    
    // 버튼 액션 설정
    private func setupActions() {
        lastAddView.addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    // 이미지 선택 버튼 눌렀을 때
    @objc private func addButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 이미지 선택 후 크롭해서 적용 & 버튼 숨기기
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            let resizedImage = resizeImage(image: selectedImage, targetSize: CGSize(width: 140, height: 187))
            lastAddView.imageView.image = resizedImage
            lastAddView.addButton.isHidden = true // 사진 갤러리에서 빼낸 뒤 버튼 숨기기
        }
    }
    
    // 이미지 선택 취소 시 호출
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 선택한 이미지를 강제로 140x187 크기로 변환하는 함수
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    @objc private func didTapNextButton() {
        let popupVC = PopupViewController()
        /***/
        popupVC.clothName = clothName // 값 전달
        popupVC.selectedSeasons = selectedSeasons
        popupVC.minTemp = minTemp
        popupVC.maxTemp = maxTemp
        popupVC.thickCount = thickCount
        popupVC.isPublicSelected = isPublicSelected
        popupVC.imageUrl = lastAddView.urlTextField.text
        popupVC.brand = lastAddView.brandTextField.text
        
        // 🔥 선택한 이미지를 전달
        popupVC.clothImage = lastAddView.imageView.image
        /***/
        popupVC.modalPresentationStyle = .fullScreen // ✅ 전체 화면 모달
        navigationController?.pushViewController(popupVC, animated: true)
    }
}
