//
//  ReportEndpoint.swift
//  Clokey
//
//  Created by 황상환 on 3/12/25.
//

import Foundation
import Moya

public enum ReportEndpoint {
    case getProfileReportInfo(clokeyId: String)
    case getCommentReportInfo(commentId: String)
    case getHistoryReportInfo(historyId: String)
    
    case reportProfile(data: ReportRequestDTO)
    case reportComment(data: ReportRequestDTO)
    case reportHistory(data: ReportRequestDTO)
}

extension ReportEndpoint: TargetType {
    public var baseURL: URL {
        return URL(string: API.baseURL)!
    }

    // 엔드 포인트 주소
    public var path: String {
        switch self {
        case .getProfileReportInfo:
            return "/report/profile"
        case .reportProfile:
            return "/report/profile"
            
        case .getCommentReportInfo:
            return "/report/comment"
        case .reportComment:
            return "/report/comment"
            
        case .getHistoryReportInfo:
            return "/report/history"
        case .reportHistory:
            return "/report/history"
        }
    }

    // HTTP 메서드
    public var method: Moya.Method {
        switch self {
        case .getProfileReportInfo, .getCommentReportInfo, .getHistoryReportInfo:
            return .get
        case .reportProfile, .reportComment, .reportHistory:
            return .post
        }
    }

    // 요청 데이터
    public var task: Moya.Task {
        switch self {
        case .getProfileReportInfo(let clokeyId):
            return .requestParameters(parameters: ["clokeyId": clokeyId], encoding: URLEncoding.queryString)
        case .getCommentReportInfo(let commentId):
            return .requestParameters(parameters: ["commentId": commentId], encoding: URLEncoding.queryString)
        case .getHistoryReportInfo(let historyId):
            return .requestParameters(parameters: ["historyId": historyId], encoding: URLEncoding.queryString)
        case .reportProfile(let data), .reportComment(let data), .reportHistory(let data):
            return .requestJSONEncodable(data)
        }
    }

    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
