//
//  HomeEndPoint.swift
//  Clokey
//
//  Created by 한금준 on 2/2/25.
//

import Foundation
import Moya

public enum HomeEndPoint {
    case recommendClothes(nowTemp: Int32, minTemp: Int32, maxTemp: Int32)
    case getOneYearAgoHistories
//    case getAllIssues
    case getDetailIssues(section: String?, page: Int)
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
        case .recommendClothes:
            return "/home/recommend"
        case .getOneYearAgoHistories: // 새로 추가된 경로
            return "/home/1-year-ago"
        case .getDetailIssues:
            return "/home/news/detail"
        
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .recommendClothes:
            return .get
        case .getOneYearAgoHistories:
            return .get
        case .getDetailIssues:
            return .get
        
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .recommendClothes(let nowTemp, let minTemp, let maxTemp):
                let parameters: [String: Any] = [
                    "nowTemp": nowTemp,
                    "minTemp": minTemp,
                    "maxTemp": maxTemp
                ]
                return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getOneYearAgoHistories: // 새로 추가된 Task
            return .requestPlain
        case .getDetailIssues(let section, let page):
            var parameters: [String: Any] = [:]

            // section이 "closet" 또는 "calendar"일 때만 추가
            if let section = section, ["closet", "calendar"].contains(section) {
                parameters["section"] = section
            }

            // page는 1 이상이어야 함
            if page >= 1 {
                parameters["page"] = page
            } else {
                print("page 값이 1 이상이어야 합니다.")
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        
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

