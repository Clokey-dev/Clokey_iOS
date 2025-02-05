//
//  HomeEndPoint.swift
//  Clokey
//
//  Created by 한금준 on 2/2/25.
//

import Foundation
import Moya

public enum HomeEndPoint {
    case getOneYearAgoHistories
    
}

extension HomeEndPoint: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    public var path: String {
        switch self {
        case .getOneYearAgoHistories: // 새로 추가된 경로
            return "/histories/1-year-ago"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getOneYearAgoHistories:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .getOneYearAgoHistories: // 새로 추가된 Task
                    return .requestPlain
                }
    }
    
    public var headers: [String : String]? {
        switch self {
        default:
            return [
                "Content-Type": "application/json"
            ]
        }
    }
    
}

