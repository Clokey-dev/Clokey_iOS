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

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let notificationView = NotificationView()
    private var viewModel = NotificationViewModel()
    
    override func loadView() {
        view = notificationView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupTableView()
        loadNotifications()
        
        notificationView.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
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

    private func loadNotifications() {
        viewModel.fetchDummyNotifications()
        notificationView.tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.markAllAsRead() // 화면이 사라질 때 읽음 처리
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationView.tableView.reloadData() // UI 업데이트
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 // 셀 자체 높이 (36) + 간격 (24) 포함
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        let unreadCount = viewModel.notifications.filter { !$0.isRead }.count
        return unreadCount > 0 ? 2 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let unread = viewModel.notifications.filter { !$0.isRead }
        let read = viewModel.notifications.filter { $0.isRead }
        return numberOfSections(in: tableView) == 2 ? (section == 0 ? unread.count : read.count) : read.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let unread = viewModel.notifications.filter { !$0.isRead }
        let read = viewModel.notifications.filter { $0.isRead }

        let notification = numberOfSections(in: tableView) == 2
            ? (indexPath.section == 0 ? unread[indexPath.row] : read[indexPath.row])
            : read[indexPath.row]

        cell.configure(with: notification)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return numberOfSections(in: tableView) == 2 ? (section == 0 ? "읽지않음" : "읽음") : "읽음"
    }
}
