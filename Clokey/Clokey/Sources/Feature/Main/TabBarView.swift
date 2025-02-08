//
//  TabBarView.swift
//  Clokey
//
//  Created by 황상환 on 1/20/25.
//

import Foundation
import UIKit
import SnapKit
import Then

// 탭바 선택 시 이벤트 처리 델리게이트 프로토콜
/* 왜 사용?
 - TabBarView는 파일은 탭바의 UI만 담당하고 각 탭이 무슨 화면을 보여줄지는 MainViewController가 결정
 - TabBarView는 누가 자신을 쓰는지 모름
    -> "어떤 특정" 파일에서 자신이 delegate 되어 처리할 것 만 알게 됨.
    -> 코드의 유연성 up
*/
protocol TabBarViewDelegate: AnyObject {
    // 각 탭 처리 메서드
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
}

final class TabBarView: UIView {
    
    // MARK: - Properties
    
    // 탭바 델리게이트
    weak var delegate: TabBarViewDelegate?
    
    // MARK: - UI Components
    
    // 하단 탭바
    let tabBar: UITabBar = {
        let tabBar = UITabBar()
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = .white
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        return tabBar
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupTabBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        addSubview(tabBar)
        tabBar.delegate = self
    }
    
    // 탭바 레이아웃 설정
    private func setupConstraints() {
        tabBar.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // 각 탭바 아이템 설정
    private func setupTabBar() {
        let items = [
            UITabBarItem(title: "홈", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill")),
            UITabBarItem(title: "캘린더", image: UIImage(systemName: "calendar"), selectedImage: UIImage(systemName: "calendar.fill")),
            UITabBarItem(title: "추가", image: UIImage(systemName: "plus"), selectedImage: UIImage(systemName: "plus.circle.fill")),
            UITabBarItem(title: "내옷장", image: UIImage(systemName: "tshirt"), selectedImage: UIImage(systemName: "tshirt.fill")),
            UITabBarItem(title: "프로필", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        ]
        
        // index 사용해서 탭바 구분
        items.enumerated().forEach { index, item in
            item.tag = index
        }
        
        // 탭바 디폴트 설정
        tabBar.setItems(items, animated: false)
        tabBar.selectedItem = items[0]
    }
}

// MARK: - UITabBarDelegate
extension TabBarView: UITabBarDelegate {
    // 탭바 아이템 선택 시, 호출되는 델리게이트 설정
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        delegate?.tabBar(tabBar, didSelect: item)
    }
}
