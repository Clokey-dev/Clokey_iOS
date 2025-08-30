//
//  TokenManager.swift
//  Clokey
//
//  Created by 황상환 on 2/15/25.
//

import Foundation

final class TokenManager {
    static let shared = TokenManager()
    static let tokenRefreshThreshold: TimeInterval = 3 * 60 * 60 // 3시간
    private let memberService = MembersService()
    
    // Race Condition 방지 프로퍼티
    private var isRefreshing = false
    private var waitingRequests: [(Bool) -> Void] = []
    private let lockQueue = DispatchQueue(label: "com.clokey.tokenManager.lock")

    private init() {}

    func validateAndRefreshTokenIfNeeded(completion: @escaping (Bool) -> Void) {
        guard let accessToken = KeychainHelper.shared.get(forKey: "accessToken"),
              let expirationDate = JWTHelper.shared.getTokenExpirationDate(from: accessToken) else {
            completion(false)
            return
        }

        let timeRemaining = expirationDate.timeIntervalSince(Date())

        // 남은 시간이 임계값(3시간) 이하이면 무조건 갱신을 시도
        if timeRemaining <= TokenManager.tokenRefreshThreshold {
            print("TokenManager: 토큰 유효 시간이 임계값 이하. 재발급을 시도합니다.")
            refreshToken(completion: completion)
        } else {
            // 유효 시간이 충분하면 성공 처리
            print("TokenManager: 토큰 유효 시간이 충분합니다.")
            completion(true)
        }
    }

    // Race Condition 방어 로직
    func refreshToken(completion: @escaping (Bool) -> Void) {
        lockQueue.async { [weak self] in
            guard let self = self else { return }

            // 이미 다른 요청이 토큰 재발급을 진행 중인 경우
            if self.isRefreshing {
                self.waitingRequests.append(completion)
                print("TokenManager: 이미 재발급 진행 중. 요청을 대기열에 추가합니다.")
                return
            }

            // 이것이 첫 재발급 요청인 경우
            self.isRefreshing = true
            print("TokenManager: 재발급 프로세스를 시작합니다.")

            guard let refreshToken = KeychainHelper.shared.get(forKey: "refreshToken") else {
                print("TokenManager: 리프레시 토큰이 없어 재발급에 실패했습니다.")
                self.completeAllRequests(success: false)
                return
            }
            
            let reissueRequestDTO = ReissueTokenRequestDTO(refreshToken: refreshToken)
            
            // 실제 네트워크 요청
            self.memberService.reissueToken(data: reissueRequestDTO) { result in
                switch result {
                case .success(let response):
                    print("TokenManager: 새 토큰 발급 성공.")
                    KeychainHelper.shared.save(response.accessToken, forKey: "accessToken")
                    KeychainHelper.shared.save(response.refreshToken, forKey: "refreshToken")
                    self.completeAllRequests(success: true)
                case .failure(let error):
                    print("TokenManager: 토큰 재발급 API 호출 실패 - \(error.localizedDescription)")
                    KeychainHelper.shared.delete(forKey: "accessToken")
                    KeychainHelper.shared.delete(forKey: "refreshToken")
                    self.completeAllRequests(success: false)
                }
            }
        }
    }

    // 대기 중이던 모든 요청에 결과를 알려주는 헬퍼 메서드
    private func completeAllRequests(success: Bool) {
        lockQueue.async { [weak self] in
            guard let self = self else { return }
            
            print("TokenManager: 대기 중인 \(self.waitingRequests.count)개의 요청에 결과(\(success))를 전달합니다.")
            
            // 메인 스레드에서 completion 핸들러들을 실행
            DispatchQueue.main.async {
                self.waitingRequests.forEach { $0(success) }
                self.waitingRequests.removeAll()
            }
            
            self.isRefreshing = false
        }
    }
}
