import UIKit
import SnapKit
import Kingfisher

// "폴더 상세" 혹은 "드로어 상세" 화면이라고 가정
class DrawerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - UI
    private let drawerView = DrawerView()
    
    // MARK: - API Service
    private let folderService = FolderService()
    
    // MARK: - Data
    // ① 이니셜라이저를 통해 주입받을 DrawerItem (또는 folderId 등)
    private let drawerItem: DrawerModel
    
    // 폴더 안에 들어 있는 옷 목록 (예: FolderClothDTO 배열)
    private var clothItems: [FolderClothDTO] = []
    
    // MARK: - Navigation Bar Button
    private lazy var editButton: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "dot3_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .mainBrown800
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    // MARK: - Initializer
    // ② 이니셜라이저에서 drawerItem을 받아 저장
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
        
        // 예시) drawerItem.id를 folderId로 사용하여 해당 폴더 안의 옷 목록을 불러온다고 가정
        //      만약 drawerItem 자체가 이미 폴더 안의 옷 목록이면, 여기서 별도 API 호출이 필요 없을 수도 있음
        loadFolderClothes(folderId: Int(drawerItem.id), page: 1)
    }
    
    // MARK: - Setup
    private func setupUI() {
        navigationItem.rightBarButtonItem = editButton
        
        let navBarManager = NavigationBarManager()
        navBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        // 폴더명 등 타이틀을 drawerItem에서 가져와도 됨
        navBarManager.setTitle(
            to: navigationItem,
            title: drawerItem.title,
            font: .ptdBoldFont(ofSize: 20),
            textColor: .black
        )
    }
    
    private func setupCollectionView() {
        drawerView.collectionView.dataSource = self
        drawerView.collectionView.delegate = self
    }
    
    // MARK: - API
    private func loadFolderClothes(folderId: Int, page: Int) {
        folderService.folderCheck(folderId: folderId, page: page) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let responseDTO):
                    // FolderCheckResponseDTO -> clothes: [FolderClothDTO]
                    self?.clothItems = responseDTO.clothes
                    self?.drawerView.collectionView.reloadData()
                case .failure(let error):
                    self?.showError(error)
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
        // 탭바 로직은 기존 코드 유지
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 3
            if let closetNav = tabBarController.viewControllers?[3] as? UINavigationController {
                closetNav.popToRootViewController(animated: true)
            }
        } else {
            navigationController?.popToRootViewController(animated: true)
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
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ClosetCollectionViewCell.identifier,
            for: indexPath
        ) as? ClosetCollectionViewCell else {
            fatalError("Unable to dequeue ClosetCollectionViewCell")
        }
        
        let cloth = clothItems[indexPath.item]
        
        // Kingfisher로 이미지 로딩
        if let imageUrl = cloth.imageUrl,
           !imageUrl.isEmpty,
           let url = URL(string: imageUrl) {
            cell.productImageView.kf.setImage(with: url, placeholder: nil)
        } else {
            // "아무 것도 표시하지 않고 싶다" → Kingfisher에 nil 전달
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
