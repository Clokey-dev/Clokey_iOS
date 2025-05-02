//
//  CategoriesEndPoint.swift
//  Clokey
//
//  Created by 한금준 on 2/12/25.
//

import Foundation
import Moya

public enum CategoriesEndPoint {
    case getRecommendCategory(name: String)
    
}

extension CategoriesEndPoint: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    // 엔드 포인트 주소
    public var path: String {
        switch self {
        case .getRecommendCategory:
            return "/categories/recommend"
        }
    }
    
    
    // HTTP 메서드
    public var method: Moya.Method {
        switch self {
        case .getRecommendCategory:
            return .get
        }
    }
    
    // 요청 데이터(내가 서버로 보내야 하는 데이터)
    public var task: Moya.Task {
        switch self {
        case .getRecommendCategory(let name):
            return .requestParameters(parameters: ["name": name], encoding: URLEncoding.queryString)
        }
    }
    
    public var headers: [String: String]? {
        return [
            "Content-Type": "application/json"
        ]
    }
    
}
