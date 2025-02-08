//
//  MainViewController.swift
//  Clokey
//
//  Created by 황상환 on 12/31/24.
//

import UIKit
import SnapKit
import Then

// MainView, Header,TabBar 이벤트 처리 델리게이트도 수행
final class MainViewController: UIViewController {
    
    // MARK: - Properties
    private let mainView = MainView()
    
    private lazy var homeVC = HomeViewController()
    private lazy var calendarVC = CalendarViewController()
    private lazy var addClothVC = AddClothViewController()
    private lazy var closetVC = ClosetViewController()
    private lazy var profileVC = ProfileViewController()
    
    // MARK: - Lifecycle
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        showViewController(homeVC)
    }
    
    // MARK: - Setup
    // HeaderView와 TabBarView의 이벤트 처리 델리게이트 설정
    private func setupDelegates() {
        mainView.headerView.delegate = self
        mainView.tabBarView.delegate = self
    }

   
        
    private func showViewController(_ viewController: UIViewController) {
         if viewController is AddClothViewController {
            pushAddClothViewController(viewController)
            return
        }

        // ✅ 기존 뷰 제거 후 새 뷰 추가

        children.forEach {
            // 제거
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        

        // 생성
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

// MARK: - HeaderViewDelegate
// 헤더뷰에 있던 버튼 이벤트 처리
extension MainViewController: HeaderViewDelegate {
    func didTapSearchButton() {
        // 검색 버튼 탭 처리
    }
    
    func didTapNotificationButton() {
        // 알림 버튼 탭 처리
    }
}

// MARK: - TabBarViewDelegate
extension MainViewController: TabBarViewDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            showViewController(homeVC)
            mainView.setHeaderViewHidden(false)
        case 1:
            showViewController(calendarVC)
            mainView.setHeaderViewHidden(false)
        case 2:

            showViewController(addClothVC)
            mainView.setHeaderViewHidden(false)

        case 3:
            showViewController(closetVC)
            mainView.setHeaderViewHidden(false)
        case 4:
            showViewController(profileVC)
            mainView.setHeaderViewHidden(true)
        default:
            break
        }
    }
}
