//
//  NotificationEndpoints.swift
//  Clokey
//
//  Created by 소민준 on 2/17/25.
//


//
//  NotificationEndpoints.swift
//  Clokey
//
//  Created by 소민준 on 2/16/25.
//

import Foundation
import Moya


public enum NotificationEndpoints {
    
    case notificationList(page : Int)
    case notificationRead(notificationId: Int64)
    case notificationExist
    case notificationLove(historyId: Int64)
    case notificationFollow(clokeyId: String)
    case notificationComment(historyId: Int64, commentId: Int64)
    case notificationReply(commentId: Int64, replyId: Int64)
    case notificationYearAgo
    case notificationTemperature
    case notificationSeasonChange(season: SeasonType)
}


public enum SeasonType: String, Codable {
    case spring = "SPRING"
    case summer = "SUMMER"
    case fall = "FALL"
    case winter = "WINTER"
}

extension NotificationEndpoints: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("잘못된 URL입니다.")
        }
        return url
    }
    
    public var path: String {
        switch self {
        case .notificationList:
            return "/notifications"
        case .notificationRead(let notificationId):
            return "/notifications/\(notificationId)"
        case .notificationExist:
            return "/notifications/not-read-exist"
        case .notificationLove:
            return "/notifications/history-like"
        case .notificationFollow:
            return "/notifications/new-follower"
        case .notificationComment:
            return "/notifications/history-comment"
        case .notificationReply:
            return "/notifications/comment-reply"
        case .notificationYearAgo:
            return "/notifications/1-year-ago"
        case .notificationTemperature:
            return "/notifications/today-temperature"
        case .notificationSeasonChange:
            return "/notifications/seasons"
            
        }
    }
    public var method: Moya.Method {
        switch self {
        case .notificationList, .notificationExist:
            return .get
        case .notificationRead:
            return .patch
        case .notificationLove, .notificationFollow, .notificationComment, .notificationReply:
            return .post
        case .notificationYearAgo, .notificationTemperature, .notificationSeasonChange:
            return .post
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .notificationList(let page):
            return .requestParameters(
                parameters: ["page": page],
                encoding: URLEncoding.queryString
            )
            
        case .notificationRead(let notificationId):
            return .requestParameters(
                parameters: ["notificationId": notificationId],
                encoding: URLEncoding.queryString
            )
            
        case .notificationExist:
            return .requestPlain
            
        case .notificationLove(let historyId):
            return .requestParameters(
                parameters: ["historyId": historyId],
                encoding: URLEncoding.queryString
            )
            
        case .notificationFollow(let clokeyId):
            return .requestParameters(
                parameters: ["clokeyId": clokeyId],
                encoding: URLEncoding.queryString
            )
            
        case .notificationComment(let historyId, let commentId):
            return .requestParameters(
                parameters: ["historyId": historyId, "commentId": commentId],
                encoding: URLEncoding.queryString
            )
            
        case .notificationReply(let commentId, let replyId):
            return .requestParameters(
                parameters: ["commentId": commentId, "replyId": replyId],
                encoding: URLEncoding.queryString
            )
            
        case .notificationYearAgo,
                .notificationTemperature:
            return .requestPlain
            
        case .notificationSeasonChange(let season):
            return .requestParameters(
                parameters: ["season": season.rawValue],
                encoding: URLEncoding.queryString
            )
        }
    }
    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
        
    }
}
