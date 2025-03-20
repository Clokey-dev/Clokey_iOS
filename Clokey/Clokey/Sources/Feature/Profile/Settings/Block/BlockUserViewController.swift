import UIKit
import SnapKit
import Then

class BlockUserViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    private let navBarManager = NavigationBarManager()
    
    /// 차단된 유저 목록
    private var blockUsers: [BlockUserModel] = []
    var clokeyId: String = ""
    /// 페이징 관련 변수
    private var currentPage = 1
    private var isLoading = false
    private var hasMorePages = true
    
    /// 풀투리프레시
    private let refreshControl = UIRefreshControl()
    
    // MARK: - UI Components
    private lazy var blockCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 60)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.refreshControl = refreshControl
        collectionView.register(BlockUserCell.self, forCellWithReuseIdentifier: BlockUserCell.identifier)
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupCollectionView()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        loadBlockData()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        navBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(didTapBackButton)
        )
        
        navBarManager.setTitle(
            to: navigationItem,
            title: "차단한 계정",
            font: .ptdSemiBoldFont(ofSize: 20),
            textColor: .black
        )
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(blockCollectionView)
        
        blockCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupCollectionView() {
        blockCollectionView.dataSource = self
        blockCollectionView.delegate = self
    }
    
    // MARK: - Data Loading
    private func loadBlockData(isNextPage: Bool = false) {
        guard !isLoading && (hasMorePages || !isNextPage) else { return }
        isLoading = true
        
        let nextPage = isNextPage ? currentPage + 1 : 1
        let membersService = MembersService()
        
        membersService.getBlockMembers(page: nextPage) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let newBlockUsers: [BlockUserModel] = response.members.map { item in
                    return BlockUserModel(
                        userId: item.clokeyId,
                        nickname: item.nickname,
                        profileImageUrl: item.profileImage,
                        isBlocked: true
                    )
                }
                
                if isNextPage {
                    self.blockUsers.append(contentsOf: newBlockUsers)
                    self.currentPage = nextPage
                } else {
                    self.blockUsers = newBlockUsers
                    self.currentPage = 1
                }
                
                self.hasMorePages = !newBlockUsers.isEmpty
                
                DispatchQueue.main.async {
                    self.blockCollectionView.reloadData()
                }
            case .failure(let error):
                print("차단 목록 불러오기 실패: \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }
    
    @objc private func didPullToRefresh() {
        loadBlockData(isNextPage: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - 차단 해제 관련 메서드
    func didTapUnblock(clokeyId: String) {
        let confirmAlert = UIAlertController(
            title: "차단 해제",
            message: "정말 이 사용자의 차단을 해제하시겠습니까?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            print("\(clokeyId) 차단 해제 취소됨")
        }
        
        let confirmAction = UIAlertAction(title: "해제", style: .destructive) { [weak self] _ in
            self?.executeUnblockRequest(clokeyId: clokeyId)
        }
        
        confirmAlert.addAction(cancelAction)
        confirmAlert.addAction(confirmAction)
        
        DispatchQueue.main.async {
            self.present(confirmAlert, animated: true)
        }
    }
    
    private func executeUnblockRequest(clokeyId: String) {
        let membersService = MembersService()
        
        membersService.blockOrUnblock(clokeyId: clokeyId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                print("\(clokeyId) 차단 해제 성공")
                
                let successAlert = UIAlertController(
                    title: "차단 해제 완료",
                    message: "해당 사용자의 차단이 해제되었습니다.",
                    preferredStyle: .alert
                )
                successAlert.addAction(UIAlertAction(title: "확인", style: .default))
                
                DispatchQueue.main.async {
                    self.present(successAlert, animated: true, completion: nil)
                    self.blockUsers.removeAll { $0.userId == clokeyId }
                    self.blockCollectionView.reloadData()
                }
                
            case .failure(let error):
                print("차단 해제 실패: \(error.localizedDescription)")
                
                let failureAlert = UIAlertController(
                    title: "차단 해제 실패",
                    message: "차단 해제 요청을 처리하는 중 오류가 발생했습니다.",
                    preferredStyle: .alert
                )
                failureAlert.addAction(UIAlertAction(title: "확인", style: .default))
                
                DispatchQueue.main.async {
                    self.present(failureAlert, animated: true, completion: nil)
                }
            }
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension BlockUserViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blockUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BlockUserCell.identifier,
            for: indexPath
        ) as! BlockUserCell
        
        let user = blockUsers[indexPath.item]
        
        // configure 셀에 차단 해제 액션 클로저 전달
        cell.configure(with: user) { [weak self] clokeyId in
            self?.didTapUnblock(clokeyId: clokeyId)
        }
        
        return cell
    }
}
