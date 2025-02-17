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
    
    // 앱의 화면이 처음 생성될 때 호출되는 메서드
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        // 로그인 상태에 따라 다른 애니메이션 설정
        let animationName = isLoggedIn ? "Onboarding_yes" : "Onboarding_no"
        
        let lottieVC = LottieViewController(animationName: animationName)

        // 애니메이션 완료 후 동작 설정
        lottieVC.animationCompletionHandler = { [weak self] in
            guard let self = self else { return }

            if isLoggedIn {
                // 토큰 체크
                TokenManager.shared.validateAndRefreshTokenIfNeeded { isValid in
                    DispatchQueue.main.async {
                        if isValid {
                            self.switchToMain()
                        } else {
                            self.switchToLogin()
                        }
                    }
                }
            } else {
                // 화면 터치
                lottieVC.enableTapToProceed { [weak self] in
                    self?.switchToLogin()
                }
            }
        }

        window?.rootViewController = lottieVC
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
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        if !isLoggedIn {
            print("로그인 상태 아님 -> 토큰 검사 패스")
            return
        }

        guard let accessToken = KeychainHelper.shared.get(forKey: "accessToken"),
              let expirationDate = JWTHelper.shared.getTokenExpirationDate(from: accessToken) else {
            self.switchToLogin() // 토큰이 없거나 만료 시간을 알 수 없으면 로그인 화면으로 이동
            return
        }

        let timeRemaining = expirationDate.timeIntervalSince(Date())

        print("Foreground 진입 - JWT 남은 시간: \(timeRemaining / 60)분")

        if timeRemaining <= 10 * 60 { // 10분 이하 남았을 때 자동 갱신
            print("토큰 만료 임박.. 즉시 재발급 ON!")
            TokenManager.shared.validateAndRefreshTokenIfNeeded { isValid in
                if !isValid {
                    DispatchQueue.main.async {
                        self.switchToLogin() // 갱신 실패 시 로그인 화면으로 전환
                    }
                }
            }
        }
    }



    // 씬이 포그라운드에서 백그라운드로 전환될 때 호출 (홈버튼 눌러서 나갈 때)
    func sceneDidEnterBackground(_ scene: UIScene) {
     
    }
}

extension SceneDelegate: Coordinator {
    
    func switchToMain() {
        let mainVC = MainViewController()
        let navigationController = UINavigationController(rootViewController: mainVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    // 화면 전환 메서드 -> AgreementViewController
    func navigateToAgreement() {
        let agreementVC = AgreementViewController()
        let navigationController = UINavigationController(rootViewController: agreementVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func navigateToAddProfile() {
        let addProfileVC = AddProfileViewController()
        let navigationController = UINavigationController(rootViewController: addProfileVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    // 화면 전환 메서드 -> LoginViewController
    func switchToLogin() {
        let loginVC = LoginViewController(coordinator: self)
        window?.rootViewController = loginVC
        window?.makeKeyAndVisible()
    }
    
    // 애플 로그인 - 필요한 window 객체 제공
    func getPresentationAnchor() -> ASPresentationAnchor {
        guard let window = window else {
            fatalError("Window is not available")
        }
        return window
    }
}
