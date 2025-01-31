import UIKit
import SnapKit

class CategorySelectionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "카테고리 직접 선택" // ✅ 네비게이션 바에 타이틀 추가

        let label = UILabel()
        label.text = "카테고리 직접 선택하는 화면"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // ✅ 닫기 버튼 추가 (네비게이션 컨트롤러가 없을 경우 dismiss)
        if navigationController == nil {
            let closeButton = UIButton(type: .system)
            closeButton.setTitle("닫기", for: .normal)
            closeButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)

            view.addSubview(closeButton)
            closeButton.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
                make.trailing.equalToSuperview().offset(-20)
            }
        }
    }
    
    @objc public func dismissModal() {
            dismiss(animated: true, completion: nil)
    }
}
