//
//  HomeViewController.swift
//  Clokey
//
//  Created by 한금준 on 1/10/25.
//

// 완료

import UIKit
import SnapKit
import Then

final class HomeViewController: UIViewController {
    
    private let homeView = HomeView()
    
    private var selectedTab: TabType = .pick

    private let pickViewController = PickViewController()
    
    private let newsViewController = NewsViewController()
    
    override func loadView() {
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActions()
        selectTab(.pick)
        
        
    }

    private func setupActions() {
        homeView.pickButton.addTarget(self, action: #selector(tabSelected(_:)), for: .touchUpInside)
        homeView.newsButton.addTarget(self, action: #selector(tabSelected(_:)), for: .touchUpInside)
    }

    @objc private func tabSelected(_ sender: UIButton) {
        guard let tabType = TabType(rawValue: sender.tag) else { return }
        selectTab(tabType)
    }
    
    private func selectTab(_ tab: TabType) {
        selectedTab = tab  // 현재 선택된 탭 업데이트

        switch tab {
        case .pick:
            configureTabAppearance(selectedButton: homeView.pickButton, deselectedButton: homeView.newsButton, indicatorColor: .mainBrown800)
        case .news:
            configureTabAppearance(selectedButton: homeView.newsButton, deselectedButton: homeView.pickButton, indicatorColor: .pointOrange800)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        updateContainerView(for: tab)
    }
    
    private func configureTabAppearance(selectedButton: UIButton, deselectedButton: UIButton, indicatorColor: UIColor) {
        homeView.indicatorView.snp.remakeConstraints { make in
            make.centerX.equalTo(selectedButton.snp.centerX)
            make.bottom.equalTo(homeView.separatorLine.snp.top)
            make.height.equalTo(5)
            make.width.equalTo(88)
        }

        selectedButton.setTitleColor(indicatorColor, for: .normal)
        deselectedButton.setTitleColor(UIColor(red: 78/255, green: 52/255, blue: 46/255, alpha: 0.5), for: .normal)

        homeView.indicatorView.backgroundColor = indicatorColor
    }
    
    private func updateContainerView(for tab: TabType) {
        // 기존 자식 ViewController 제거
        if pickViewController.parent != nil {
            pickViewController.willMove(toParent: nil)
            pickViewController.view.removeFromSuperview()
            pickViewController.removeFromParent()
        }
        if newsViewController.parent != nil {
            newsViewController.willMove(toParent: nil)
            newsViewController.view.removeFromSuperview()
            newsViewController.removeFromParent()
        }
        
        let selectedVC = (tab == .pick) ? pickViewController : newsViewController
        addChild(selectedVC)
        homeView.containerView.addSubview(selectedVC.view)

        selectedVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        selectedVC.didMove(toParent: self)
    }

}
