//
//  AppDelegate.swift
//  Clokey
//
//  Created by 황상환 on 12/31/24.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase 초기화
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        // 푸시 알림 권한 요청
        UNUserNotificationCenter.current().delegate = self
        requestNotificationAuthorization(application)

        // 카카오 SDK 초기화
        if let appKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String {
            print("Kakao App Key: \(appKey)") // 디버그용
            KakaoSDK.initSDK(appKey: appKey)
        }
        
        let manager = IQKeyboardManager.shared
           manager.isEnabled = true                // 키보드 자동 처리 활성화
           manager.resignOnTouchOutside = true     // 화면 터치 시 키보드 자동 내림

        return true
    }

    private func requestNotificationAuthorization(_ application: UIApplication) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if granted {
                print("✅ 푸시 알림 권한 허용됨")
            } else {
                print("❌ 푸시 알림 권한 거부됨")
            }
        }
        
        // APNs 등록
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }
    }

    // APNs 디바이스 토큰 받기
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("📌 APNs Device Token: \(tokenString)")
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ APNs 등록 실패: \(error.localizedDescription)")
    }
}

// MARK: - Firebase MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("FCM 토큰을 받지 못함")
            return
        }
        print("📌 FCM Token: \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: "FCMToken")
        UserDefaults.standard.synchronize()
    }
}

// MARK: - UNUserNotificationCenterDelegate (푸시 알림 처리)
extension AppDelegate {
    // 포그라운드에서 알림 수신
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let historyId = userInfo["historyId"] as? String {
            navigateToHistoryDetail(historyId: historyId)
        }
        
        if let clokeyId = userInfo["clokeyId"] as? String {
            navigateToFollowProfile(clokeyId: clokeyId)
        }
        
        completionHandler()
    }

    // 푸시 알림을 누르면 기록으로 이동
    private func navigateToHistoryDetail(historyId: String) {
        DispatchQueue.main.async {
            guard let historyIdInt = Int(historyId) else {
                print("historyId 변환 실패")
                return
            }

            let detailVC = FriendsCalendarDetailViewController()

            let historyService = HistoryService()
            historyService.historyDetail(historyId: historyIdInt) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        detailVC.setDetailData(response) // 올바른 DTO 전달
                        
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = scene.windows.first,
                           let navController = window.rootViewController as? UINavigationController {
                            navController.pushViewController(detailVC, animated: true)
                        }
                    }
                case .failure(let error):
                    print("히스토리 상세 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    // 푸시 알림을 누르면 프로필로 이동
    private func navigateToFollowProfile(clokeyId: String) {
        DispatchQueue.main.async {
            let followVC = FollowProfileViewController(followId: clokeyId)

            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first,
               let navController = window.rootViewController as? UINavigationController {
                navController.pushViewController(followVC, animated: true)
            }
        }
    }
}
