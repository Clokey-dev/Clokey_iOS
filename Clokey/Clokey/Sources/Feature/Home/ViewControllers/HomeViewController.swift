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

/// `HomeViewController`는 메인 화면을 관리하며 탭을 선택하여 화면을 전환
final class HomeViewController: UIViewController {
    
    /// 메인 화면에 사용되는 뷰 (`HomeView`)
    private let homeView = HomeView()
    
    /// 현재 선택된 탭 타입 (기본값은 `.pick`)
    private var selectedTab: TabType = .pick
    
    /// 'Pick' 탭에 해당하는 화면
    private let pickViewController = PickViewController()
    
    private let pickNothingViewController = PickNothingViewController()
    
    /// 'News' 탭에 해당하는 화면
    private let newsViewController = NewsViewController()
    
    /// 뷰 컨트롤러의 루트 뷰를 `homeView`로 설정
    override func loadView() {
        view = homeView
    }
    
    /// 뷰가 메모리에 로드된 후 호출되며 초기 설정을 수행
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActions()  // 버튼 액션 설정
        selectTab(.pick) // 초기 탭 설정
        
    }
    
    
    
    // MARK: - Actions
    
    /// 버튼의 액션(target)을 설정
    private func setupActions() {
        homeView.pickButton.addTarget(self, action: #selector(tabSelected(_:)), for: .touchUpInside)
        homeView.newsButton.addTarget(self, action: #selector(tabSelected(_:)), for: .touchUpInside)
    }
    
    /// 탭 버튼 클릭 시 호출되는 메서드
    /// - Parameter sender: 클릭된 버튼
    @objc private func tabSelected(_ sender: UIButton) {
        // 버튼의 tag를 통해 탭 타입을 결정
        guard let tabType = TabType(rawValue: sender.tag) else { return }
        selectTab(tabType)
    }
    
    /// 선택된 탭에 따라 화면 및 UI를 업데이트
    /// - Parameter tab: 선택된 탭 타입
    private func selectTab(_ tab: TabType) {
        selectedTab = tab  // 현재 선택된 탭 업데이트
        
        // 선택된 탭에 따라 버튼과 IndicatorView의 색상 및 위치 변경
        switch tab {
        case .pick:
            configureTabAppearance(selectedButton: homeView.pickButton, deselectedButton: homeView.newsButton, indicatorColor: .mainBrown800)
        case .news:
            configureTabAppearance(selectedButton: homeView.newsButton, deselectedButton: homeView.pickButton, indicatorColor: .pointOrange800)
        }
        
        // 레이아웃 업데이트 애니메이션 적용
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        // 선택된 탭에 맞는 ViewController로 화면 전환
        updateContainerView(for: tab)
    }
    
    /// 선택된 버튼과 IndicatorView를 업데이트
    /// - Parameters:
    ///   - selectedButton: 선택된 버튼
    ///   - deselectedButton: 선택 해제된 버튼
    ///   - indicatorColor: IndicatorView 색상
    private func configureTabAppearance(selectedButton: UIButton, deselectedButton: UIButton, indicatorColor: UIColor) {
        // IndicatorView의 위치 및 크기 업데이트
        homeView.indicatorView.snp.remakeConstraints { make in
            make.centerX.equalTo(selectedButton.snp.centerX)
            make.bottom.equalTo(selectedButton.snp.bottom).offset(6)
            make.height.equalTo(5)
//            make.width.equalTo(selectedButton.snp.width).multipliedBy(0.5)
            make.width.equalTo(88)
        }
        // 선택된 버튼과 선택 해제된 버튼의 색상 변경
        selectedButton.setTitleColor(indicatorColor, for: .normal)
        deselectedButton.setTitleColor(UIColor(red: 78/255, green: 52/255, blue: 46/255, alpha: 0.5), for: .normal)
        // IndicatorView의 배경색 업데이트
        homeView.indicatorView.backgroundColor = indicatorColor
    }
    
    /// 선택된 탭에 따라 컨테이너 뷰를 업데이트
    /// - Parameter tab: 선택된 탭 타입
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
        
        // 새로운 ViewController를 추가
//        let selectedVC = (tab == .pick) ? pickNothingViewController : newsViewController
        let selectedVC = (tab == .pick) ? pickViewController : newsViewController
        addChild(selectedVC)
        homeView.containerView.addSubview(selectedVC.view)
        
        // 선택된 ViewController의 레이아웃 설정
        selectedVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        selectedVC.didMove(toParent: self)
    }

}
