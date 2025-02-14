//
//  HomeEndPoint.swift
//  Clokey
//
//  Created by 한금준 on 2/2/25.
//

import Foundation
import Moya

public enum HomeEndPoint {
    case getIssues(view: String?, section: String?, page: Int?)
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
        case .getIssues:
            return "/home"
        case .getOneYearAgoHistories: // 새로 추가된 경로
            return "/home/1-year-ago"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getIssues:
            return .get
        case .getOneYearAgoHistories:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .getIssues(let view, let section, let page):
            var parameters: [String: Any] = [:]

            // ✅ view는 기본값이 "simple"이므로 nil이면 생략 가능
            if let view = view, !view.isEmpty {
                parameters["view"] = view
            }

            // ✅ section은 nil이거나 유효한 값이 아닐 경우 에러 방지를 위해 처리
            if let section = section, !section.isEmpty {
                parameters["section"] = section
            } else {
                print("❌ section 값이 유효하지 않음")
            }

            // ✅ page는 view가 "full"일 때만 사용 가능하므로, nil 체크 필요
            if let page = page, page > 0 {
                parameters["page"] = page
            } else {
                print("❌ page 값이 유효하지 않음")
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
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

