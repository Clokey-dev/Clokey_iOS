//
//  ReportEndpoint.swift
//  Clokey
//
//  Created by 한금준 on 3/16/25.
//

import Foundation
import Moya

public enum ReportEndpoint {
    case getProfileReportInformation(clokeyId: String)
    
}

extension ReportEndpoint: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("잘못된 URL")
        }
        return url
    }
    
    public var path: String {
        switch self {
        case .getProfileReportInformation:
            return "/report/profile"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getProfileReportInformation:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .getProfileReportInformation(let clokeyId):
            return .requestParameters(parameters: ["clokeyId": clokeyId], encoding: URLEncoding.queryString)
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
    


