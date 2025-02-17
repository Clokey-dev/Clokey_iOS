//
//  FolderEndpoint.swift
//  Clokey
//
//  Created by 한태빈 on 2/13/25.
//

import Foundation
import Moya

// 폴더 생성
public enum FolderEndpoint{
    case folderCheck(folderId: Int, page: Int)
    case folderAll(page: Int)
    case folderManage(data: FolderManageRequestDTO)
    case folderDelete(folderId: Int)

}
extension FolderEndpoint: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: API.baseURL) else {
            fatalError("잘못된 URL입니다.")
        }
        return url
    }
    
    // 엔드 포인트 주소
    public var path: String {
        switch self {
        case .folderCheck(let folderId, _):
            return "/folders/\(folderId)/clothes"
        case .folderAll:
            return "/folders"
        case .folderManage:
            return "/folders"
        case .folderDelete(let folderId):
            return "/folders/\(folderId)"
        }
    }
    
    // HTTP 메서드
    public var method: Moya.Method {
        switch self {
        case .folderManage:
            return .post
        case .folderCheck, .folderAll:
            return .get
        case .folderDelete:
            return .delete
        }
    }
    
    //요청 데이터
    public var task: Moya.Task {
        switch self {
        case .folderCheck(_, let page):
            return .requestParameters(parameters: ["page": page],
                                      encoding: URLEncoding.default)
            
        case .folderAll(let page):
            return .requestParameters(parameters: ["page": page],
                                      encoding: URLEncoding.default)
            
        case .folderManage(let data):
            return .requestJSONEncodable(data)
            
        case .folderDelete:
            return .requestPlain
        }
    }
    
    
    public var headers: [String: String]? {
        return [
            "Content-Type": "application/json"
        ]
    }
}
