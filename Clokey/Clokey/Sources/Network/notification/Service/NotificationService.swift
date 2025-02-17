

//
//  NotificationService.swift
//  Clokey
//
//  Created by 소민준 on 2/16/25.
//

import Foundation
import Moya

public final class NotificationService : NetworkManager {
    typealias Endpoint = NotificationEndpoints
    let provider: MoyaProvider<NotificationEndpoints>
    
    public init(provider: MoyaProvider<NotificationEndpoints>? = nil) {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
            AccessTokenPlugin(),
            TokenRefreshPlugin()
        ]
        self.provider = provider ?? MoyaProvider<NotificationEndpoints>(plugins: plugins)
    }
    
    
    
    public func notificationList(
        page : Int,
        completion: @escaping (Result< NotificationResponseDTO, NetworkError>) -> Void
    ){
        request(target: .notificationList(page: page),
                decodingType: NotificationResponseDTO.self,
                completion: completion
        )
    }
    public func notificationExsit(
        notificationId : Int64,
        completion: @escaping (Result< NotificationUnreadResponseDTO, NetworkError>) -> Void
    ){
        request(target: .notificationExist,
                decodingType: NotificationUnreadResponseDTO.self,
                completion: completion
            
        )
    }
    public func notificationLove(
        historyId: Int64,
        completion: @escaping (Result<NotificationLoveResponseDTO, NetworkError>) -> Void
    ){
        request(target: .notificationLove(historyId: historyId),
                decodingType: NotificationLoveResponseDTO.self,
                completion: completion
        )
    }
    public func notificationFollow(
        clokeyId : String,
        completion: @escaping (Result<NotificationFollowResponseDTO, NetworkError>) -> Void
    ){
        request(target: .notificationFollow(clokeyId: clokeyId),
                decodingType: NotificationFollowResponseDTO.self,
                completion: completion
        )
        
    }
    public func notificationComment(
        historyId: Int64,
        commentId: Int64,
        completion: @escaping (Result<NotificationHistoryCommentResponseDTO, NetworkError>) -> Void
    ){
        request(target: .notificationComment(historyId: historyId, commentId: commentId),
                decodingType: NotificationHistoryCommentResponseDTO.self,
                completion: completion
                
        )
    }
    public func notificationReply(
        commentId: Int64,
        replyId: Int64,
        completion: @escaping (Result<NotificationReplyResponseDTO,
                               NetworkError>) -> Void
        
    ){
        request(target: .notificationReply(commentId: commentId, replyId: replyId),
                decodingType: NotificationReplyResponseDTO.self,
                completion : completion
        )
    }
    public func notificationYearAgo(
        completion : @escaping (Result<Void,NetworkError>) -> Void
    ){
        requestStatusCode(
            target: .notificationYearAgo,
            
            completion: completion
        )
    }
    public func notificationTemperature(
        completion : @escaping (Result<Void, NetworkError>) -> Void
    ){
        requestStatusCode(target: .notificationTemperature, completion: completion
        )
    }
    public func notificationSeasonChange(
        season: SeasonType,
        completion : @escaping (Result<Void, NetworkError>) -> Void
    ){
        requestStatusCode(target: .notificationSeasonChange(season: season), completion: completion)
    }
    
}
