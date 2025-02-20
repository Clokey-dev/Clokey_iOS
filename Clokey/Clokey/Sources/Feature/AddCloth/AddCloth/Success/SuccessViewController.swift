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
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.switchToMain()
        }
    }
    
}
