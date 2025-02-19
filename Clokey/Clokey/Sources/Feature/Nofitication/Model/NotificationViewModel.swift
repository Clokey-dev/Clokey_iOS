
import Foundation


class NotificationViewModel {
    var notifications: [NotificationItem] = []
    let notificationService = NotificationService()

    func fetchNotificationsFromAPI() {
        notificationService.notificationList(page: 1) { [weak self] result in
            switch result {
            case .success(let response):
                self?.notifications = response.notificationResults.map { dto in
                    // 서버 응답: dto.redirectType == .historyRedirect or .memberRedirect
                    //           dto.redirectInfo == "15" or "paeng" 등
                    let date = Self.formatDate(dto.createdAt)
                    
                    // (선택) 좋아요/팔로우 알림 판별 로직
                    let appNotificationType: NotificationType? = {
                        // 예: content 안의 문구를 보고 구분
                        if dto.content.contains("좋아요") {
                            return .like
                        } else if dto.content.contains("팔로우") {
                            return .follower
                        } else if dto.content.contains("댓글") {
                            return .recap
                        } else {
                            return nil
                        }
                    }()
                    
                    return NotificationItem(
                        id: Int(dto.notificationId),
                        title: dto.content,
                        createdAt: date,
                        imageUrl: dto.notificationImageUrl,
                        isRead: dto.isRead,
                        redirectType: {
                            switch dto.redirectType {
                            case .historyRedirect:
                                return .historyRedirect
                            case .memberRedirect:
                                return .memberRedirect
                            }
                        }(),
                        redirectInfo: {
                            // dto.redirectInfo는 enum RedirectInfo 형태이므로, 내부를 꺼내 문자열로 저장
                            switch dto.redirectInfo {
                            case .historyId(let hId):
                                return String(hId) // "15"
                            case .clokeyId(let cId):
                                return cId         // "paeng"
                            }
                        }()
                        
                    )
                }
                NotificationCenter.default.post(name: NSNotification.Name("ReloadNotifications"), object: nil)
            case .failure(let error):
                print("❌ 알림 목록 조회 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private static func formatDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date()
    }

    func saveReadStatus() {
        let readStatus = notifications.reduce(into: [String: Bool]()) { $0["\($1.id)"] = $1.isRead }
        UserDefaults.standard.set(readStatus, forKey: "ReadStatus")
    }

    func loadReadStatus() {
        guard let savedStatus = UserDefaults.standard.dictionary(forKey: "ReadStatus") as? [String: Bool] else { return }
        for index in notifications.indices {
            if let isRead = savedStatus["\(notifications[index].id)"] {
                notifications[index].isRead = isRead
            }
        }
    }
    func markNotificationAsRead(notificationId: Int) {
        notificationService.notificationRead(notificationId: Int64(notificationId)) { [weak self] result in
            switch result {
            case .success:
                // 성공 시 로컬 데이터 업데이트
                if let index = self?.notifications.firstIndex(where: { $0.id == notificationId }) {
                    self?.notifications[index].isRead = true
                }
                // UI 갱신
                NotificationCenter.default.post(name: NSNotification.Name("ReloadNotifications"), object: nil)
            case .failure(let error):
                print("❌ 읽음 처리 실패: \(error.localizedDescription)")
            }
        }
    }
    func markAllNotificationsAsRead(completion: @escaping () -> Void) {
        notificationService.notificationAllRead { [weak self] result in
            switch result {
            case .success:
                // 로컬 데이터 업데이트: 모든 알림을 읽음으로 표시
                self?.notifications = self?.notifications.map { notification in
                    var updatedNotification = notification
                    updatedNotification.isRead = true
                    return updatedNotification
                } ?? []
                // UI 갱신을 위해 NotificationCenter로 알림 전송
                NotificationCenter.default.post(name: NSNotification.Name("ReloadNotifications"), object: nil)
                completion()
            case .failure(let error):
                print("❌ 전체 읽음 처리 실패: \(error.localizedDescription)")
                completion()
            }
        }
    }
}
