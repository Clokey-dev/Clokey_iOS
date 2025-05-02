import UIKit
import SnapKit
import Kingfisher

final class PopUpViewController: UIViewController, PopUpDropdownViewDelegate {
    // MARK: - Properties
    var clothId: Int64? {
        didSet { fetchPopUpClothesDetail() }
    }
    var clokeyId: String = ""
    var clothPreviews: [ClothPreview] = []
    var currentIndex: Int = 0
    let clothesService = ClothesService()
    private var currentClothUrl: String?
    private var dropdownView: PopUpDropdownView?

    // MARK: - UI Components
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.alpha = 0
        return view
    }()

    let popupView: ClosetPopupView = {
        let view = ClosetPopupView()
        view.alpha = 0
        return view
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        popupView.optionButton.isHidden = !clokeyId.isEmpty
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateArrowButtonStates()
        UIView.animate(withDuration: 0.3) {
            self.dimmingView.alpha = 1
            self.popupView.alpha = 1
        }
    }

    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .clear
        view.addSubview(dimmingView)
        dimmingView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
        dimmingView.addGestureRecognizer(tap)

        view.addSubview(popupView)
        popupView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(290)
            make.height.equalTo(489)
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
        if let dropdown = dropdownView {
            dropdown.removeFromSuperview()
            dropdownView = nil
        } else {
            let dropdown = PopUpDropdownView()
            dropdown.delegate = self
            popupView.addSubview(dropdown)
            dropdown.snp.makeConstraints { make in
                make.top.equalTo(popupView.optionButton.snp.bottom).offset(8)
                make.trailing.equalTo(popupView.optionButton.snp.trailing)
                make.width.equalTo(92)
                make.height.equalTo(64)
            }
            dropdownView = dropdown
        }
    }

    @objc private func leftArrowButtonTapped() {
        if currentIndex > 0 {
            currentIndex -= 1
            clothId = Int64(clothPreviews[currentIndex].id)
        }
        updateArrowButtonStates()
    }

    @objc private func rightArrowButtonTapped() {
        if currentIndex < clothPreviews.count - 1 {
            currentIndex += 1
            clothId = Int64(clothPreviews[currentIndex].id)
        }
        updateArrowButtonStates()
    }

    @objc private func dimmingViewTapped() {
        dismissPopup()
    }

    private func dismissPopup() {
        UIView.animate(withDuration: 0.3) {
            self.dimmingView.alpha = 0
            self.popupView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - PopUpDropdownViewDelegate
    func didSelectEditCloth() {
        guard let id = clothId else { return }
        
        // 1) presentingViewController가 UINavigationController라면 그 안의 topViewController를 사용
        let rawPresenter = presentingViewController
        let presenter: UIViewController = {
            if let nav = rawPresenter as? UINavigationController {
                return nav.topViewController ?? nav
            }
            return rawPresenter!
        }()
        
        // 2) 진짜 호출한 VC가 DisplayAll인지 검사
        let name = (presenter is DisplayAllViewController)
            ? "clothEditFromDisplayAll"
            : "clothEditFromCloset"
        
        // 드롭다운 닫기
        dropdownView?.removeFromSuperview()
        dropdownView = nil
        
        // 3) 팝업 닫고(애니=false), 완료 콜백에서 알림 전송
        dismiss(animated: false) {
            NotificationCenter.default.post(
                name: Notification.Name(name),
                object: nil,
                userInfo: ["clothId": id]
            )
        }
    }


    func didSelectDeleteCloth() {
        guard let id = clothId else { return }
        clothesService.deleteClothes(cloth_id: Int(id)) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.dropdownView?.removeFromSuperview()
                    self?.dismiss(animated: false) {
                        print("[PopUp] didSelectDeleteCloth → posting clothDeleted for id \(id)")
                        NotificationCenter.default.post(
                            name: .init("clothDeleted"),
                            object: nil,
                            userInfo: ["clothId": id]
                        )
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    self?.showAlert(title: "네트워크 오류",
                                    message: "인터넷 연결이 끊겼습니다.")
                }
            }
        }
    }



    // MARK: - API
    private func fetchPopUpClothesDetail() {
        guard let id = clothId else { return }
        clothesService.checkPopUpClothes(clothId: id) { [weak self] result in
            if case .success(let detail) = result {
                DispatchQueue.main.async { self?.configurePopupView(with: detail) }
            }
        }
    }

    private func configurePopupView(with detail: checkPopUpClothesResponseDTO) {
        popupView.nameLabel.text = detail.name
        if detail.visibility == "PUBLIC" {
            popupView.publicButton.setImage(UIImage(named: "public_icon"), for: .normal)
        } else {
            popupView.publicButton.setImage(UIImage(named: "private_icon"), for: .normal)
        }
        if let url = URL(string: detail.imageUrl) {
            popupView.imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"))
        } else {
            popupView.imageView.image = UIImage(named: "placeholderImage")
        }
        ["SPRING","SUMMER","FALL","WINTER"].forEach { season in
            let button: UIButton
            switch season {
            case "SPRING": button = popupView.springButton
            case "SUMMER": button = popupView.summerButton
            case "FALL": button = popupView.fallButton
            default: button = popupView.winterButton
            }
            if detail.seasons.contains(season) {
                button.backgroundColor = UIColor(named: "mainBrown800")
                button.setTitleColor(.white, for: .normal)
                button.layer.borderWidth = 0
            } else {
                button.backgroundColor = UIColor(red: 255/255, green: 254/255, blue: 252/255, alpha: 1)
                button.setTitleColor(.black, for: .normal)
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor(named: "mainBrown600")?.cgColor
            }
        }
        popupView.wearCountButton.setTitle("\(detail.wearNum)회", for: .normal)
        popupView.brandNameLabel.text = detail.brand?.isEmpty == false ? detail.brand : "없음"
        if let urlString = detail.clothUrl,
           let _ = URL(string: urlString), !urlString.trimmingCharacters(in: .whitespaces).isEmpty {
            let title = "바로가기"
            let attrs: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                       .foregroundColor: UIColor.mainBrown800,
                                                       .font: UIFont.ptdMediumFont(ofSize: 12)]
            popupView.urlGoButton.setAttributedTitle(NSAttributedString(string: title, attributes: attrs), for: .normal)
            currentClothUrl = urlString
            popupView.urlGoButton.addTarget(self, action: #selector(openUrl(_:)), for: .touchUpInside)
        } else {
            let title = "없음"
            let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mainBrown800,
                                                       .font: UIFont.ptdMediumFont(ofSize: 12)]
            popupView.urlGoButton.setAttributedTitle(NSAttributedString(string: title, attributes: attrs), for: .normal)
            popupView.urlGoButton.removeTarget(nil, action: nil, for: .allEvents)
        }
        popupView.categoryButton2.setTitle(detail.category, for: .normal)
        if let name = CategoryModel.getCategoryNameByClothName(detail.category) {
            popupView.categoryButton1.setTitle(name, for: .normal)
        }
    }

    @objc private func openUrl(_ sender: UIButton) {
        guard let urlString = currentClothUrl, let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    private func updateArrowButtonStates() {
        popupView.leftArrowButton.isUserInteractionEnabled = currentIndex > 0
        popupView.rightArrowButton.isUserInteractionEnabled = currentIndex < clothPreviews.count - 1
    }
}
