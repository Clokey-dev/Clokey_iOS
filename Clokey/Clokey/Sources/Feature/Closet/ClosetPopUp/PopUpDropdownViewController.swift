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
    
    // MARK: - FolderDropdownViewDelegate 구현
    
    func didSelectEditCloth() {
            }

    func didSelectDeleteCloth() {
        
    }

}
