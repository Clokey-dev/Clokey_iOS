//
//  MainViewController.swift
//  Clokey
//
//  Created by 황상환 on 12/31/24.
//

import UIKit
import SnapKit
import Then

final class MainViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: MainViewModel
    private let mainView = MainView()
    
    // 각 탭의 뷰컨트롤러
    private lazy var homeVC = HomeViewController()
    private lazy var calendarVC = CalendarViewController()
    private lazy var addClothVC = AddClothViewController()
    private lazy var closetVC = ClosetViewController()
    private lazy var profileVC = ProfileViewController()
        
    
    // MARK: - Init
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        showViewController(homeVC) // 초기 화면으로 홈 표시
    }
    
    // MARK: - Setup
    private func setupTabBar() {
        mainView.tabBar.delegate = self
    }
   
        
    private func showViewController(_ viewController: UIViewController) {
        if viewController is AddClothViewController {
            print("✅ '옷 추가' 화면으로 이동 시도")
            
            if let navController = navigationController {
                print("✅ 네비게이션 컨트롤러 확인됨! 화면 이동 실행")
                navController.pushViewController(viewController, animated: true)
            } else if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                      let rootNav = sceneDelegate.window?.rootViewController as? UINavigationController {
                print("🚀 SceneDelegate에서 네비게이션 컨트롤러 가져옴")
                rootNav.pushViewController(viewController, animated: true)
            } else {
                print("🚨 네비게이션 컨트롤러 없음! SceneDelegate에서 강제 재설정 필요")
            }
            return
        }

        // ✅ 기존 뷰 제거 후 새 뷰 추가
        children.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        
        addChild(viewController)
        mainView.contentView.addSubview(viewController.view)
        viewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        viewController.didMove(toParent: self)
    }
       
    

    /// ✅ 네비게이션 스택을 출력하는 함수
    private func printNavigationStack() {
        if let navController = navigationController {
            print("📌 현재 네비게이션 스택: \(navController.viewControllers)")
        } else {
            print("❌ 네비게이션 컨트롤러가 없음!")
        }
    }
}

// MARK: - UITabBarDelegate
// 탭바의 동작을 처리
extension MainViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            showViewController(homeVC)
        case 1:
            showViewController(calendarVC)
        case 2:
            print("✅ '옷 추가' 화면으로 이동 시도")
                        let addClothVC = AddClothViewController()
                        
                        if let navController = navigationController {
                            print("✅ 네비게이션 컨트롤러 확인됨! 화면 이동 실행")
                            navController.pushViewController(addClothVC, animated: true)
                            print("🛠 현재 네비게이션 스택: \(navController.viewControllers)")
                        } else if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                                  let rootNav = sceneDelegate.window?.rootViewController as? UINavigationController {
                            print("🚀 SceneDelegate에서 네비게이션 컨트롤러 가져옴")
                            rootNav.pushViewController(addClothVC, animated: true)
                            print("🛠 SceneDelegate 사용 후 네비게이션 스택: \(rootNav.viewControllers)")
                        } else {
                            print("🚨 네비게이션 컨트롤러 없음! `SceneDelegate`에서 설정했는지 확인 필요")
                        }
        case 3:
            showViewController(closetVC)
        case 4:
            showViewController(profileVC)
        default:
            break
        }
    }
}
