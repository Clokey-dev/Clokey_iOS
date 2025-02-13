//
//  SearchEndpoint.swift
//  Clokey
//
//  Created by 소민준 on 2/13/25.
//

import Foundation
import Moya


public enum SearchEndpoint {
    case searchMember(data: String?, page: Int, size: Int)
    case searchHistory(data: String?, page: Int, size: Int)
    case searchClothes(keyword: String?, page: Int, size: Int)
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
        case    .searchHistory(let data, let page, let size),
                .searchMember(let data, let page, let size),
                .searchClothes(let data, let page, let size):
            var parameters: [String: Any] = [
                "page": page,
                "size": size
            ]
            if let data = data {
                if case .searchClothes = self {
                    parameters["keyword"] = data 
                } else {
                    parameters["data"] = data
                }
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    
}
