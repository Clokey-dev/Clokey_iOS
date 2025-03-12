//
//  LikeHistoryViewController.swift
//  Clokey
//
//  Created by 소민준 on 3/11/25.
//


import UIKit
import SnapKit

class LikeHistoryViewController: UIViewController {
    
    private var likedPosts: [LikedHistoriesResponseDTO.HistoryPreviewDTO] = []
    private let historyService = HistoryService()
    
    // 페이징 관련 변수
    private var currentPage: Int = 1
    private var totalPage: Int = 1
    private var isLoading: Bool = false
    
    private let likeHistoryView = LikeHistoryView()  // 기존 커스텀 뷰 사용
    
    override func loadView() {
        view = likeHistoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        likeHistoryView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        likeHistoryView.collectionView.dataSource = self
        likeHistoryView.collectionView.delegate = self
        
        setupEdgePanGesture()
        fetchLikedPosts(page: 1)
        
        
    
    }
    
    @objc private func backButtonTapped() {
            // 네비게이션 컨트롤러가 없다면 dismiss 처리
            if let nav = navigationController {
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    private func setupEdgePanGesture() {
            let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
            edgePan.edges = .left
            view.addGestureRecognizer(edgePan)
        }
    
    @objc private func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        if gesture.state == .ended && translation.x > 100 {
            if let nav = navigationController {
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    private func fetchLikedPosts(page: Int) {
            guard !isLoading else { return }
            isLoading = true
            
            historyService.likedHistories(page: page) { [weak self] (result: Result<LikedHistoriesResponseDTO, NetworkError>) in
                guard let self = self else { return }
                defer { self.isLoading = false }
                switch result {
                case .success(let response):
                    if page == 1 {
                        self.likedPosts = response.historyPreviews
                    } else {
                        self.likedPosts.append(contentsOf: response.historyPreviews)
                    }
                    self.totalPage = response.totalPage
                    self.currentPage = page
                    DispatchQueue.main.async {
                        self.likeHistoryView.collectionView.reloadData()
                    }
                case .failure(let error):
                    print("❌ 좋아요한 게시물 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    extension LikeHistoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return likedPosts.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LikeHistoryCell.identifier, for: indexPath) as? LikeHistoryCell else {
                return UICollectionViewCell()
            }
            let post = likedPosts[indexPath.item]
            cell.configure(with: post.imageUrl)
            return cell
        }
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let selectedPost = likedPosts[indexPath.item]
            print("선택된 게시물 ID: \(selectedPost.id)")
            
            let detailVC = CalendarDetailViewController()
            detailVC.historyId = selectedPost.id
            
            if let nav = navigationController {
                nav.pushViewController(detailVC, animated: true)
            } else {
                let nav = UINavigationController(rootViewController: detailVC)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true)
            }
        }
        // 페이징: 스크롤이 하단에 도달하면 추가 데이터를 호출
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let height = scrollView.frame.size.height
            
            if offsetY > contentHeight - height - 100 {
                if !isLoading && currentPage < totalPage {
                    fetchLikedPosts(page: currentPage + 1)
                }
            }
        }
    }
