//
//  MainView.swift
//  Clokey
//
//  Created by 황상환 on 1/10/25.
//

import Foundation
import UIKit
import SnapKit
import Then

final class MainView: UIView {
    
    // MARK: - UI Components
    
    // 상단 바
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // 각 탭 컨테이너 뷰
    let contentView = UIView()
    
    // Clokey 라벨
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "clokey"
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
    // 검색 버튼
    private let searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    // 알림 버튼
    private let notificationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    // 하단 탭바
    let tabBar: UITabBar = {
        let tabBar = UITabBar()
        // 선택 탭바 색 설정
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = .white
        
        // 탭바 스타일 커스텀
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        
        // 탭바 스타일 상태 설정
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        return tabBar
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    // UI 셋업
    private func setupUI() {
        backgroundColor = .white
        [headerView, contentView, tabBar].forEach { addSubview($0) }
        [logoLabel, searchButton, notificationButton].forEach { headerView.addSubview($0) }
        
        setupTabBar()
    }
    
    // 텝바 셋업
    private func setupTabBar() {
        let items = [
            UITabBarItem(title: "홈", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill")),
            UITabBarItem(title: "캘린더", image: UIImage(systemName: "calendar"), selectedImage: UIImage(systemName: "calendar.fill")),
            UITabBarItem(title: "추가", image: UIImage(systemName: "plus"), selectedImage: UIImage(systemName: "plus.circle.fill")),
            UITabBarItem(title: "내옷장", image: UIImage(systemName: "tshirt"), selectedImage: UIImage(systemName: "tshirt.fill")),
            UITabBarItem(title: "프로필", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        ]
        
        // 각 텝 인덱스 설정
        items.enumerated().forEach { index, item in
            item.tag = index
        }
        
        // 탭바 애니메이션 및 기본 화면 선택
        tabBar.setItems(items, animated: false)
        tabBar.selectedItem = items[0]
    }

    private func setupConstraints() {
        
        // 상단 바
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(47)
            $0.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(50)
        }
        
        // 상단 로고
        logoLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(16)
        }
        
        // 상단 검색 버튼
        searchButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(notificationButton.snp.leading).offset(-16)
            $0.size.equalTo(24)
        }
        
        // 상단 알림 버튼
        notificationButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(-16)
            $0.size.equalTo(24)
        }
        
        // 화면 뷰
        contentView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBar.snp.top)
        }
        
        // 하단 탭바
        tabBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}
