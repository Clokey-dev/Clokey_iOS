import UIKit
import SnapKit

// MARK: - FolderDropDownViewController
class FolderDropDownViewController: UIViewController, FolderDropdownViewDelegate, UIGestureRecognizerDelegate {
    
    private let folderDropdownView = FolderDropdownView()
    
    var parentNav: UINavigationController?
    
    /// 현재 편집 또는 삭제할 폴더의 ID (서버에서 생성된 실제 폴더 ID)
    var folderId: Int64?
    
    /// DrawerViewController에서 계산한 상단 오프셋 (예: 네비게이션바 하단 + 5)
    var dropdownTop: CGFloat = 0
    
    // API 서비스 (FolderService)
    private let folderService = FolderService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 배경을 투명하게 설정
        view.backgroundColor = .clear
        
        // 드롭다운 외의 영역을 탭했을 때 dismiss하도록 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(folderDropdownView)
        folderDropdownView.delegate = self
        
        folderDropdownView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(dropdownTop)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(143)
            make.height.equalTo(75)
        }
    }
    
    /// 배경을 탭했을 때 호출되어 드롭다운 모달을 닫습니다.
    @objc private func handleBackgroundTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    /// 드롭다운 뷰 내에서의 터치는 제스처 인식에서 제외시킵니다.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if folderDropdownView.frame.contains(touch.location(in: view)) {
            return false
        }
        return true
    }
    
    // MARK: - FolderDropdownViewDelegate 구현
    
    // 1) 폴더 편집
    func didSelectEditFolder() {
        guard let nav = parentNav else {
            print("❌ 네비게이션 컨트롤러를 찾을 수 없습니다.")
            return
        }
        guard let folderId = self.folderId, folderId != 0 else {
            print("❌ 폴더 수정에 필요한 folderId가 없습니다.")
            return
        }
        
        // 모달 닫고, 편집 화면으로 이동 (예시: DrawerEditViewController)
        dismiss(animated: false) {
            let drawerEditVC = DrawerEditViewController(folderId: folderId)
            nav.pushViewController(drawerEditVC, animated: true)
        }
    }
    
    // 2) 폴더 삭제
        func didSelectDeleteFolder() {
            guard let folderId = self.folderId, folderId != 0 else {
                print("❌ 폴더 삭제에 필요한 folderId가 없습니다.")
                return
            }
            
            folderService.folderDelete(folderId: Int(folderId)) { [weak self] result in
                DispatchQueue.main.async {
                    self?.dismiss(animated: false) {
                        // presentingViewController 대신, 미리 설정한 parentNav를 사용합니다.
                        if let nav = self?.parentNav {
                            if let tabBarController = nav.tabBarController {
                                tabBarController.selectedIndex = 3  // ClosetViewController가 있는 탭 인덱스
                                if let closetNav = tabBarController.viewControllers?[0] as? UINavigationController {
                                    closetNav.popToRootViewController(animated: true)
                                }
                            } else {
                                nav.popToRootViewController(animated: true)
                            }
                        } else {
                            print("❌ parentNav가 nil입니다.")
                        }
                    }
                }
            }
        }



    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(title: "오류", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

