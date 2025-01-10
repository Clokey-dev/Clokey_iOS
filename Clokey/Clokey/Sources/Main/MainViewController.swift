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
    private lazy var homeVC = HomeViewController(viewModel: HomeViewModel())
    private lazy var calendarVC = CalendarViewController(viewModel: CalendarViewModel())
    private lazy var addClothVC = AddClothViewController(viewModel: AddClothViewModel())
    private lazy var closetVC = ClosetViewController(viewModel: ClosetViewModel())
    private lazy var profileVC = ProfileViewController(viewModel: ProfileViewModel())
        
    
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
    
    // MARK: - Methods
    private func showViewController(_ viewController: UIViewController) {
        // 현재 표시된 뷰컨트롤러 해제
        children.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        
        // 새로운 뷰컨트롤러 추가
        addChild(viewController)
        mainView.contentView.addSubview(viewController.view)
        viewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        viewController.didMove(toParent: self)
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
            showViewController(addClothVC)
        case 3:
            showViewController(closetVC)
        case 4:
            showViewController(profileVC)
        default:
            break
        }
    }
}
