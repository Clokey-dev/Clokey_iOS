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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // 🔹 이전 화면에서 다시 돌아올 때 초기화
        resetViewState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc internal override func dismissKeyboard() {
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
        weatherVC.categoryName = cate1
        weatherVC.categoryCloth = cate3
        weatherVC.categoryId = cate3Id
        if let navController = self.navigationController {
            navController.pushViewController(weatherVC, animated: true)
        } else {
            weatherVC.modalPresentationStyle = .fullScreen
            self.present(weatherVC, animated: true, completion: nil)
        }
    }
    
    var cate1: String?
    var cate3: String?
    var cate3Id: Int64?
    //
    // MARK: - Action Handlers
    @objc private func handleInput() {
        guard let text = addClothesView.inputField.text, !text.isEmpty else {
            print("❌ 입력 필드가 비어 있음")
            return
        }
        
//        // 🔹 입력된 텍스트에서 옷 이름 찾기
//            let possibleNames = AddCategoryModel.allCategories.flatMap { $0.buttons.map { $0.name } }
//            guard let extractedKeyword = possibleNames.first(where: { text.contains($0) }) else {
//                print("❌ 옷 종류를 추출할 수 없음")
//                return
//            }
        // 🔹 수정된 함수 사용
            guard let extractedKeyword = extractClothingKeyword(from: text) else {
                print("❌ 옷 종류를 추출할 수 없음")
                return
            }

            print("📌 추출된 옷 이름: \(extractedKeyword)")

            // 🔹 AddCategoryModel에서 카테고리 찾기
//            guard let (category1Name, category3Name) = AddCategoryModel.getCategoryByName(extractedKeyword) else {
//                print("❌ 해당하는 카테고리를 찾을 수 없음")
//                return
//            }
        guard let (category1Name, category3Name, category3Id) = AddCategoryModel.getCategoryByName(extractedKeyword) else {
            print("❌ 해당하는 카테고리를 찾을 수 없음")
            return
        }

        
        addClothesView.categoryTagsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 🔹 카테고리 태그 생성
            let category1 = makeCategoryTag(title: category1Name)
            let separator = makeSeparator()
            let category3 = makeCategoryTag(title: category3Name)
        
        cate1 = category1Name
        cate3 = category3Name
        cate3Id = category3Id
        
        
        addClothesView.categoryTagsContainer.addArrangedSubview(category1)
        addClothesView.categoryTagsContainer.addArrangedSubview(separator)
        addClothesView.categoryTagsContainer.addArrangedSubview(category3)
        
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
    
    private func extractClothingKeyword(from text: String) -> String? {
        let possibleNames = AddCategoryModel.allCategories.flatMap { $0.buttons.map { $0.name } }

        // 🔹 '/'로 구분된 단어를 개별적으로 검사
        for name in possibleNames {
            let keywords = name.lowercased().split(separator: "/") // ex) ["니트", "스웨터"]
            if keywords.contains(where: { text.lowercased().contains($0) }) {
                return name // 🔹 "니트/스웨터" 반환
            }
        }
        return nil
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
        // 입력 필드 값 가져오기
        guard let clothName = addClothesView.inputField.text, !clothName.isEmpty else {
            print("❌ 텍스트 필드가 비어 있습니다.")
            return
        }
        
        let addCategoryVC = AddCategoryViewController()
        addCategoryVC.clothName = clothName // 값 전달
        navigationController?.pushViewController(addCategoryVC, animated: true)
    }
    
    //
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
        resetViewState() // ✅ 화면을 초기 상태로 되돌리는 함수 호출
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
    
    private func resetViewState() {
        // 🔹 입력 필드 초기화
        addClothesView.inputField.text = ""

        // 🔹 카테고리 태그 초기화
        addClothesView.categoryTagsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 🔹 UI 요소들 초기화
        addClothesView.categoryContainer.isHidden = true

        // 🔹 nextButton 초기화
        addClothesView.nextButton.isEnabled = false
        addClothesView.nextButton.backgroundColor = .mainBrown400

        // 🔹 reclassifyButton 초기화
        addClothesView.reclassifyButton.isUserInteractionEnabled = false
        addClothesView.reclassifyButton.isHidden = true
        addClothesView.reclassifyButton.alpha = 0.0

        // ✅ 필요하면 추가적인 초기화 코드 작성 가능
    }
    
}


