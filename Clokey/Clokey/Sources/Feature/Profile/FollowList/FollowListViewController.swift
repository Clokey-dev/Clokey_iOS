//
//  FollowListViewController.swift
//  Clokey
//
//  Created by 황상환 on 2/2/25.
//

import UIKit
import SnapKit
import Then

enum FollowTabType: Int {
    case follower = 0
    case following = 1
}

class FollowListViewController: UIViewController {
    var selectedTab: FollowTabType = .follower // 기본값: 팔로워
    
    // MARK: - Properties
    private var follwerusers: [FollowerUserModel] = []
    private var followingusers: [FollowingUserModel] = []
    
    // MARK: - UI Components
    private let navigationBar = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "cake123(아이디란)"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = .black
    }
    
    let followerButton = UIButton(type: .system).then {
        $0.setTitle("팔로워(000)", for: .normal)
        $0.setTitleColor(.orange, for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        $0.tag = FollowTabType.follower.rawValue
    }
    
    let followingButton = UIButton(type: .system).then {
        $0.setTitle("팔로잉(000)", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        $0.tag = FollowTabType.following.rawValue
    }
    
    let separatorLine = UIView().then {
        $0.backgroundColor = UIColor(red: 52/255, green: 52/255, blue: 52/255, alpha: 0.5) // 구분선 색상
    }
    
    let indicatorView = UIView().then {
        $0.backgroundColor = .orange
        $0.layer.cornerRadius = 2
    }
    
    let containerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private lazy var followerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(FollowerUserCell.self, forCellWithReuseIdentifier: FollowerUserCell.identifier)
        return collectionView
    }()
    
    private lazy var followingCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(FollowingUserCell.self, forCellWithReuseIdentifier: FollowingUserCell.identifier)
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupCollectionViews()
        loadDummyData()
        
        // 초기 탭 설정
        updateCollectionView(for: selectedTab)
        updateButtonColors(
            selectedButton: selectedTab == .follower ? followerButton : followingButton,
            unselectedButton: selectedTab == .follower ? followingButton : followerButton
        )
        animateIndicator(to: selectedTab == .follower ? followerButton : followingButton)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(navigationBar)
        navigationBar.addSubview(titleLabel)
        navigationBar.addSubview(closeButton)
        view.addSubview(followerButton)
        view.addSubview(followingButton)
        view.addSubview(separatorLine)
        view.addSubview(indicatorView)
        view.addSubview(containerView)
        
        containerView.addSubview(followerCollectionView) // 초기 상태는 팔로워 컬렉션 뷰
        
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        followerButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(navigationBar.snp.bottom).offset(12)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(28)
        }
        
        followingButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(navigationBar.snp.bottom).offset(12)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(28)
        }
        
        separatorLine.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20) // 왼쪽에 20px 여백
            make.trailing.equalToSuperview().inset(20) // 오른쪽에 20px 여백
            make.top.equalTo(followerButton.snp.bottom).offset(4) // 버튼 바로 아래
            make.height.equalTo(0.5) // 높이: 0.5 (얇은 선)
        }
        
        indicatorView.snp.makeConstraints { make in
            make.centerX.equalTo(followerButton)
            make.top.equalTo(followerButton.snp.bottom).offset(2)
            make.width.equalTo(80)
            make.height.equalTo(3)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(indicatorView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        followerCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private func setupActions() {
        followerButton.addTarget(self, action: #selector(followerButtonTapped), for: .touchUpInside)
        followingButton.addTarget(self, action: #selector(followingButtonTapped), for: .touchUpInside)
    }
    
    private func setupCollectionViews() {
        followerCollectionView.dataSource = self
        followerCollectionView.delegate = self
        followingCollectionView.dataSource = self
        followingCollectionView.delegate = self
    }
    
    // MARK: - Button Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func followerButtonTapped() {
        updateCollectionView(for: .follower)
        updateButtonColors(selectedButton: followerButton, unselectedButton: followingButton)
        animateIndicator(to: followerButton)
    }
    
    @objc private func followingButtonTapped() {
        updateCollectionView(for: .following)
        updateButtonColors(selectedButton: followingButton, unselectedButton: followerButton)
        animateIndicator(to: followingButton)
    }
    
    private func updateButtonColors(selectedButton: UIButton, unselectedButton: UIButton) {
        selectedButton.setTitleColor(.orange, for: .normal) // 눌린 버튼: 오렌지색
        unselectedButton.setTitleColor(.gray, for: .normal) // 안 눌린 버튼: 회색
    }
    
    // MARK: - Update Collection View
     func updateCollectionView(for tabType: FollowTabType) {
        followerCollectionView.removeFromSuperview()
        followingCollectionView.removeFromSuperview()
        
        switch tabType {
        case .follower:
            containerView.addSubview(followerCollectionView)
            followerCollectionView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            followerCollectionView.reloadData()
        case .following:
            containerView.addSubview(followingCollectionView)
            followingCollectionView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            followingCollectionView.reloadData()
        }
    }
    
    private func animateIndicator(to button: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.indicatorView.snp.remakeConstraints { make in
                make.centerX.equalTo(button)
                make.top.equalTo(button.snp.bottom).offset(2)
                make.width.equalTo(80)
                make.height.equalTo(3)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func loadDummyData() {
        follwerusers = [
            FollowerUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollower: true),
            FollowerUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollower: false)
                    // Add more dummy data as needed
                ]
        
        followingusers = [
            FollowingUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_123", nickname: "닉네임1", profileImageUrl: "", isFollowing: true),
            FollowingUserModel(userId: "id_456", nickname: "닉네임2", profileImageUrl: "", isFollowing: false)
                    // Add more dummy data as needed
                ]
        
        followerCollectionView.reloadData()
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension FollowListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == followerCollectionView {
            return follwerusers.count
        } else if collectionView == followingCollectionView {
            return followingusers.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == followerCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerUserCell.identifier, for: indexPath) as! FollowerUserCell
            cell.configure(with: follwerusers[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowingUserCell.identifier, for: indexPath) as! FollowingUserCell
            cell.configure(with: followingusers[indexPath.item])
            return cell
        }
    }
}

