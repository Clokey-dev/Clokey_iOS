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

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeBack(_:)))
        swipeGesture.direction = .right
        view.addGestureRecognizer(swipeGesture)
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
        print("섹션 개수: \(numberOfSections(in: tableView))")
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    }
    func updateEmptyState() {
        let unreadCount = viewModel.notifications.filter { !$0.isRead }.count
        let readCount = viewModel.notifications.filter { $0.isRead }.count
        let totalCount = unreadCount + readCount
        
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
