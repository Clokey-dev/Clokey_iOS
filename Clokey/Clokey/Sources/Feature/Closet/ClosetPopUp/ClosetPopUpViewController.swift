import UIKit
import SnapKit
import Kingfisher

final class PopUpViewController: UIViewController {
    
    // MARK: - Properties
    /// API 호출 시 사용할 옷 아이템의 ID (checkPopUpClothes API 사용)
    var clothId: Int64? {
        didSet {
            // clothId가 변경될 때마다 API 호출
            fetchPopUpClothesDetail()
        }
    }
    
    /// 전체 옷 모델 배열 (clothPreviews)
    var clothPreviews: [ClothPreview] = []
    /// 현재 선택된 아이템 인덱스
    var currentIndex: Int = 0
    
    // clothesService의 접근 수준은 PopUpDropdownViewController에서 접근 가능하도록 internal(let)로 선언
    let clothesService = ClothesService()
    
    /// 현재 버튼에 할당된 옷 URL (유효한 경우)
    private var currentClothUrl: String?
    
    // MARK: - UI Components
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()
    
    private let popupView: ClosetPopupView = {
        let view = ClosetPopupView()
        view.alpha = 0
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Popup view did appear, currentIndex: \(currentIndex)")
        updateArrowButtonStates()
        UIView.animate(withDuration: 0.3) {
            self.dimmingView.alpha = 1
            self.popupView.alpha = 1
        }
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        view.backgroundColor = .clear
        
        view.addSubview(dimmingView)
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(popupView)
        popupView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(290)
            make.height.equalTo(448)
        }
    }
    
    private func setupActions() {
        popupView.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        popupView.optionButton.addTarget(self, action: #selector(optionButtonTapped), for: .touchUpInside)
        popupView.leftArrowButton.addTarget(self, action: #selector(leftArrowButtonTapped), for: .touchUpInside)
        popupView.rightArrowButton.addTarget(self, action: #selector(rightArrowButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismissPopup()
    }
    
    @objc private func optionButtonTapped() {
        let dropdownVC = PopUpDropdownViewController()
        dropdownVC.modalPresentationStyle = .overCurrentContext
        dropdownVC.modalTransitionStyle = .crossDissolve
        self.present(dropdownVC, animated: true, completion: nil)
    }
    
    @objc private func leftArrowButtonTapped() {
        if currentIndex > 0 {
            currentIndex -= 1
            clothId = Int64(clothPreviews[currentIndex].id)
            print("Left arrow tapped: currentIndex = \(currentIndex), clothId = \(clothId!)")
            // API 재호출로 팝업 업데이트
            fetchPopUpClothesDetail()
        } else {
            print("첫 번째 항목입니다.")
        }
        updateArrowButtonStates()
    }
    
    @objc private func rightArrowButtonTapped() {
        if currentIndex < clothPreviews.count - 1 {
            currentIndex += 1
            clothId = Int64(clothPreviews[currentIndex].id)
            print("Right arrow tapped: currentIndex = \(currentIndex), clothId = \(clothId!)")
            // API 재호출로 팝업 업데이트
            fetchPopUpClothesDetail()
        } else {
            print("마지막 항목입니다.")
        }
        updateArrowButtonStates()
    }
    
    private func updateArrowButtonStates() {
        // 왼쪽 화살표 업데이트: currentIndex가 0이면 비활성화, 아니면 활성화
        if currentIndex == 0 {
            popupView.leftArrowButton.isUserInteractionEnabled = false
            popupView.leftArrowButton.tintColor = UIColor(named: "mainBrown50")
        } else {
            popupView.leftArrowButton.isUserInteractionEnabled = true
            popupView.leftArrowButton.tintColor = UIColor(named: "mainBrown800")
        }
        
        // 오른쪽 화살표 업데이트: currentIndex가 마지막이면 비활성화, 아니면 활성화
        if currentIndex == clothPreviews.count - 1 {
            popupView.rightArrowButton.isUserInteractionEnabled = false
            popupView.rightArrowButton.tintColor = UIColor(named: "mainBrown600")
        } else {
            popupView.rightArrowButton.isUserInteractionEnabled = true
            popupView.rightArrowButton.tintColor = UIColor(named: "mainBrown800")
        }
    }

    
    private func dismissPopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.dimmingView.alpha = 0
            self.popupView.alpha = 0
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - API 연동: 옷 상세 정보 조회
    private func fetchPopUpClothesDetail() {
        print("Fetching popup clothes detail, currentIndex: \(currentIndex)")
        guard let clothId = clothId else {
            print("clothId가 설정되지 않았습니다.")
            return
        }
        clothesService.checkPopUpClothes(clothId: clothId) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.configurePopupView(with: response)
                }
            case .failure(let error):
                print("팝업 상세 정보를 가져오는데 실패했습니다: \(error)")
            }
        }
    }
    
    private func configurePopupView(with detail: checkPopUpClothesResponseDTO) {
        // 이름
        popupView.nameLabel.text = detail.name
        
        // Visibility: PUBLIC이면 lock_on, 그 외에는 lock_off 이미지
        if detail.visibility == "PUBLIC" {
            popupView.publicButton.setImage(UIImage(named: "lock_off"), for: .normal)
        } else {
            popupView.publicButton.setImage(UIImage(named: "lock_on"), for: .normal)
        }
        
        // 이미지
        if let url = URL(string: detail.imageUrl) {
            popupView.imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"))
        } else {
            popupView.imageView.image = UIImage(named: "placeholderImage")
        }
        
        // 계절 버튼 업데이트
        if detail.seasons.contains("SPRING") {
            popupView.springButton.backgroundColor = UIColor(named: "mainBrown600")
            popupView.springButton.setTitleColor(.white, for: .normal)
            popupView.springButton.layer.borderWidth = 0
        } else {
            popupView.springButton.backgroundColor = UIColor(named: "mainBrown50")
            popupView.springButton.setTitleColor(.black, for: .normal)
            popupView.springButton.layer.borderWidth = 1
            popupView.springButton.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
        }
        
        if detail.seasons.contains("SUMMER") {
            popupView.summerButton.backgroundColor = UIColor(named: "mainBrown600")
            popupView.summerButton.setTitleColor(.white, for: .normal)
            popupView.summerButton.layer.borderWidth = 0
        } else {
            popupView.summerButton.backgroundColor = UIColor(named: "mainBrown50")
            popupView.summerButton.setTitleColor(.black, for: .normal)
            popupView.summerButton.layer.borderWidth = 1
            popupView.summerButton.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
        }
        
        if detail.seasons.contains("FALL") {
            popupView.fallButton.backgroundColor = UIColor(named: "mainBrown600")
            popupView.fallButton.setTitleColor(.white, for: .normal)
            popupView.fallButton.layer.borderWidth = 0
        } else {
            popupView.fallButton.backgroundColor = UIColor(named: "mainBrown50")
            popupView.fallButton.setTitleColor(.black, for: .normal)
            popupView.fallButton.layer.borderWidth = 1
            popupView.fallButton.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
        }
        
        if detail.seasons.contains("WINTER") {
            popupView.winterButton.backgroundColor = UIColor(named: "mainBrown600")
            popupView.winterButton.setTitleColor(.white, for: .normal)
            popupView.winterButton.layer.borderWidth = 0
        } else {
            popupView.winterButton.backgroundColor = UIColor(named: "mainBrown50")
            popupView.winterButton.setTitleColor(.black, for: .normal)
            popupView.winterButton.layer.borderWidth = 1
            popupView.winterButton.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
        }
        
        // WearNum
        popupView.wearCountButton.setTitle("\(detail.wearNum)회", for: .normal)
        
        // Brand
        popupView.brandNameLabel.text = (detail.brand?.isEmpty ?? true) ? "설정하지 않음" : detail.brand
        
        // clothUrl 처리: detail.clothUrl이 nil 또는 빈 값이면 "설정하지 않음", 유효한 URL이면 "바로가기"로 표시 후 클릭 시 해당 URL로 이동
        if let urlString = detail.clothUrl, !urlString.isEmpty, let _ = URL(string: urlString) {
            let title = "바로가기"
            let attributes: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.mainBrown800,
                .font: UIFont.ptdRegularFont(ofSize: 16)
            ]
            popupView.urlGoButton.setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .normal)
            currentClothUrl = urlString
            popupView.urlGoButton.removeTarget(nil, action: nil, for: .allEvents)
            popupView.urlGoButton.addTarget(self, action: #selector(openUrl(_:)), for: .touchUpInside)
        } else {
            let title = "설정하지 않음"
            let attributes: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.mainBrown800,
                .font: UIFont.ptdRegularFont(ofSize: 16)
            ]
            popupView.urlGoButton.setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .normal)
            currentClothUrl = nil
            popupView.urlGoButton.removeTarget(nil, action: nil, for: .allEvents)
        }
        
        // Category
        popupView.categoryButton2.setTitle(detail.category, for: .normal)
        
        if let categoryName = CategoryModel.getCategoryNameByClothName(detail.category) {
            print(categoryName) // 출력: "상의"
            popupView.categoryButton1.setTitle("\(categoryName)", for: .normal)
        }
    }
    
    // MARK: - URL 열기 액션
    @objc private func openUrl(_ sender: UIButton) {
        guard let urlString = currentClothUrl, let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
