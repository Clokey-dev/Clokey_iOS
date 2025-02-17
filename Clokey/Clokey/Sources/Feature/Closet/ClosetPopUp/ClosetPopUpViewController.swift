import UIKit
import SnapKit

final class PopUpViewController: UIViewController {
    
    // MARK: - UI Components
    
    // 전체 화면 어둡게 처리할 dimmingView
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    // 팝업 내용을 담은 커스텀 뷰 (TouchPopupView)
    private let popupView: ClosetPopupView = {
        let view = ClosetPopupView()
        // 필요한 경우 추가 설정 가능
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
        // 팝업과 배경 애니메이션 효과
        UIView.animate(withDuration: 0.3) {
            self.dimmingView.alpha = 1
            self.popupView.alpha = 1
        }
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        // 모달 배경은 투명하게 설정 (dimmingView가 전체를 덮음)
        view.backgroundColor = .clear
        
        // dimmingView 추가 및 제약조건 설정 (전체 화면)
        view.addSubview(dimmingView)
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // 초기 상태: dimmingView와 팝업 뷰는 보이지 않음
        dimmingView.alpha = 0
        
        // popupView 추가 및 제약조건 설정 (중앙, 고정 사이즈)
        view.addSubview(popupView)
        popupView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(290)
            make.height.equalTo(448)
        }
        popupView.alpha = 0
    }
    
    private func setupActions() {
        // popupView 내부에 있는 closeButton과 optionButton에 액션 등록
        popupView.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        popupView.optionButton.addTarget(self, action: #selector(optionButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismissPopup()
    }
    
    @objc private func optionButtonTapped() {
        let dropdownVC = PopUpDropdownViewController()
        dropdownVC.modalPresentationStyle = .overCurrentContext
        dropdownVC.modalTransitionStyle = .crossDissolve
        present(dropdownVC, animated: true, completion: nil)
    }
    
    private func dismissPopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.dimmingView.alpha = 0
            self.popupView.alpha = 0
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
}
