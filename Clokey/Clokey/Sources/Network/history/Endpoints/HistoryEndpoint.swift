//
//  HistoryEndpoint.swift
//  Clokey
//
//  Created by 황상환 on 1/28/25.
//

import Foundation
import Moya

public enum HistoryEndpoint {
    case historyMonth(clokeyId: String?, month: String)
    case historyDetail(historyId: Int)
    case historyLike(data: HistoryLikeRequestDTO)
    case historyComments(historyId: Int, page: Int)
    case historyCommentWrite(historyId: Int, data: HistoryCommentWriteRequestDTO)
    // 추가적인 API는 여기 케이스로 정의
}

extension HistoryEndpoint: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("잘못된 URL입니다.")
        }
        return url
    }
    
    // 엔드 포인트 주소
    public var path: String {
        switch self {
        case .historyMonth:
            return "/histories/monthly"
        case .historyDetail(let historyId):
            return "/histories/\(historyId)"
        case .historyLike:
            return "/histories/like"
        case .historyComments(let historyId, _):
            return "/histories/\(historyId)/comments"
        case .historyCommentWrite(let historyId, _):
            return "/histories/\(historyId)/comments"
        }
    }
    
    // HTTP 메서드
    public var method: Moya.Method {
        switch self {
        case .historyLike, .historyCommentWrite:
            return .post
//        case
//            return .patch
        case .historyMonth, .historyDetail, .historyComments:
            return .get
//        case
//            return .delete
        }
    }
    
    // 요청 데이터(내가 서버로 보내야 하는 데이터)
    public var task: Moya.Task {
        switch self {
        case .historyMonth(let clokeyId, let month):
            var parameters: [String: Any] = ["month": month]
            if let clokeyId = clokeyId {
                parameters["clokeyId"] = clokeyId
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .historyDetail:
            return .requestPlain // Path Parameter만 사용 (Body 필요 없음)
        case .historyLike(let data):
            return .requestJSONEncodable(data)
        case .historyComments(_, let page):
            return .requestParameters(
                parameters: ["page": page],
                encoding: URLEncoding.queryString
            )
        case .historyCommentWrite(_, let data):
            return .requestJSONEncodable(data)
        }
    }

    
    public var headers: [String: String]? {
        return [
            "Content-Type": "application/json"
        ]
    }
}
