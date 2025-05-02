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
        setupTabBarAppearance()
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
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        // 선택된 아이콘 및 텍스트 색상
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(named: "mainBrown800")
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(named: "mainBrown800") ?? .black
        ]

        // 선택되지 않은 아이콘 및 텍스트 색상
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(named: "mainBrown200")
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(named: "mainBrown200") ?? .gray
        ]

        // 탭바에 appearance 적용
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
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
            UITabBarItem(
                title: "홈",
                image: resizedImage(named: "home_icon", size: CGSize(width: 24, height: 24)),
                selectedImage: resizedImage(named: "home_n_icon", size: CGSize(width: 24, height: 24))
            ),
            UITabBarItem(
                title: "캘린더",
                image: resizedImage(named: "calendar_n_icon", size: CGSize(width: 24, height: 24)),
                selectedImage: resizedImage(named: "calendar_icon", size: CGSize(width: 24, height: 24))
            ),
            UITabBarItem(
                title: "추가",
                image: resizedImage(named: "add_n_icon", size: CGSize(width: 24, height: 24)),
                selectedImage: resizedImage(named: "add_icon", size: CGSize(width: 24, height: 24))
            ),
            UITabBarItem(
                title: "내 옷장",
                image: resizedImage(named: "hanger_n_icon", size: CGSize(width: 24, height: 24)),
                selectedImage: resizedImage(named: "hanger_icon", size: CGSize(width: 24, height: 24))
            ),
            UITabBarItem(
                title: "내 프로필",
                image: resizedImage(named: "profile_n_icon", size: CGSize(width: 24, height: 24)),
                selectedImage: resizedImage(named: "profile_icon", size: CGSize(width: 24, height: 24))
            )
        ]
        
        items.enumerated().forEach { index, item in
            item.tag = index
        }
        
        tabBar.setItems(items, animated: false)
        tabBar.selectedItem = items[0]
    }

    
    // 하단 메뉴 이미지 크기 조절
    func resizedImage(named: String, size: CGSize) -> UIImage? {
        guard let image = UIImage(named: named) else { return nil }
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

}

// MARK: - UITabBarDelegate
extension TabBarView: UITabBarDelegate {
    // 탭바 아이템 선택 시, 호출되는 델리게이트 설정
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        delegate?.tabBar(tabBar, didSelect: item)
    }
}
