
import Foundation


class NotificationViewModel {
    var notifications: [NotificationItem] = []
    let notificationService = NotificationService()
    
    // 페이징 관련 변수 추가
    private(set) var currentPage: Int = 1
    private let pageSize: Int = 30
    private(set) var hasMorePages: Bool = true

    // isNextPage가 true이면 다음 페이지를 불러오고, false이면 1페이지부터 다시 불러옵니다.
    func fetchNotificationsFromAPI(isNextPage: Bool = false) {
        let pageToLoad = isNextPage ? currentPage + 1 : 1
        
        notificationService.notificationList(page: pageToLoad) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let newNotifications = response.notificationResults.map { dto in
                    let date = Self.formatDate(dto.createdAt)
                    
                    let _appNotificationType: NotificationType? = {
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
                            switch dto.redirectInfo {
                            case .historyId(let hId):
                                return String(hId)
                            case .clokeyId(let cId):
                                return cId
                            }
                        }()
                        
                    )
                }
                
                // 페이지에 따라 데이터를 추가하거나 초기화
                if isNextPage {
                    self.notifications.append(contentsOf: newNotifications)
                    self.currentPage = pageToLoad
                } else {
                    self.notifications = newNotifications
                    self.currentPage = 1
                }
                
                // 새로 불러온 항목 수가 pageSize 이상이면 더 불러올 페이지가 있다고 가정
                self.hasMorePages = newNotifications.count >= self.pageSize
                
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
