//
//  SearchEndpoint.swift
//  Clokey
//
//  Created by 소민준 on 2/13/25.
//


import Foundation
import Moya

public enum SearchEndpoint {
    case searchMember(by: String, keyword: String, page: Int, size: Int)
    case searchHistory(by: String, keyword: String, page: Int, size: Int)
    case searchClothes(by: String, keyword: String, page: Int, size: Int)
}

extension SearchEndpoint: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("잘못된 URL입니다.")
        }
        return url
    }
    
    public var path: String {
        switch self {
        case .searchHistory:
            return "/search/histories"  // ✅ 슬래시 추가
        case .searchMember:
            return "/search/members"
        case .searchClothes:
            return "/search/clothes"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Moya.Task {
        switch self {
        case .searchHistory(let by, let keyword, let page, let size),
             .searchMember(let by, let keyword, let page, let size),
             .searchClothes(let by, let keyword, let page, let size):
            
            let parameters: [String: Any] = [
                "by": by,      //  API 필터 (예: "id-and-nickname", "hashtag")
                "keyword": keyword,
                "page": page,
                "size": size
            ]
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
