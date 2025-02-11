//
//  NotificationViewModel.swift
//  Clokey
//
//  Created by 소민준 on 2/11/25.
//


//
//  NotificationViewModel.swift
//  Alarm
//
//  Created by 소민준 on 2/8/25.
//
import Foundation


class NotificationViewModel {
    var notifications: [NotificationItem] = []

    func fetchDummyNotifications() {
        notifications = [
            NotificationItem(id: 1, type: .like, title: "OO님이 회원님의 옷장을 팔로우하기 시작했습니다.", content: "", createdAt: Date(), imageUrl: nil, isRead: false),
            NotificationItem(id: 2, type: .weather, title: "기온이 어제보다 6도 낮아요!", content: "", createdAt: Date(), imageUrl: nil, isRead: false),
            NotificationItem(id: 3, type: .like, title: "OO님이 회원님의 기록을 좋아합니다.", content: "", createdAt: Date(), imageUrl: nil, isRead: false),
            NotificationItem(id: 4, type: .recap, title: "1년 전 오늘의 기록을 확인해보세요.", content: "", createdAt: Date(), imageUrl: nil, isRead: true),
            NotificationItem(id: 5, type: .follower, title: "새로운 유저가 당신을 팔로우했습니다!", content: "", createdAt: Date(), imageUrl: nil, isRead: false),
            NotificationItem(id: 6, type: .recap, title: "작년 오늘의 기록을 확인하세요.", content: "", createdAt: Date(), imageUrl: nil, isRead: false)
        ]
        
        loadReadStatus() // 저장된 읽음 상태 불러오기
    }

    func markAllAsRead() {
        for index in notifications.indices {
            if !notifications[index].isRead {
                notifications[index].isRead = true // 읽지 않은 것들만 읽음으로 변경
            }
        }
        saveReadStatus() // 저장된 읽음 상태 업데이트
    }

    // 읽음 상태를 UserDefaults에 저장
    private func saveReadStatus() {
        let readStatus = notifications.reduce(into: [String: Bool]()) { $0["\($1.id)"] = $1.isRead }
        UserDefaults.standard.set(readStatus, forKey: "ReadStatus")
    }

    // UserDefaults에서 읽음 상태 불러오기
    private func loadReadStatus() {
        guard let savedStatus = UserDefaults.standard.dictionary(forKey: "ReadStatus") as? [String: Bool] else { return }
        for index in notifications.indices {
            if let isRead = savedStatus["\(notifications[index].id)"] {
                notifications[index].isRead = isRead
            }
        }
    }
}
