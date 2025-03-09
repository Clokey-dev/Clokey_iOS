import UIKit
import SnapKit
import Kingfisher

// "폴더 상세" 혹은 "드로어 상세" 화면이라고 가정
class DrawerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - UI
    private let drawerView = DrawerView()
    
    // MARK: - API Service
    private let folderService = FolderService()
    private let clothesService = ClothesService()
    
    // MARK: - Data
    // ① 이니셜라이저를 통해 주입받을 DrawerItem (또는 folderId 등)
    private let drawerItem: DrawerModel
    
    // 폴더 안에 들어 있는 옷 목록 (예: FolderClothDTO 배열)
    private var clothItems: [FolderClothDTO] = []
    
    // 페이징 관련 변수
    private var currentPage = 1
    private let pageSize = 12
    private var isLoading = false
    private var hasMorePages = true
    
    // MARK: - Navigation Bar Button
    private lazy var editButton: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "dot3_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .mainBrown800
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 24),
            button.heightAnchor.constraint(equalToConstant: 24)
        ])
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    // MARK: - Initializer
    init(drawerItem: DrawerModel) {
        self.drawerItem = drawerItem
        super.init(nibName: nil, bundle: nil)
    }
    
    // 스토리보드 사용하지 않을 때 필수
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = drawerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        loadFolderClothes(folderId: Int(drawerItem.id), isNextPage: false)
        
        // 기본 interactive pop 제스처 비활성화
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        // 커스텀 왼쪽 엣지 스와이프 제스처 추가
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
        edgePanGesture.edges = .left
        view.addGestureRecognizer(edgePanGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationItem.rightBarButtonItem = editButton
        
        let navBarManager = NavigationBarManager()
        navBarManager.addBackButton(to: navigationItem, target: self, action: #selector(backButtonTapped))
        navBarManager.setTitle(to: navigationItem,
                               title: drawerItem.title,
                               font: .ptdBoldFont(ofSize: 20),
                               textColor: .black)
    }
    
    private func setupCollectionView() {
        drawerView.collectionView.dataSource = self
        drawerView.collectionView.delegate = self
    }
    
    // MARK: - API
    private func loadFolderClothes(folderId: Int, isNextPage: Bool = false) {
        // 로딩 중이거나, 다음 페이지 요청 시 추가 데이터가 없으면 진행하지 않음
        guard !isLoading && (hasMorePages || !isNextPage) else { return }
        isLoading = true
        let pageToLoad = isNextPage ? currentPage + 1 : 1
        
        folderService.folderCheck(folderId: folderId, page: pageToLoad) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let responseDTO):
                    let newItems = responseDTO.clothes
                    if isNextPage {
                        self.clothItems.append(contentsOf: newItems)
                        self.currentPage = pageToLoad
                    } else {
                        self.clothItems = newItems
                        self.currentPage = 1
                    }
                    // 새로 받아온 아이템 개수가 pageSize 이상이면 다음 페이지 존재
                    self.hasMorePages = newItems.count >= self.pageSize
                    self.drawerView.collectionView.reloadData()
                case .failure(let error):
                    self.showError(error)
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func editButtonTapped() {
        guard let navController = navigationController else { return }
        let dropdownTop = navController.navigationBar.frame.maxY + 5
        let dropdownVC = FolderDropDownViewController()
        dropdownVC.dropdownTop = dropdownTop
        dropdownVC.parentNav = navController
        dropdownVC.modalPresentationStyle = .overCurrentContext
        dropdownVC.modalTransitionStyle = .crossDissolve
        present(dropdownVC, animated: true, completion: nil)
        dropdownVC.folderId = Int64(drawerItem.id)
    }
    
    @objc func backButtonTapped() {
        // backButtonTapped에서의 커스텀 뒤로가기 동작 (예: tabBarController에서 특정 탭 선택 후 pop)
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 3
            if let closetNav = tabBarController.viewControllers?[3] as? UINavigationController {
                closetNav.popToRootViewController(animated: true)
            }
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc private func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        // 스와이프 제스처가 끝났을 때 backButtonTapped 호출
        if gesture.state == .ended {
            backButtonTapped()
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "오류", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clothItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClosetCollectionViewCell.identifier, for: indexPath) as? ClosetCollectionViewCell else {
            fatalError("Unable to dequeue ClosetCollectionViewCell")
        }
        
        let cloth = clothItems[indexPath.item]
        if let imageUrl = cloth.imageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            cell.productImageView.kf.setImage(with: url, placeholder: nil)
        } else {
            cell.productImageView.image = nil
        }
        
        cell.nameLabel.text = cloth.clothName
        cell.countLabel.text = "\(cloth.clothCount)회"
        cell.numberLabel.isHidden = true
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cloth = clothItems[indexPath.item]
        print("Selected cloth: \(cloth.clothName)")
    }
}

// MARK: - UIScrollViewDelegate
extension DrawerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height
        // 스크롤이 바닥에 가까워지면 다음 페이지 로드
        if offsetY > contentHeight - screenHeight - 100 {
            loadFolderClothes(folderId: Int(drawerItem.id), isNextPage: true)
        }
    }
}
