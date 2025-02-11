//
//  SceneDelegate.swift
//  Clokey
//
//  Created by 황상환 on 12/31/24.
//

import UIKit
import KakaoSDKAuth
import AuthenticationServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // 앱의 화면이 처음 생성될 때 호출되는 메서드.
        
        // 초기 화면 설정
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        // 커스텀 예시
//        let loginViewController = ViewController()
//        let navigationController = UINavigationController(rootViewController: loginViewController)
//        window?.rootViewController = navigationController
        
        // 로그인 화면을 초기 화면으로 설정
        let loginViewController = LoginViewController(coordinator: self)
        window?.rootViewController = loginViewController
       
//        let loginViewController = CalendarDetailViewController()
//        window?.rootViewController = loginViewController
               
        // 임시 자동 로그인 코드
//         앱 실행 시, 바로 메인화면을 원하면 위 코드 대신 이 코드를 사용
//        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
//        
//        if isLoggedIn {
//            // 로그인 상태라면 메인 화면으로 이동
//            let mainViewController = MainViewController()
//            let navigationController = UINavigationController(rootViewController: mainViewController)
//            window?.rootViewController = navigationController
//        } else {
//            // 비로그인 상태라면 로그인 화면 표시
//            let loginViewController = LoginViewController(coordinator: self)
//            let navigationController = UINavigationController(rootViewController: loginViewController)
//            window?.rootViewController = navigationController
//        }
        
        window?.makeKeyAndVisible()
        
    }
    
    // 카카오 로그인 처리를 위한 URL 처리
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            print("카카오 로그인 콜백 URL 수신: \(url)")
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
                print("카카오 로그인 URL 처리 완료")
            }
        }
    }
    
    // 시스템에 의해 씬이 해제될 때 호출 (백그라운드에서 메모리 해제될 때)
    func sceneDidDisconnect(_ scene: UIScene) {
       
    }

    // 씬이 활성화될 때 호출 (앱이 foreground에서 실행되고 사용자와 상호작용 가능한 상태)
    func sceneDidBecomeActive(_ scene: UIScene) {
       
    }

    // 씬이 비활성화되기 직전에 호출 (전화가 오거나 다른 앱으로 전환될 때)
    func sceneWillResignActive(_ scene: UIScene) {
       
    }

    // 씬이 백그라운드에서 포그라운드로 전환될 때 호출
    func sceneWillEnterForeground(_ scene: UIScene) {
       
    }

    // 씬이 포그라운드에서 백그라운드로 전환될 때 호출 (홈버튼 눌러서 나갈 때)
    func sceneDidEnterBackground(_ scene: UIScene) {
     
    }
}

extension SceneDelegate: Coordinator {
    // 화면 전환 메서드 -> MainViewController
    func switchToMain() {
        let mainVC = MainViewController()
        let navigationController = UINavigationController(rootViewController: mainVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    // 화면 전환 메서드 -> AgreementViewController
//    func navigateToAgreement() {
//        let agreementVC = AgreementViewController()
//        let navigationController = UINavigationController(rootViewController: agreementVC)
//        window?.rootViewController = navigationController
//        window?.makeKeyAndVisible()
//    }
    
    // 화면 전환 메서드 -> LoginViewController
    func switchToLogin() {
        let loginVC = LoginViewController(coordinator: self)
        window?.rootViewController = loginVC
        window?.makeKeyAndVisible()
    }
    
    // 에플 로그인 - 필요한 window 객체 제공
    func getPresentationAnchor() -> ASPresentationAnchor {
        guard let window = window else {
            fatalError("Window is not available")
        }
        return window
    }
}
