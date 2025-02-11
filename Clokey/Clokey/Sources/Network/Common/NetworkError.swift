import Foundation

public enum NetworkError: Error {
    case networkError(message: String)
    case decodingError(underlyingError: DecodingError)
    case serverError(statusCode: Int, message: String)
    case unknown
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "🚨 네트워크 오류 발생: \(message)"
        
        case .decodingError(let underlyingError):
            return "❌ 데이터 디코딩 실패: \(decodingErrorDescription(underlyingError))" // 🔥 상세 오류 메시지
        
        case .serverError(let statusCode, let message):
            return "🔴 서버 오류 (\(statusCode)): \(message)"
        
        case .unknown:
            return "⚠️ 알 수 없는 오류가 발생했습니다."
        }
    }

    // 디코딩 오류를 더 자세하게 설명하는 함수 추가
    private func decodingErrorDescription(_ error: DecodingError) -> String {
        switch error {
        case .keyNotFound(let key, let context):
            return "필수 키 '\(key.stringValue)'가 누락됨. (Context: \(context.debugDescription))"
        case .typeMismatch(let type, let context):
            return "타입 불일치: '\(type)' (Context: \(context.debugDescription))"
        case .valueNotFound(let type, let context):
            return "'\(type)' 값이 존재하지 않음. (Context: \(context.debugDescription))"
        case .dataCorrupted(let context):
            return "데이터가 손상됨. (Context: \(context.debugDescription))"
        @unknown default:
            return "알 수 없는 디코딩 오류 발생"
        }
    }
}
