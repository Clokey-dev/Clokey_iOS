//
//  CustomNavigationBar.swift
//  Clokey
//
// 커스텀 네비게이션 바
// VC 에서 NavigationBarManager 호출
// setupNavBar 함수에서 func 호출

import Foundation
import UIKit
import SnapKit

class NavigationBarManager {
    
    // MARK: - Initializer
    init() {}
    
    // MARK: - 왼쪽 커스텀 Back 버튼 생성
    func addBackButton(
        to navigationItem: UINavigationItem,
        target: Any?,
        action: Selector,
        tintColor: UIColor = .mainBrown800
    ) {
        let backButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: config)
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = tintColor
        backButton.addTarget(target, action: action, for: .touchUpInside)
        backButton.accessibilityLabel = "뒤로 가기"

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    // MARK: - 네비게이션 타이틀 설정 (텍스트)
    func setTitle(
        to navigationItem: UINavigationItem,
        title: String? = nil,
        font: UIFont = UIFont.ptdSemiBoldFont(ofSize: 22),
        textColor: UIColor = .label
    ) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = font
        titleLabel.textColor = textColor
        titleLabel.textAlignment = .center
        titleLabel.accessibilityLabel = title
        
        navigationItem.titleView = titleLabel
    }
    
    func setOption(
        to navigationItem: UINavigationItem,
        target: Any?,
        action: Selector,
        tintColor: UIColor = .mainBrown800
    ) {
        let optionButton = UIButton(type: .system)
        let backImage = UIImage(named: "dot3_icon")
        optionButton.setImage(backImage, for: .normal)
        optionButton.tintColor = tintColor
        optionButton.addTarget(target, action: action, for: .touchUpInside)
        optionButton.accessibilityLabel = "옵션"
        // 버튼 크기 조정
        optionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            optionButton.widthAnchor.constraint(equalToConstant: 24),
            optionButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: optionButton)
    }
}

extension NavigationBarManager {
    func setupWhiteNavigationBar(for navigationController: UINavigationController?) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear // 네비게이션 바 하단 그림자 제거
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // iOS 15 이상에서 사용되는 설정
        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
        }
        
        // 기본 네비게이션 바 설정도 함께 적용
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .mainBrown800
    }
}
// 사용 예시
//
//import UIKit
//
//class MyViewController: UIViewController {
//
//    let navBarManager = NavigationBarManager()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.backgroundColor = .white
//
//        // 왼쪽 백 버튼 추가
//        navBarManager.addBackButton(
//            to: navigationItem,
//            target: self,
//            action: #selector(didTapBackButton)
//        )
//
//        // 타이틀 설정
//        navBarManager.setTitle(
//            to: navigationItem,
//            title: "커스텀 네비게이션 바",
//            font: .systemFont(ofSize: 18, weight: .semibold), textColor: .black
//        )
//    }
//
//    @objc private func didTapBackButton() {
//        print("뒤로 버튼 클릭")
//        // NavigationController pop 동작
//        navigationController?.popViewController(animated: true)
//    }
//}


