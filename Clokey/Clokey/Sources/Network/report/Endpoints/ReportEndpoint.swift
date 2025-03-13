//
//  ReportEndpoint.swift
//  Clokey
//
//  Created by 황상환 on 3/12/25.
//

import Foundation
import Moya

public enum ReportEndpoint {
    case getReportInfo(clokeyId: String) // 신고 정보 조회
    case reportProfile(data: ReportRequestDTO) // 프로필 신고

}

extension ReportEndpoint: TargetType {
    public var baseURL: URL {
        return URL(string: API.baseURL)!
    }

    public var path: String {
        switch self {
        case .getReportInfo:
            return "/report/profile"
        case .reportProfile:
            return "/report/profile"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .getReportInfo:
            return .get
        case .reportProfile:
            return .post
        }
    }

    public var task: Moya.Task {
        switch self {
        case .getReportInfo(let clokeyId):
            return .requestParameters(parameters: ["clokeyId": clokeyId], encoding: URLEncoding.queryString)
        case .reportProfile(let data):
            return .requestJSONEncodable(data)
        }
    }

    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
