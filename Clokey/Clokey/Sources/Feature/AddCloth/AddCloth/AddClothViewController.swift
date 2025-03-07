import UIKit
import SnapKit

struct EditClothModel {
    var id: Int64
    var name: String
    var seasons: [String]
    var tempUpperBound: Int
    var tempLowerBound: Int
    var thicknessLevel: String
    var visibility: String
    var clothUrl: String?
    var brand: String?
    var imageUrl: String
    var categoryId: Int64
}

class AddClothViewController: UIViewController, UITextFieldDelegate /*UIGestureRecognizerDelegate*/ {
    private let navBarManager = NavigationBarManager()
    private let addClothesView = AddClothesView()
    
    var editClothModel: EditClothModel?
    
    var clothId: Int64 = 0 {
        didSet {
            isEditingMode = (clothId != 0) // clothId가 0이면 추가, 0이 아니면 수정 모드
        }
    }
    var isEditingMode: Bool = false
    
    
    override func loadView() {
        view = addClothesView
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        addClothesView.inputField.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        setupAction()
        
        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints {
                    $0.center.equalToSuperview()
                }
        
        //  화면 탭하면 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
       
        loadEditCloth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //  이전 화면에서 다시 돌아올 때 초기화
        resetViewState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc internal override func dismissKeyboard() {
        view.endEditing(true) //  현재 화면에서 키보드 내리기
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
//        navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name("HideLoadingOverlayNotification"), object: nil)
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.switchToMain()
        }
        resetViewState() // 화면을 초기 상태로 되돌리는 함수 호출
    }
   
    private func setupAction() {
        addClothesView.inputField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged) // 텍스트 변경 감지
        addClothesView.inputButton.addTarget(self, action: #selector(handleInput), for: .touchUpInside)
        addClothesView.reclassifyButton.addTarget(self, action: #selector(handleReclassify), for: .touchUpInside)
        addClothesView.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        
    }
    
    //
    @objc private func didTapNextButton() {
        // 입력 필드 값 가져오기
        guard let clothName = addClothesView.inputField.text, !clothName.isEmpty else {
            print(" 텍스트 필드가 비어 있습니다.")
            return
        }
        
        if isEditingMode {
            // WeatherClothesViewController로 이동
            let weatherVC = WeatherChooseViewController()
            weatherVC.clothId = clothId
            weatherVC.editSeasons = editClothModel?.seasons
            weatherVC.editTempUpperBound = editClothModel?.tempUpperBound
            weatherVC.editTempLowerBound = editClothModel?.tempLowerBound
            weatherVC.editThicknessLevel = editClothModel?.thicknessLevel
            weatherVC.editVisibility = editClothModel?.visibility
            weatherVC.editClothUrl = editClothModel?.clothUrl
            weatherVC.editBrand = editClothModel?.brand
            weatherVC.editImageUrl = editClothModel?.imageUrl
            
            weatherVC.clothName = clothName // 값 전달
            weatherVC.categoryName = cate1
            weatherVC.categoryCloth = cate3
            weatherVC.categoryId = cate3Id
            self.navigationController?.pushViewController(weatherVC, animated: true)
        } else {
            // WeatherClothesViewController로 이동
            let weatherVC = WeatherChooseViewController()
            weatherVC.clothName = clothName // 값 전달
            weatherVC.categoryName = cate1
            weatherVC.categoryCloth = cate3
            weatherVC.categoryId = cate3Id
            self.navigationController?.pushViewController(weatherVC, animated: true)
        }
    }
    
    var cate1: String?
    var cate3: String?
    var cate3Id: Int64?
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.color = UIColor(named: "pointOrange800")
        $0.hidesWhenStopped = true
        $0.backgroundColor = .clear
    }
    //
    // MARK: - Action Handlers
    
    @objc private func handleInput() {
        guard let text = addClothesView.inputField.text, !text.isEmpty else {
            print(" 입력 필드가 비어 있음")
            return
        }
        
        // 로딩 시작 (UI 스레드에서 실행)
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
        
        let categoriesService = CategoriesService()
        
        categoriesService.getRecommendCategory(name: text) { [weak self] result in
            //            DispatchQueue.main.async {
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating() // 로딩 완료되면 중지
            }
            
            switch result {
            case .success(let response):
                let category1Name = response.largeCategoryName
                let category3Name = response.smallCategoryName
                let category3Id = response.categoryId
                
                // 카테고리 응답이 비어있을 경우 로그 출력
                if category1Name.isEmpty || category3Name.isEmpty {
                    print("추천 카테고리 없음")
                } else {
                    //  UI 업데이트
                    self.updateCategoryTags(category1Name: category1Name, category3Name: category3Name, category3Id: category3Id)
                    view.endEditing(true)
                    
                }
                
            case .failure(let error):
                print("카테고리 추천 데이터 로드 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateCategoryTags(category1Name: String, category3Name: String, category3Id: Int64) {
        //  기존 태그 제거
        addClothesView.categoryTagsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        
        // 새로운 카테고리 태그 생성
        let category1 = makeCategoryTag(title: category1Name)
        let separator = makeSeparator()
        let category3 = makeCategoryTag(title: category3Name)
        
        cate1 = category1Name
        cate3 = category3Name
        cate3Id = category3Id
        
        //  UI 업데이트
        addClothesView.categoryTagsContainer.addArrangedSubview(category1)
        addClothesView.categoryTagsContainer.addArrangedSubview(separator)
        addClothesView.categoryTagsContainer.addArrangedSubview(category3)
        
        addClothesView.categoryContainer.isHidden = false
        
        //  버튼 활성화
        addClothesView.nextButton.isEnabled = true
        addClothesView.nextButton.backgroundColor = .mainBrown800
        
        addClothesView.reclassifyButton.isUserInteractionEnabled = true
        addClothesView.reclassifyButton.isHidden = false
        addClothesView.reclassifyButton.alpha = 1.0
        
        print("카테고리 태그 업데이트 완료")
    }
    
    private func makeCategoryTag(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 16)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.pointOrange800.cgColor
        button.layer.cornerRadius = 5
        //        button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 14, bottom: 3, right: 14) //  내부 여백 추가
        //  iOS 15 이상에서 contentInsets 적용
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
    

    private func makeSeparator() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right") // SF Symbol 설정
        imageView.tintColor = .mainBrown800 // 색상 적용
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    //
    @objc private func handleReclassify() {
        // 입력 필드 값 가져오기
        guard let clothName = addClothesView.inputField.text, !clothName.isEmpty else {
            print("텍스트 필드가 비어 있습니다.")
            return
        }
        
        let categoryVC = CategoryViewController()
        
        if isEditingMode {
            categoryVC.clothId = clothId
            categoryVC.editSeasons = editClothModel?.seasons
            categoryVC.editTempUpperBound = editClothModel?.tempUpperBound
            categoryVC.editTempLowerBound = editClothModel?.tempLowerBound
            categoryVC.editThicknessLevel = editClothModel?.thicknessLevel
            categoryVC.editVisibility = editClothModel?.visibility
            categoryVC.editClothUrl = editClothModel?.clothUrl
            categoryVC.editBrand = editClothModel?.brand
            categoryVC.editImageUrl = editClothModel?.imageUrl
            
            categoryVC.clothName = clothName // 값 전달
            
            self.navigationController?.pushViewController(categoryVC, animated: true)
        } else {
            categoryVC.clothName = clothName // 값 전달
            self.navigationController?.pushViewController(categoryVC, animated: true)
        }
    }
    

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            addClothesView.inputButton.backgroundColor = .mainBrown800 //  텍스트 있으면 색 변경
            addClothesView.inputButton.setTitleColor(.white, for: .normal)
            addClothesView.inputButton.layer.borderColor = UIColor.mainBrown800.cgColor //  테두리 색도 변경
        } else {
            addClothesView.inputButton.backgroundColor = .clear //  텍스트 없으면 투명
            addClothesView.inputButton.layer.borderColor = UIColor.mainBrown400.cgColor //  기본 테두리 색 유지
            addClothesView.inputButton.setTitleColor(UIColor.black, for: .normal) //  기본 글 색 유지
            resetViewState()
        }
    }
    
    private func resetViewState() {
        //  입력 필드 초기화
        addClothesView.inputField.text = ""

        //  카테고리 태그 초기화
        addClothesView.categoryTagsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

        //  UI 요소들 초기화
        addClothesView.categoryContainer.isHidden = true

        // nextButton 초기화
        addClothesView.nextButton.isEnabled = false
        addClothesView.nextButton.backgroundColor = .mainBrown400

        //  reclassifyButton 초기화
        addClothesView.reclassifyButton.isUserInteractionEnabled = false
        addClothesView.reclassifyButton.isHidden = true
        addClothesView.reclassifyButton.alpha = 0.0

    }
    
    
    private func loadEditCloth() {
        let clothesService = ClothesService()
        
        clothesService.checkEditClothes(clothId: clothId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.editClothModel = EditClothModel(
                    id: response.id,
                    name: response.name,
                    seasons: response.seasons,
                    tempUpperBound: response.tempUpperBound,
                    tempLowerBound: response.tempLowerBound,
                    thicknessLevel: response.thicknessLevel,
                    visibility: response.visibility,
                    clothUrl: response.clothUrl,
                    brand: response.brand,
                    imageUrl: response.imageUrl,
                    categoryId: response.categoryId)
                
                DispatchQueue.main.async {
                    self.addClothesView.inputField.text = response.name
                }
            case .failure(let error):
                print("옷 정보 로드 실패: \(error.localizedDescription)")
            }
        }
    }
}

extension AddClothViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer {
            didTapBackButton()
            return false  // 기본 pop 동작 차단
        }
        return true
    }
}



