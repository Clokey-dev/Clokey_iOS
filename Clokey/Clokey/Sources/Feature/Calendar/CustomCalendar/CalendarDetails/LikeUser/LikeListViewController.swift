//
//  LikeListViewController.swift
//  Clokey
//
//  Created by 황상환 on 2/2/25.
//

import Foundation
import UIKit
import SnapKit
import Then
import Kingfisher

class LikeListViewController: UIViewController {
    
    // MARK: - Properties
    private var users: [LikeUserModel] = []
    
    private let historyId: Int
    private let historyService = HistoryService()
    
    // MARK: - Initializer
    init(historyId: Int) {
        self.historyId = historyId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    private let navigationBar = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "좋아요"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .black
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(LikeUserCell.self, forCellWithReuseIdentifier: LikeUserCell.identifier)
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        // TODO: Fetch like users data
        loadDummyData()
        fetchLikeUsers()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(navigationBar)
        navigationBar.addSubview(titleLabel)
        navigationBar.addSubview(closeButton)
        view.addSubview(collectionView)
        
        navigationBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - Method
    private func fetchLikeUsers() {
        historyService.historyLikeList(historyId: historyId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                // DTO를 Model로 변환
                self.users = response.likedUsers.map { like in
                    LikeUserModel(
                        userId: like.clokeyId,
                        nickname: like.nickname,
                        profileImageUrl: like.imageUrl,
                        isFollowing: like.followStatus
                    )
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print("좋아요 목록 조회 에러: \(error.localizedDescription)")
            }
        }
    }


    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Data
    private func loadDummyData() {
        // 테스트용 더미 데이터
        users = [
            LikeUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: false),
            LikeUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            LikeUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: false),
            LikeUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            LikeUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: false),
            LikeUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            LikeUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: false),
            LikeUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            LikeUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: false),
            LikeUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            LikeUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: false),
            LikeUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            LikeUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: false),
            LikeUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            LikeUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: false),
            LikeUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            LikeUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: false),
            LikeUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            LikeUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: false),
            LikeUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true)
            // Add more dummy data as needed
        ]
        collectionView.reloadData()
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension LikeListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LikeUserCell.identifier, for: indexPath) as! LikeUserCell
        cell.configure(with: users[indexPath.item])
        cell.followButton.tag = indexPath.item
        cell.followButton.addTarget(self, action: #selector(followButtonTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc private func followButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        users[index].isFollowing.toggle()
        
        if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? LikeUserCell {
            cell.updateFollowButton(isFollowing: users[index].isFollowing)
        }
        
        // TODO: API 호출
    }
}
