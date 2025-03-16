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
    
    private let commentHistoryView = CommentHistoryView()
    
    // 댓글 데이터 배열
    private var comments: [CommentModel] = []
    
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
        
        // 제스처 인식기 설정
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // 샘플 데이터 로드
        loadSampleData()
        
        // 디버그 로그 추가
        print("viewDidLoad 완료: \(comments.count)개의 댓글 로드됨")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 화면이 나타날 때마다 데이터 리로드
        commentHistoryView.tableView.reloadData()
        print("viewWillAppear: 테이블 뷰 리로드")
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
    
    // 샘플 데이터 로드
    private func loadSampleData() {
        comments = [
            CommentModel(
                id: "1",
                userName: "OO님의 기록",
                date: "20xx.xx.xx",
                content: "이 코디 진짜 이뻐요",
                profileImageUrl: nil
            ),
            CommentModel(
                id: "2",
                userName: "OO님의 기록",
                date: "20xx.xx.xx",
                content: "링링이가 좋아요",
                profileImageUrl: nil
            ),
            CommentModel(
                id: "3",
                userName: "OO님의 기록",
                date: "20xx.xx.xx",
                content: "댓글을 여러 개 남겼을 경우에도 이런 식으로",
                profileImageUrl: nil
            ),
            CommentModel(
                id: "4",
                userName: "OO님의 기록",
                date: "20xx.xx.xx",
                content: "금자 좋아가 최고임 덕에가는 경험이...",
                profileImageUrl: nil
            )
        ]
        
        // 메인 스레드에서 UI 업데이트 (안전하게)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.commentHistoryView.tableView.reloadData()
            print("loadSampleData: 데이터 로드됨 - \(self.comments.count)개 항목")
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection 호출: \(comments.count)개 항목")
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt 호출: row \(indexPath.row)")
        
        // 셀 등록 확인
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentHistoryCell", for: indexPath) as? CommentHistoryCell else {
            print("CommentHistoryCell 등록 실패")
            return UITableViewCell()
        }
        
        // 안전한 인덱스 검사
        if indexPath.row < comments.count {
            let comment = comments[indexPath.row]
            cell.configure(with: comment)
            print("셀 구성 완료: \(comment.content)")
        } else {
            print("잘못된 인덱스: \(indexPath.row), 댓글 수: \(comments.count)")
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 댓글 클릭 시 해당 게시물로 이동하는 등의 동작 추가 가능
        if indexPath.row < comments.count {
            print("댓글 선택: \(comments[indexPath.row].content)")
        }
    }
    
    // 테이블 뷰의 높이를 명시적으로 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // 스와이프 액션 - 삭제 기능 (필요 시 구현)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            // 서버에 삭제 요청 후 성공 시 로컬 데이터 업데이트
            if indexPath.row < self.comments.count {
                self.comments.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
