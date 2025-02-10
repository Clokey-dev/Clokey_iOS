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
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupDelegates()
        showViewController(homeVC)
    }
    
    // MARK: - Setup
    // HeaderView와 TabBarView의 이벤트 처리 델리게이트 설정
    private func setupDelegates() {
        mainView.headerView.delegate = self
        mainView.tabBarView.delegate = self
    }
    
    // MARK: - Methods
    // 다른 뷰 컨트롤러로 화면 전환
    private func showViewController(_ viewController: UIViewController) {
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
}

// MARK: - HeaderViewDelegate
// 헤더뷰에 있던 버튼 이벤트 처리
// MARK: - HeaderViewDelegate
// 헤더뷰에 있던 버튼 이벤트 처리
// MARK: - HeaderViewDelegate
// 헤더뷰에 있던 버튼 이벤트 처리
extension MainViewController: HeaderViewDelegate {
    func didTapSearchButton() {
        print("🔍 터치됨: 검색 버튼") // ✅ 디버깅 로그 추가
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true) // ✅ 검색 화면으로 푸시
    }

    func didTapNotificationButton() {
        print("🔔 터치됨: 알림 버튼") // ✅ 필요하면 알림 화면으로 이동하도록 수정
    }

    func didTapProfileButton() { // ✅ 만약 프로필 버튼 메서드가 있다면 추가해야 오류 해결됨!
        print("👤 터치됨: 프로필 버튼")
    }
}
    
    func didTapNotificationButton() {
        // 알림 버튼 탭 처리
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
