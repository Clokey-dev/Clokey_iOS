import UIKit
import SnapKit

class PopUpDropdownViewController: UIViewController, PopUpDropdownViewDelegate, UIGestureRecognizerDelegate {
    
    private let popUpDropdownView = PopUpDropdownView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 배경을 투명하게 설정
        view.backgroundColor = .clear
        
        // 드롭다운 외의 영역을 탭했을 때 dismiss하도록 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(popUpDropdownView)
        popUpDropdownView.delegate = self
        
        popUpDropdownView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(300)
            make.trailing.equalToSuperview().inset(75)
            make.width.equalTo(92)
            make.height.equalTo(64)
        }
    }
    
    /// 배경을 탭했을 때 호출되어 드롭다운 모달을 닫습니다.
    @objc private func handleBackgroundTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    /// 드롭다운 뷰 내에서의 터치는 제스처 인식에서 제외시킵니다.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if popUpDropdownView.frame.contains(touch.location(in: view)) {
            return false
        }
        return true
    }
    
    // MARK: - PopUpDropdownViewDelegate 구현
    func didSelectEditCloth() {
        // 수정 동작 구현 (필요 시)
    }

    func didSelectDeleteCloth() {
        // presentingViewController가 PopUpViewController인지 확인
        guard let popUpVC = presentingViewController as? PopUpViewController,
              let clothId = popUpVC.clothId else {
            return
        }
        
        // deleteClothes API 호출 (ClothService의 deleteClothes는 Int 타입의 cloth_id를 받음)
        popUpVC.clothesService.deleteClothes(cloth_id: Int(clothId)) { [weak self] result in
            switch result {
            case .success(let success):
                if success {
                    DispatchQueue.main.async {
                        // 먼저 드롭다운을 닫고, 그 후 팝업도 닫음
                        self?.dismiss(animated: true) {
                            popUpVC.dismiss(animated: true, completion: nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        print("옷 삭제 실패: 삭제 결과가 false")
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("옷 삭제 실패: \(error)")
                    // 필요 시 Alert 등으로 사용자에게 알림
                }
            }
        }
    }
}
