//
//  NotificationViewController.swift
//  Clokey
//
//  Created by 소민준 on 2/11/25.
//

//
//  NotificationViewController.swift
//  Alarm
//
//  Created by 소민준 on 2/8/25.

//
import UIKit
import RxSwift
import RxCocoa
import RxGesture

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationCellDelegate, UIGestureRecognizerDelegate {
    func notificationCell(_ cell: NotificationCell, didTapProfileFor notification: NotificationItem) {
        
        // (A) 프로필 탭 시 처리 로직을 여기에 작성합니다.
        print("프로필 탭: \(notification.title)")
        // 예시: FollowProfileViewController로 이동
        let profileVC = FollowProfileViewController(followId: "")
        profileVC.followId = notification.redirectInfo  // 또는 적절한 값
        navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    
    private let notificationView = NotificationView()
    private var viewModel = NotificationViewModel()
    private let refreshControl = UIRefreshControl()
    
    override func loadView() {
        view = notificationView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupTableView()
        navigationItem.hidesBackButton = true
        
        notificationView.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        // 알림 업데이트 감지 후 reload
        NotificationCenter.default.addObserver(self, selector: #selector(reloadNotifications), name: NSNotification.Name("ReloadNotifications"), object: nil)
        notificationView.tableView.alwaysBounceVertical = true
        notificationView.tableView.refreshControl = refreshControl
        //왼쪽에서 오른쪽 스와이프 하면 뒤로가기
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchNotificationsFromAPI()
        updateEmptyState()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    @objc private func handleSwipeBack(_ gesture: UISwipeGestureRecognizer) {
        // 시작 위치가 왼쪽 가장자리인지 추가 확인하려면 gesture.location(in: view)를 사용할 수 있습니다.
        let startPoint = gesture.location(in: view)
        if startPoint.x < 30 {
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    
    
    @objc private func reloadNotifications() {
        notificationView.tableView.reloadData()
        updateEmptyState()
    }
    
    @objc private func didPullToRefresh() {
        // 전체 읽음 처리 API 호출
        print("Refresh triggered")
        viewModel.markAllNotificationsAsRead { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self?.refreshControl.endRefreshing()
                // API 호출 후 새로 알림 목록 갱신 (원하는 경우)
                self?.viewModel.fetchNotificationsFromAPI()
            }
        }
    }
    private func setupTableView() {
        notificationView.tableView.delegate = self
        notificationView.tableView.dataSource = self
        notificationView.tableView.register(NotificationCell.self, forCellReuseIdentifier: "NotificationCell")
        notificationView.tableView.separatorStyle = .none
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 // 셀 자체 높이 (36) + 간격 (24) 포함
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let unreadCount = viewModel.notifications.filter { !$0.isRead }.count
        let readCount = viewModel.notifications.filter { $0.isRead }.count
        
        // 알림이 하나도 없으면 섹션을 0개로
        if unreadCount == 0 && readCount == 0 {
            return 0
        }
        
        // 읽지 않음, 읽음 두 섹션이 있으면
        if unreadCount > 0 && readCount > 0 {
            return 2
        }
        
        // 읽음 또는 읽지 않음 하나만 있을 때
        return 1
        
    }
    
    // MARK: - UIScrollViewDelegate for Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        // 스크롤이 바닥 근처에 도달하면 추가 페이지 요청
        if offsetY > contentHeight - frameHeight - 100 {
            if viewModel.hasMorePages {
                viewModel.fetchNotificationsFromAPI(isNextPage: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let unread = viewModel.notifications.filter { !$0.isRead }
        let read = viewModel.notifications.filter { $0.isRead }
        
        // 두 그룹이 모두 있을 때 섹션 구분
        if unread.count > 0 && read.count > 0 {
            return section == 0 ? unread.count : read.count
        } else if unread.count > 0 { // 읽지 않은 알림만 있을 경우
            return unread.count
        } else { // 읽은 알림만 있을 경우
            return read.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let unread = viewModel.notifications.filter { !$0.isRead }
        let read = viewModel.notifications.filter { $0.isRead }
        let notification: NotificationItem
        
        if unread.count > 0 && read.count > 0 {
            // 두 그룹이 모두 있을 때 섹션 0은 읽지 않은, 섹션 1은 읽은 알림
            notification = indexPath.section == 0 ? unread[indexPath.row] : read[indexPath.row]
        } else if unread.count > 0 {
            notification = unread[indexPath.row]
        } else {
            notification = read[indexPath.row]
        }
        
        cell.configure(with: notification)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let unreadCount = viewModel.notifications.filter { !$0.isRead }.count
        let readCount = viewModel.notifications.filter { $0.isRead }.count
        
        // 알림 자체가 0개인 경우 섹션이 0개이므로 여기 안 타야 정상
        if unreadCount == 0 && readCount == 0 {
            return nil
        }
        
        // 둘 다 있는 경우 → 0: 읽지 않음, 1: 읽음
        if unreadCount > 0 && readCount > 0 {
            return (section == 0) ? "읽지 않음" : "읽음"
        }
        // 안 읽은 알림만 있는 경우
        if unreadCount > 0 {
            return "읽지 않음"
        }
        // 읽은 알림만 있는 경우
        return "읽음"
    }
    private func fetchHistoryDetail(historyId: Int) {
        let historyService = HistoryService()
        
        historyService.historyDetail(historyId: historyId) { //[weak self]
            result in
            //guard let self = self else { return }
            
            switch result {
            case .success(let response):
                print("히스토리 상세 조회 성공: \(response)")
                
                DispatchQueue.main.async {
                    let detailVC = FriendsCalendarDetailViewController()
                    detailVC.setDetailData(response)
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                       let navController = windowScene.windows.first?.rootViewController as? UINavigationController {
                        navController.pushViewController(detailVC, animated: true)
                    }
                }
            case .failure(let error):
                print("히스토리 상세 조회 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func handleNotificationFollow(clokeyId: String) {
        DispatchQueue.main.async {
            self.navigateToFollowProfile(clokeyId: clokeyId)
        }
    }
    
    private func navigateToFollowProfile(clokeyId: String) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let navController = windowScene.windows.first?.rootViewController as? UINavigationController else {
                print("네비게이션 컨트롤러가 없음")
                return
            }
            
            let followProfileVC = FollowProfileViewController(followId: clokeyId)
            followProfileVC.followId = clokeyId
            navController.pushViewController(followProfileVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.isUserInteractionEnabled = false
        let unread = viewModel.notifications.filter { !$0.isRead }
        let read = viewModel.notifications.filter { $0.isRead }
        
        let notification: NotificationItem
        if unread.count > 0 && read.count > 0 {
            notification = indexPath.section == 0 ? unread[indexPath.row] : read[indexPath.row]
        } else if unread.count > 0 {
            notification = unread[indexPath.row]
        } else {
            notification = read[indexPath.row]
        }
        
        // 읽음 처리 API 호출
        viewModel.markNotificationAsRead(notificationId: notification.id)
        
        // 선택 시 추가 행동이 있다면 처리
        let redirectType = notification.redirectType
        let redirectInfo = notification.redirectInfo
        
        switch redirectType {
        case .historyRedirect:
            if let historyId = Int(redirectInfo) {
                self.fetchHistoryDetail(historyId: historyId)
            } else {
                print("historyId 변환 실패")
            }
        case .memberRedirect:
            self.handleNotificationFollow(clokeyId: redirectInfo)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            tableView.isUserInteractionEnabled = true
        }
    }
    
    func updateEmptyState() {
        let unreadCount = viewModel.notifications.filter { !$0.isRead }.count
        let readCount = viewModel.notifications.filter { $0.isRead }.count
        let _ = unreadCount + readCount
        
        // 1) backgroundView 라벨 처리
        if unreadCount == 0 && readCount == 0 {
            let label = UILabel()
            label.text = "현재 알람이 없습니다!"
            label.textAlignment = .center
            label.textColor = .gray
            notificationView.tableView.backgroundView = label
        } else {
            notificationView.tableView.backgroundView = nil
        }
        
        // 2) 테이블뷰 리로드
        notificationView.tableView.reloadData()
    }
}
/*extension NotificationViewController: NotificationCellDelegate {
 func notificationCell(_ cell: NotificationCell, didTapProfileFor notification: NotificationItem) {
 // **(A) 부분 탭 이벤트 처리**
 switch notification.type {
 case .like:
 // 기록 좋아요: (A)를 누르면 → (A)의 프로필로 이동
 print("Like 알림 (A) 탭 → (A)의 프로필로 이동")
 // 예: navigationController?.pushViewController(ProfileViewController(userID: ...), animated: true)
 case .follower:
 // 팔로우 알림: (A)를 누르면 → (A)의 프로필로 이동
 print("Follow 알림 (A) 탭 → (A)의 프로필로 이동")
 case .recap:
 // 댓글 알림: (A)를 누르면 → (A)의 프로필로 이동
 // 단, 대댓글인 경우 두 동작이 동일 (게시물로 이동) 처리할 수 있음
 if notification.title.contains("대댓글") {
 print("대댓글 답장 알림 (A) 탭 → 해당 게시물로 이동")
 } else {
 print("댓글 알림 (A) 탭 → (A)의 프로필로 이동")
 }
 default:
 break
 }
 }*/


