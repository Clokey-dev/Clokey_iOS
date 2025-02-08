import UIKit
import SnapKit


class AddClothViewController: UIViewController, UITextFieldDelegate {
    private let addClothesView = AddClothesView()
    
    override func loadView() {
        view = addClothesView
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        addClothesView.inputField.delegate = self
        
        setupAction()
        
        // 🔹 화면 탭하면 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true) // 🔥 현재 화면에서 키보드 내리기
    }
   
    private func setupAction() {
        addClothesView.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        addClothesView.inputField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged) // ✅ 텍스트 변경 감지
        addClothesView.inputButton.addTarget(self, action: #selector(handleInput), for: .touchUpInside)

        addClothesView.reclassifyButton.addTarget(self, action: #selector(handleReclassify), for: .touchUpInside)
        
        addClothesView.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        
    }
    
    //
    @objc private func didTapNextButton() {
        // 입력 필드 값 가져오기
        guard let clothName = addClothesView.inputField.text, !clothName.isEmpty else {
            print("❌ 텍스트 필드가 비어 있습니다.")
            return
        }
        
        // WeatherClothesViewController로 이동
        let weatherVC = WeatherChooseViewController()
        weatherVC.clothName = clothName // 값 전달
        if let navController = self.navigationController {
            navController.pushViewController(weatherVC, animated: true)
        } else {
            weatherVC.modalPresentationStyle = .fullScreen
            self.present(weatherVC, animated: true, completion: nil)
        }
    }
    
    
    //
    // MARK: - Action Handlers
    @objc private func handleInput() {
        guard let text = addClothesView.inputField.text, !text.isEmpty else {
            print("❌ 입력 필드가 비어 있음")
            return
        }
        
        addClothesView.categoryTagsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let category1 = makeCategoryTag(title: "상의")
        let separator = makeSeparator()
        let category2 = makeCategoryTag(title: "후드티")
        
        addClothesView.categoryTagsContainer.addArrangedSubview(category1)
        addClothesView.categoryTagsContainer.addArrangedSubview(separator)
        addClothesView.categoryTagsContainer.addArrangedSubview(category2)
        
        addClothesView.categoryContainer.isHidden = false
        
        // ✅ 입력 버튼이 눌렸을 때만 nextButton 활성화 & 색상 변경
        addClothesView.nextButton.isEnabled = true
        addClothesView.nextButton.backgroundColor = .mainBrown800
        
        // ✅ reclassifyButton이 터치 가능 상태인지 확인
           addClothesView.reclassifyButton.isUserInteractionEnabled = true
           addClothesView.reclassifyButton.isHidden = false
           addClothesView.reclassifyButton.alpha = 1.0 // ✅ 투명도 문제 해결

           print("📌 reclassifyButton isUserInteractionEnabled: \(addClothesView.reclassifyButton.isUserInteractionEnabled)")
           print("📌 reclassifyButton isHidden: \(addClothesView.reclassifyButton.isHidden)")
           print("📌 reclassifyButton frame: \(addClothesView.reclassifyButton.frame)")
        
        view.layoutIfNeeded()

    }
    
    private func makeCategoryTag(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.brown, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.pointOrange600.cgColor
        button.layer.cornerRadius = 5
        //        button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 14, bottom: 3, right: 14) // ✅ 내부 여백 추가
        // ✅ iOS 15 이상에서 contentInsets 적용
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 14, bottom: 3, trailing: 14)
            config.baseBackgroundColor = .clear // 기본 배경 제거
            button.configuration = config
        } else {
            // iOS 14 이하에서는 기존 방식 유지
            button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 14, bottom: 3, right: 14)
        }
        return button
    }
    
    private func makeSeparator() -> UILabel {
        let label = UILabel()
        label.text = ">"
        label.textColor = .mainBrown800
        label.font = UIFont.ptdSemiBoldFont(ofSize: 14)
        return label
    }
    //
    @objc private func handleReclassify() {
        print("📌 handleReclassify 실행됨") // ✅ 실행 여부 확인
        let addCategoryVC = AddCategoryViewController()
        navigationController?.pushViewController(addCategoryVC, animated: true)
    }
    
    //
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    //
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            addClothesView.inputButton.backgroundColor = .mainBrown800 // ✅ 텍스트 있으면 색 변경
            addClothesView.inputButton.setTitleColor(.white, for: .normal)
            addClothesView.inputButton.layer.borderColor = UIColor.mainBrown800.cgColor // ✅ 테두리 색도 변경
        } else {
            addClothesView.inputButton.backgroundColor = .clear // ✅ 텍스트 없으면 투명
            addClothesView.inputButton.layer.borderColor = UIColor.mainBrown400.cgColor // ✅ 기본 테두리 색 유지
            addClothesView.inputButton.setTitleColor(UIColor.black, for: .normal) // ✅ 기본 글 색 유지
        }
    }
    
}


