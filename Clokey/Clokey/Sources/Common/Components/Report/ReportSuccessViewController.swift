//
//  ReportSuccessViewController.swift
//  Clokey
//
//  Created by 한금준 on 3/11/25.
//

import UIKit

class ReportSuccessViewController: UIViewController {

    private let reportSuccessView = ReportSuccessView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = reportSuccessView
        
        // 2초 후 MainViewController로 이동
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.navigationToProfileVC()
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
    
//    private func navigateToMainViewController() {
//        
//        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
//            sceneDelegate.switchToMain()
//        }
//    }
    
    private func navigationToProfileVC() {
//        self.navigationController?.popToRootViewController(animated: true) {
//            self.navigationController?.popToRootViewController(animated: true) {
//                self.navigationController?.popToRootViewController(animated: true)
//            }
//        }
        self.navigationController?.popToRootViewController(animated: true)
    }
}
