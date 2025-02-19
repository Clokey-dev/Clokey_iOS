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

        // 앱이 종료된 상태에서 푸시 알림을 클릭해 실행된 경우, historyId 저장
        if let remoteNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            handleNotification(userInfo: remoteNotification)
        }

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

    // MARK: - 푸시 알림 클릭 시 historyId 저장
    func handleNotification(userInfo: [AnyHashable: Any]) {
        guard let historyIdString = userInfo["historyId"] as? String,
              let historyId = Int(historyIdString) else {
            print("❌ historyId 없음")
            return
        }

        // historyId를 UserDefaults에 저장
        UserDefaults.standard.set(historyId, forKey: "PendingHistoryId")
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Firebase MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("📌 FCM Token: \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: "FCMToken")
        UserDefaults.standard.synchronize()
    }
}

// MARK: - UNUserNotificationCenterDelegate (푸시 알림 처리)
extension AppDelegate {
    // 포그라운드에서 알림 수신
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        handleNotification(userInfo: userInfo) // 포그라운드에서도 데이터 활용 가능
        completionHandler([.alert, .badge, .sound])
    }

    // 백그라운드 & 종료 상태에서 푸시 클릭 시 실행되는 메서드
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        handleNotification(userInfo: userInfo)
        completionHandler()
    }
}
