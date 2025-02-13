//
//  SuccessViewController.swift
//  Clokey
//
//  Created by 한금준 on 2/2/25.
//

import UIKit

class SuccessViewController: UIViewController {
    private let successView = SuccessView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = successView
        
        // 2초 후 MainViewController로 이동
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.navigateToMainViewController()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func navigateToMainViewController() {
        let mainVC = MainViewController()
        mainVC.modalPresentationStyle = .fullScreen
        
        // 네비게이션 컨트롤러가 있을 경우 Push
        if let navigationController = navigationController {
            navigationController.setViewControllers([mainVC], animated: true)
        } else {
            // 네비게이션 컨트롤러가 없을 경우 모달로 표시
            present(mainVC, animated: true, completion: nil)
        }
    }
    
}
