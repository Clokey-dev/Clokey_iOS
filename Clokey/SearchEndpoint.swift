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
            return "/history/search/hashtag-and-category"
        case .searchMember:
            return "/member/search/id-and-nickname"
        case .searchClothes:
            return "/clothes/search/name-and-brand"
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
            
            var parameters: [String: Any] = [
                "by": by,    // 🔥 필터 옵션 추가 (예: "nickname", "id", "hashtag")
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
