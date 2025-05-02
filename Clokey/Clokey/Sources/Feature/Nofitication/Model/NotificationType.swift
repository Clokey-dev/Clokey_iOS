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
    let title: String       // 서버의 content
    let createdAt: Date
    let imageUrl: String?
    var isRead: Bool
    
    // 새로 추가: 서버의 redirectType, redirectInfo
    let redirectType: RedirectType
    let redirectInfo: String
    
    // (선택) 기존 NotificationType(좋아요/팔로우/댓글...)를 쓰고 싶다면 여기에 추가
   // let type: NotificationType // like, follower, recap, etc.
}
