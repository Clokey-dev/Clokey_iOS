//
//  NotificationType.swift
//  Clokey
//
//  Created by 소민준 on 2/11/25.
//


//
//  NotificationType.swift
//  Alarm
//
//  Created by 소민준 on 2/8/25.
//
import UIKit

enum NotificationType: String {
    case like = "LIKE"
    case follower = "FOLLOWER"
    case weather = "WEATHER"
    case recap = "RECAP"
}

struct NotificationItem {
    let id: Int
    let type: NotificationType
    let title: String
    let content: String
    let createdAt: Date
    let imageUrl: String? // 프로필 이미지 URL (follower 타입용)
    var isRead: Bool
}
