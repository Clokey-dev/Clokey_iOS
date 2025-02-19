
import Moya
import Foundation

extension NetworkManager {
    //  1. 필수 데이터 요청
    func request<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                let result: Result<T, NetworkError> = self.handleResponse(response, decodingType: decodingType)
                completion(result)
            case .failure(let error):
                let networkError = self.handleNetworkError(error)
                completion(.failure(networkError))
            }
        }
    }
    
    //  2. 옵셔널 데이터 요청
    func requestOptional<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T?, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                let result: Result<T?, NetworkError> = self.handleResponseOptional(response, decodingType: decodingType)
                completion(result)
            case .failure(let error):
                let networkError = self.handleNetworkError(error)
                completion(.failure(networkError))
            }
        }
    }
    
    //  3. 상태 코드만 확인
    func requestStatusCode(
        target: Endpoint,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                let result: Result<ApiResponse<String?>?, NetworkError> = self.handleResponseOptional(
                    response,
                    decodingType: ApiResponse<String?>.self
                )
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            case .failure(let error):
                let networkError = self.handleNetworkError(error)
                completion(.failure(networkError))
            }
        }
    }
    
    //  4. 유효기간 파싱 + 데이터 파싱
    func requestWithTime<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<(T, TimeInterval?), NetworkError>) -> Void //  캐시 유효 시간 포함
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                let result: Result<(T, TimeInterval?), NetworkError> = self.handleResponseTimeInterval(response, decodingType: decodingType)
                completion(result)
            case .failure(let error):
                let networkError = self.handleNetworkError(error)
                completion(.failure(networkError))
            }
        }
    }
    
    // MARK: - 상태 코드 처리 처리 함수
    private func handleResponse<T: Decodable>(
        _ response: Response,
        decodingType: T.Type
    ) -> Result<T, NetworkError> {
        do {
            // 1. 상태 코드 확인
            guard (200...299).contains(response.statusCode) else {
                let errorMessage: String
                switch response.statusCode {
                case 300..<400:
                    errorMessage = "리다이렉션 오류 발생: \(response.statusCode)"
                case 400..<500:
                    errorMessage = "클라이언트 오류 발생: \(response.statusCode)"
                case 500..<600:
                    errorMessage = "서버 오류 발생: \(response.statusCode)"
                default:
                    errorMessage = "알 수 없는 오류 발생: \(response.statusCode)"
                }

                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
                let finalMessage = errorResponse?.message ?? errorMessage
                return .failure(.serverError(statusCode: response.statusCode, message: finalMessage))
            }

            // 2. 응답 디코딩
            let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)

            // 3. result 처리
            guard let result = apiResponse.result else {
                return .failure(.serverError(statusCode: response.statusCode, message: "결과 데이터가 없습니다."))
            }

            return .success(result)

        } catch let decodingError as DecodingError {
            print("🚨 디코딩 오류 발생: \(decodingError)")
            return .failure(.decodingError(underlyingError: decodingError)) //  상세 오류 포함
        } catch {
            return .failure(.decodingError(underlyingError: error as! DecodingError)) //  일반 오류도 포함
        }
    }
    
    private func handleResponseOptional<T: Decodable>(
        _ response: Response,
        decodingType: T.Type
    ) -> Result<T?, NetworkError> {
        do {
            // 1. 상태 코드 확인
            guard (200...299).contains(response.statusCode) else {
                let errorMessage: String
                switch response.statusCode {
                case 300..<400:
                    errorMessage = "리다이렉션 오류가 발생했습니다. 코드: \(response.statusCode)"
                case 400..<500:
                    errorMessage = "클라이언트 오류가 발생했습니다. 코드: \(response.statusCode)"
                case 500..<600:
                    errorMessage = "서버 오류가 발생했습니다. 코드: \(response.statusCode)"
                default:
                    errorMessage = "알 수 없는 오류가 발생했습니다. 코드: \(response.statusCode)"
                }

                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
                let finalMessage = errorResponse?.message ?? errorMessage
                return .failure(.serverError(statusCode: response.statusCode, message: finalMessage))
            }

            // 2. 빈 데이터 처리
            if response.data.isEmpty {
                return .success(nil) //  빈 데이터 처리 (옵셔널 허용)
            }

            // 3. 응답 디코딩
            let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)

            return .success(apiResponse.result) //  result가 옵셔널이라면 nil 반환 가능

        } catch let decodingError as DecodingError {
            print("🚨 디코딩 오류 발생: \(decodingError)")
            return .failure(.decodingError(underlyingError: decodingError)) //  상세 오류 포함
        } catch {
            return .failure(.decodingError(underlyingError: error as! DecodingError)) //  일반 오류도 포함
        }
    }
    
    private func handleResponseTimeInterval<T: Decodable>(
        _ response: Response,
        decodingType: T.Type
    ) -> Result<(T, TimeInterval?), NetworkError> {
        do {
            guard (200...299).contains(response.statusCode) else {
                let errorMessage: String
                switch response.statusCode {
                case 300..<400:
                    errorMessage = "리다이렉션 오류 발생: \(response.statusCode)"
                case 400..<500:
                    errorMessage = "클라이언트 오류 발생: \(response.statusCode)"
                case 500..<600:
                    errorMessage = "서버 오류 발생: \(response.statusCode)"
                default:
                    errorMessage = "알 수 없는 오류 발생: \(response.statusCode)"
                }

                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
                let finalMessage = errorResponse?.message ?? errorMessage
                return .failure(.serverError(statusCode: response.statusCode, message: finalMessage))
            }

            let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)

            // 4. result 처리 (빈 데이터 불허)
            guard let result = apiResponse.result else {
                return .failure(.serverError(statusCode: response.statusCode, message: "결과 데이터가 없습니다."))
            }

            // 5. Cache-Control 처리
            let cacheDuration = extractCacheTimeInterval(from: response)
            print(" Cache-Control 유효 시간: \(cacheDuration ?? 0)초")

            return .success((result, cacheDuration)) //  데이터와 캐시 유효 시간 반환

        } catch let decodingError as DecodingError {
            print("🚨 디코딩 오류 발생: \(decodingError)")
            return .failure(.decodingError(underlyingError: decodingError)) //  상세 오류 포함
        } catch {
            return .failure(.decodingError(underlyingError: error as! DecodingError)) //  일반 오류도 포함
        }
    }
    
    // MARK: - 네트워크 오류 처리 함수
    func handleNetworkError(_ error: Error) -> NetworkError {
        let nsError = error as NSError
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet:
            return .networkError(message: "인터넷 연결이 끊겼습니다.")
        case NSURLErrorTimedOut:
            return .networkError(message: "요청 시간이 초과되었습니다.")
        default:
            return .networkError(message: "네트워크 오류가 발생했습니다.")
        }
    }
    
    func extractCacheTimeInterval(from response: Response) -> TimeInterval? {
        guard let httpResponse = response.response,
              let cacheControl = httpResponse.allHeaderFields["Cache-Control"] as? String else {
            print("⚠️ Cache-Control 헤더가 없습니다.")
            return nil
        }

        let components = cacheControl.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        for component in components {
            if component.starts(with: "max-age") {
                let maxAgeValue = component.split(separator: "=").last
                if let maxAgeString = maxAgeValue, let maxAge = TimeInterval(maxAgeString) {
                    return maxAge
                }
            }
        }
        
        print("⚠️ Cache-Control 헤더에서 max-age를 찾을 수 없습니다.")
        return nil
    }
}
