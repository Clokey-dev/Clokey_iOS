//
//  CommentHistoryViewController.swift
//  Clokey
//
//  Created by 황상환 on 3/16/25.
//

import Foundation
import UIKit

class CommentHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    private let navBarManager = NavigationBarManager()
    private let historyService = HistoryService()
    
    private let commentHistoryView = CommentHistoryView()
    
    // 댓글 데이터 배열 수정
    private var histories: [HistoryModel] = []
    
    // 페이지네이션 관련 변수
    private var currentPage = 1
    private var totalPages = 1
    private var isLastPage = false
    private var isLoading = false
    
    // MARK: - Lifecycle
    override func loadView() {
        view = commentHistoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        // 테이블 뷰 설정
        commentHistoryView.tableView.delegate = self
        commentHistoryView.tableView.dataSource = self
        
        // 제스처 설정
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // 데이터 로드
        loadCommentHistories()
    }
    
    // 네비게이션 설정
    private func setupNavigationBar() {
        let backButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: config)
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .mainBrown800
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "내가 남긴 댓글"
        titleLabel.font = .ptdSemiBoldFont(ofSize: 20)
        titleLabel.textColor = .black
        
        let titleItem = UIBarButtonItem(customView: titleLabel)
        
        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backButton), titleItem]
    }
    
    // 뒤로가기
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    // 댓글 불렁오기 API
    private func loadCommentHistories(page: Int = 1) {
        isLoading = true
        commentHistoryView.setLoading(true)
        
        historyService.getMyCommentHistories(page: page) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.commentHistoryView.setLoading(false)
                
                switch result {
                case .success(let response):
                    print("서버 응답 확인: \(response)")
                    
                    if page == 1 {
                        self.histories = response.histories
                    } else {
                        self.histories.append(contentsOf: response.histories)
                    }
                    
                    self.totalPages = response.totalPage
                    self.isLastPage = response.isLast
                    self.currentPage = page
                    
                    self.commentHistoryView.tableView.reloadData()
                    
                case .failure(let error):
                    print("Error fetching comment histories: \(error)")
                    self.showAlert(title: "네트워크 오류", message: "인터넷 연결이 원활하지 않아요.\n잠시 후 다시 시도해 주세요.")
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentHistoryCell", for: indexPath) as? CommentHistoryCell else {
            return UITableViewCell()
        }
        
        if indexPath.row < histories.count {
            let history = histories[indexPath.row]
            cell.configure(with: history)
            
            cell.onRequestAlert = { [weak self] title, message in
                self?.showAlert(title: title, message: message)
            }
            
            // 마지막 셀에 도달하고 더 많은 페이지가 있는 경우 다음 페이지 로드
            if indexPath.row == histories.count - 1 && !isLastPage && !isLoading {
                loadCommentHistories(page: currentPage + 1)
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < histories.count {
            let selectedHistory = histories[indexPath.row]
            
            // 선택한 기록의 상세 페이지로 이동
            navigateToHistoryDetail(historyId: selectedHistory.historyId)
            print("기록 선택: ID \(selectedHistory.historyId)")
        }
    }
    
    // 기록 상세 페이지로 이동
    private func navigateToHistoryDetail(historyId: Int) {
        let historyService = HistoryService()
        
        historyService.historyDetail(historyId: historyId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                print("히스토리 상세 조회 성공: \(response)")
                
                let detailVC = FriendsCalendarDetailViewController()
                detailVC.setDetailData(response)
                self.navigationController?.pushViewController(detailVC, animated: true)
                
            case .failure(let error):
                print("히스토리 상세 조회 실패: \(error.localizedDescription)")
                self.showAlert(title: "네트워크 오류", message: "인터넷 연결이 원활하지 않아요.\n잠시 후 다시 시도해 주세요.")
            }
        }
    }
}
