//
//  FollowListViewController.swift
//  Clokey
//
//  Created by 황상환 on 2/2/25.
//

import UIKit
import SnapKit
import Then

enum YourFollowTabType: Int {
    case follower = 0
    case following = 1
}

class YourFollowListViewController: UIViewController, UIGestureRecognizerDelegate {
    private let navBarManager = NavigationBarManager()
    
    var selectedTab: YourFollowTabType = .follower // 기본값: 팔로워
    
    var clokeyId: String = ""
    var followerCount: Int = 0
    var followingCount: Int = 0
    
    // MARK: - Properties
    private var followerusers: [YourFollowerUserModel] = []
    private var followingusers: [YourFollowingUserModel] = []
    
    private var currentPage = 1
    private var isLoading = false
    private var hasMorePages = true
    
    private var currentPage1 = 1
    private var isLoading1 = false
    private var hasMorePages1 = true
    
    private let refreshControl = UIRefreshControl()
    
   
    
    let followerButton = UIButton(type: .system).then {
        $0.setTitle("팔로워(000)", for: .normal)
        $0.setTitleColor(.orange, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.tag = YourFollowTabType.follower.rawValue
    }
    
    let followingButton = UIButton(type: .system).then {
        $0.setTitle("팔로잉(000)", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.tag = YourFollowTabType.following.rawValue
    }
    
    let separatorLine = UIView().then {
        $0.backgroundColor = UIColor(red: 52/255, green: 52/255, blue: 52/255, alpha: 0.5) // 구분선 색상
    }
    
    let indicatorView = UIView().then {
        $0.backgroundColor = .orange
        $0.layer.cornerRadius = 2
    }
    
    private let scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true // 내용이 짧아도 당김 효과
    }

    private let contentView = UIView().then {
        $0.backgroundColor = .white
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
        collectionView.register(YourFollowerUserCell.self, forCellWithReuseIdentifier: YourFollowerUserCell.identifier)
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
        collectionView.register(YourFollowingUserCell.self, forCellWithReuseIdentifier: YourFollowingUserCell.identifier)
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupActions()
        setupCollectionViews()
        loadFollowerData()
//        loadFollowingData()
        
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        
        // 초기 탭 설정
        updateCollectionView(for: selectedTab)
        updateButtonColors(
            selectedButton: selectedTab == .follower ? followerButton : followingButton,
            unselectedButton: selectedTab == .follower ? followingButton : followerButton
        )
        animateIndicator(to: selectedTab == .follower ? followerButton : followingButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadFollowerData()
        loadFollowingData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // 네비게이션 설정
        private func setupNavigationBar() {
            navBarManager.addBackButton(
                to: navigationItem,
                target: self,
                action: #selector(didTapBackButton)
            )
            
            navBarManager.setTitle(
                to: navigationItem,
                title: clokeyId,
                font: .ptdSemiBoldFont(ofSize: 20),
                textColor: .black
            )
        }
        
        // 뒤로가기
        @objc private func didTapBackButton() {
            navigationController?.popViewController(animated: true)
        }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(followerButton)
        view.addSubview(followingButton)
        view.addSubview(separatorLine)
        view.addSubview(indicatorView)
//        view.addSubview(containerView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
     contentView.addSubview(containerView)
        
        containerView.addSubview(followerCollectionView) // 초기 상태는 팔로워 컬렉션 뷰
        
        
        followerButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(28)
        }
        
        followingButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
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
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(indicatorView.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        // contentView는 scrollView 내부의 컨텐츠 영역으로, 스크롤뷰의 모든 폭을 채우도록 설정
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.greaterThanOrEqualTo(scrollView.snp.height)
        }
        
        containerView.snp.makeConstraints {
//            $0.top.equalTo(indicatorView.snp.bottom).offset(8)
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        followerCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func setupActions() {
        followerButton.addTarget(self, action: #selector(followerButtonTapped), for: .touchUpInside)
        followingButton.addTarget(self, action: #selector(followingButtonTapped), for: .touchUpInside)
    }
    
    private func setupCollectionViews() {
        followerCollectionView.dataSource = self
        followerCollectionView.delegate = self
//        followerCollectionView.refreshControl = refreshControl
        
        followingCollectionView.dataSource = self
        followingCollectionView.delegate = self
//        followingCollectionView.refreshControl = refreshControl
    }
    
    @objc private func followerButtonTapped() {
        updateCollectionView(for: .follower)
        updateButtonColors(selectedButton: followerButton, unselectedButton: followingButton)
        animateIndicator(to: followerButton)
        
        loadFollowerData()
    }
    
    @objc private func followingButtonTapped() {
        updateCollectionView(for: .following)
        updateButtonColors(selectedButton: followingButton, unselectedButton: followerButton)
        animateIndicator(to: followingButton)
        
        loadFollowingData()
    }
    
    private func updateButtonColors(selectedButton: UIButton, unselectedButton: UIButton) {
        selectedButton.setTitleColor(.orange, for: .normal) // 눌린 버튼: 오렌지색
        unselectedButton.setTitleColor(.gray, for: .normal) // 안 눌린 버튼: 회색
    }
    
    // MARK: - Update Collection View
     func updateCollectionView(for tabType: YourFollowTabType) {
        followerCollectionView.removeFromSuperview()
        followingCollectionView.removeFromSuperview()
        
        switch tabType {
        case .follower:
            containerView.addSubview(followerCollectionView)
            followerCollectionView.snp.remakeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(1)
            }
            followerCollectionView.reloadData()
            loadFollowerData()
        case .following:
            containerView.addSubview(followingCollectionView)
            followingCollectionView.snp.remakeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(1)
            }
            followingCollectionView.reloadData()
            loadFollowingData()
        }
    }
    
    private func animateIndicator(to button: UIButton) {
        UIView.animate(withDuration: 0.1) {
            self.indicatorView.snp.remakeConstraints { make in
                make.centerX.equalTo(button)
                make.top.equalTo(button.snp.bottom).offset(2)
                make.width.equalTo(80)
                make.height.equalTo(3)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    
    private func loadFollowerData(isNextPage: Bool = false) {
        guard !isLoading && (hasMorePages || !isNextPage) else { return }
        isLoading = true
        let nextPage = isNextPage ? currentPage + 1 : 1
        
        let clokeyId = clokeyId // 실제 로그인한 사용자의 ID로 변경해야 함
        let isFollowing = false // false면 팔로워 리스트를 가져옴

        let membersService = MembersService()

        membersService.getFollowPeople(clokeyId: clokeyId, page: nextPage, isFollowing: isFollowing) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let newResult: [YourFollowerUserModel] = response.members.compactMap { item -> YourFollowerUserModel? in
                    return YourFollowerUserModel(
                        userId: item.clokeyId,
                        nickname: item.nickname,
                        profileImageUrl: item.profileImage,
                        isFollowing: item.isFollowed,
                        isMe: item.isMe
                    )
                }
                
                
                
                if isNextPage {
                    self.followerusers.append(contentsOf: newResult)
                    self.currentPage = nextPage
                } else {
                    self.followerusers = newResult
                    self.currentPage = 1
                }

                self.hasMorePages = !newResult.isEmpty
                
                DispatchQueue.main.async {
                    self.followerCount = self.followerusers.count
                    self.followerButton.setTitle("팔로워(\(self.followerCount))", for: .normal)
                    
                    self.followerCollectionView.reloadData()
                    self.updateFollowerCollectionViewHeight()
                }
            case .failure(let error):
                print("🚨 팔로워 데이터 가져오기 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateFollowerCollectionViewHeight() {
        followerCollectionView.layoutIfNeeded()
        let contentHeight = followerCollectionView.contentSize.height
        print("Content Height: \(contentHeight)") // 디버깅용 출력
        
        followerCollectionView.snp.updateConstraints { make in
            make.height.equalTo(contentHeight)
        }
    }
    
    private func loadFollowingData(isNextPage1: Bool = false) {
        guard !isLoading1 && (hasMorePages1 || !isNextPage1) else { return }
        isLoading1 = true
        let nextPage1 = isNextPage1 ? currentPage1 + 1 : 1
        
        let clokeyId = clokeyId // 실제 로그인한 사용자의 ID로 변경해야 함
        let isFollowing = true // true면 팔로잉 리스트를 가져옴

        let membersService = MembersService()

        membersService.getFollowPeople(clokeyId: clokeyId, page: nextPage1, isFollowing: isFollowing) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let newResult: [YourFollowingUserModel] = response.members.compactMap { item -> YourFollowingUserModel? in
                    return YourFollowingUserModel(
                        userId: item.clokeyId,
                        nickname: item.nickname,
                        profileImageUrl: item.profileImage,
                        isFollowing: item.isFollowed,
                        isMe: item.isMe
                    )
                }
                
                if isNextPage1 {
                    self.followingusers.append(contentsOf: newResult)
                    self.currentPage1 = nextPage1
                } else {
                    self.followingusers = newResult
                    self.currentPage1 = 1
                }

                self.hasMorePages1 = !newResult.isEmpty
                
                DispatchQueue.main.async {
                    self.followingCount = self.followingusers.count
                    self.followingButton.setTitle("팔로잉(\(self.followingCount))", for: .normal)
                    
                    self.followingCollectionView.reloadData()
                    self.updateFollowingCollectionViewHeight()
                }
            case .failure(let error):
                print("🚨 팔로워 데이터 가져오기 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateFollowingCollectionViewHeight() {
        followingCollectionView.layoutIfNeeded()
        let contentHeight = max(followingCollectionView.contentSize.height, 1)
        print("Content Height: \(contentHeight)") // 디버깅용 출력
        
        followingCollectionView.snp.updateConstraints { make in
            make.height.equalTo(contentHeight)
        }
    }
    
    @objc private func didPullToRefresh() {
        loadFollowerData()
        loadFollowingData()
        
        // 풀투리프레시 종료 (약간의 딜레이 후)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshControl.endRefreshing()
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension YourFollowListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == followerCollectionView {
            return followerusers.count
        } else if collectionView == followingCollectionView {
            return followingusers.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == followerCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YourFollowerUserCell.identifier, for: indexPath) as! YourFollowerUserCell
            cell.configure(with: followerusers[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YourFollowingUserCell.identifier, for: indexPath) as! YourFollowingUserCell
            cell.configure(with: followingusers[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == followerCollectionView {
            let selectedUser = followerusers[indexPath.item]
            print("팔로워 선택됨: \(selectedUser.nickname)")
            
            let followProfileVC = FollowProfileViewController(followId: selectedUser.userId)
            followProfileVC.isMe = selectedUser.isMe
            navigationController?.pushViewController(followProfileVC, animated: false)
        } else if collectionView == followingCollectionView {
            let selectedUser = followingusers[indexPath.item]
            print("팔로잉 선택됨: \(selectedUser.nickname)")
            
            let followProfileVC = FollowProfileViewController(followId: selectedUser.userId)
            followProfileVC.isMe = selectedUser.isMe
            navigationController?.pushViewController(followProfileVC, animated: false)
        }
    }
    
}

