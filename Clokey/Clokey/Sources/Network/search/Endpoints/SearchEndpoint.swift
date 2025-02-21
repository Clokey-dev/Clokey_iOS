import Foundation
import Moya

public enum SearchEndpoint {
    case searchMember(by: String, keyword: String, page: Int, size: Int)
    case searchHistory(by: String, keyword: String, page: Int, size: Int)
    case searchClothes(clokeyId: String?, by: String, keyword: String, page: Int, size: Int)
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
            return "/search/histories"
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
        case .searchMember(let by, let keyword, let page, let size),
             .searchHistory(let by, let keyword, let page, let size):
            
            // 사람 검색, 히스토리 검색은 clokeyId가 없으므로 공통 처리
            let parameters: [String: Any] = [
                "by": by,
                "keyword": keyword,
                "page": page,
                "size": size
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
            
        case .searchClothes(let clokeyId, let by, let keyword, let page, let size):
            // 옷 검색의 경우 clokeyId가 있을 수도, 없을 수도 있음
            var parameters: [String: Any] = [
                "by": by,
                "keyword": keyword,
                "page": page,
                "size": size
            ]
            // clokeyId가 nil이 아니고 비어있지 않으면 파라미터에 추가
            if let cId = clokeyId, !cId.isEmpty {
                parameters["clokeyid"] = cId
            }
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
