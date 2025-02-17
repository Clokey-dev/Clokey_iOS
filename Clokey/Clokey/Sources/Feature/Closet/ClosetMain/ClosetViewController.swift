import UIKit
import SnapKit

final class ClosetViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - Properties
    private let closetView = ClosetView()
    // 서버에서 받아올 옷(제품) 데이터
    private var closetItems: [ClosetModel] = []
    
    // Drawer(폴더) 데이터
    private var drawerItems: [DrawerModel] = []
    private enum SortOption: String {
        case wear = "WEAR"
        case notWear = "NOT_WEAR"
        case latest = "LATEST"
        case oldest = "OLDEST"
        
        static func from(_ text: String) -> SortOption {
            switch text {
            case "착용순": return .wear
            case "미착용순": return .notWear
            case "최신등록순": return .latest
            case "오래된순": return .oldest
            default: return .wear
            }
        }
    }

    private var currentSort: SortOption = .wear

    // API 서비스 인스턴스
    private let folderService = FolderService()
    private let clothesService = ClothesService()
    
    // 카테고리 선택 상태 (메인/서브)
    private var currentMainCategoryId: Int = 0
    private var currentSubCategoryId: Int? = nil
    
    // MARK: - Lifecycle
    override func loadView() {
        view = closetView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupActions()
        setupSegmentedControl()
        
        // 초기 제품 데이터 로드 (첫 번째 세그먼트)
        loadInitialData()
        
        // 폴더 데이터 로드
        loadDrawers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 새로 추가된 폴더가 있을 경우 최신 데이터를 불러옵니다.
        loadDrawers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let initialIndex = closetView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
        closetView.customTotalSegmentView.updateIndicatorPosition(for: initialIndex)
    }
    
    // MARK: - Setup Methods
    private func setupCollectionView() {
        // 옷 데이터 컬렉션
        closetView.collectionView.dataSource = self
        closetView.collectionView.delegate = self
        
        // 폴더(서랍) 컬렉션
        closetView.drawerCollectionView.dataSource = self
        closetView.drawerCollectionView.delegate = self
    }
    
    private func setupActions() {
        // 세그먼트의 menuButton -> 카테고리 추가 화면으로 이동
        closetView.customTotalSegmentView.menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        
        // 전체보기 버튼
        closetView.seeAllButton.addTarget(self, action: #selector(seeAllButtonTapped), for: .touchUpInside)
        
        // 폴더 편집 버튼
        closetView.editDrawerButton.addTarget(self, action: #selector(editDrawerButtonTapped), for: .touchUpInside)
        
        // 배너 버튼 (ArrangeClosetViewController로 이동)
        closetView.banner1.bannerButton.addTarget(self, action: #selector(bannerButtonTapped), for: .touchUpInside)
    }
    
    private func setupSegmentedControl() {
        closetView.customTotalSegmentView.segmentedControl.addTarget(
            self,
            action: #selector(segmentChanged(_:)),
            for: .valueChanged
        )
    }
    
    // MARK: - Actions (버튼)
    @objc private func menuButtonTapped() {
        let categoryVC = AddCategoryViewController()
        navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    @objc private func bannerButtonTapped() {
        let arrangeVC = ArrangeClosetViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(arrangeVC, animated: true)
        } else {
            print("❌ ClosetViewController가 네비게이션 컨트롤러 안에 없음")
        }
    }
    
    @objc private func seeAllButtonTapped() {
        let displayAllVC = DisplayAllViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(displayAllVC, animated: true)
        } else {
            print("❌ ClosetViewController가 네비게이션 컨트롤러 안에 없음")
        }
    }
    
    @objc private func editDrawerButtonTapped() {
        let drawerEditVC = DrawerEditViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(drawerEditVC, animated: true)
        } else {
            print("❌ ClosetViewController가 네비게이션 컨트롤러 안에 없음")
        }
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        closetView.customTotalSegmentView.updateIndicatorPosition(for: index)
        updateContent(for: index)
    }
    
    // MARK: - 데이터 로드
    /// 초기 인덱스에 해당하는 제품 데이터를 로드
    private func loadInitialData() {
        let initialIndex = closetView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
        updateContent(for: initialIndex)
    }
    
    /// 세그먼트 인덱스에 따라 옷 데이터 및 레이아웃 업데이트
    private func updateContent(for index: Int) {
        // 메인 카테고리 설정
        currentMainCategoryId = index
        currentSubCategoryId = nil
        
        if index == 0 {
            // "전체" 선택 시 서브 카테고리 버튼 숨김
            closetView.customTotalSegmentView.toggleCategoryButtons(isHidden: true)
            
            // 레이아웃 재설정
            closetView.collectionView.snp.remakeConstraints { make in
                make.top.equalTo(closetView.customTotalSegmentView.divideLine.snp.bottom).offset(16)
                make.centerX.equalToSuperview()
                make.width.equalTo(353)
                make.height.equalTo(354)
            }
            
            // API로 옷 데이터 로드 (categoryId = 0)
            loadClothesData(categoryId: 0)
        } else if let category = CustomCategoryModel.getCategories(for: index) {
            // 특정 카테고리 선택 시 서브 카테고리 버튼 표시
            closetView.customTotalSegmentView.toggleCategoryButtons(isHidden: false)
            closetView.customTotalSegmentView.updateCategories(for: category.buttons)
            
            closetView.collectionView.snp.remakeConstraints { make in
                make.top.equalTo(closetView.customTotalSegmentView.categoryScrollView.snp.bottom)
                make.centerX.equalToSuperview()
                make.width.equalTo(353)
                make.height.equalTo(354)
            }
            
            // API로 옷 데이터 로드 (categoryId = index)
            loadClothesData(categoryId: index)
        }
    }
    
    /// ClothesService를 통해 옷 목록을 불러옵니다.
    private func loadClothesData(categoryId: Int, season: String = "ALL") {
        clothesService.getClothes(
            clokeyId: nil,
            categoryId: categoryId,
            season: season,
            sort: currentSort.rawValue,
            page: 1,     // 고정된 페이지
            size: 6      // 6개의 cell만 표시
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                // 서버 응답을 ClosetModel 배열로 매핑
                let newItems = response.clothPreviews.map { preview in
                    ClosetModel(
                        id: Int(preview.id),
                        image: preview.imageUrl,
                        count: preview.wearNum,
                        name: preview.name
                    )
                }
                
                self.closetItems = newItems
                
                DispatchQueue.main.async {
                    self.closetView.collectionView.reloadData()
                }
                
            case .failure(let error):
                print("Error loading clothes: \(error)")
            }
        }
    }
    
    // MARK: - Drawer(폴더) API 연동
    private func loadDrawers() {
        folderService.folderAll(page: 1) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let responseDTO):
                    self?.drawerItems = responseDTO.folders.toDrawerItems()
                    self?.closetView.drawerCollectionView.reloadData()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "오류", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == closetView.collectionView {
            return closetItems.count
        } else if collectionView == closetView.drawerCollectionView {
            return drawerItems.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == closetView.collectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CustomCollectionViewCell.identifier,
                for: indexPath
            ) as? CustomCollectionViewCell else {
                fatalError("Unable to dequeue CustomCollectionViewCell")
            }
            let product = closetItems[indexPath.item]
            // Kingfisher를 사용해 URL로부터 이미지 비동기 로드
            if let url = URL(string: product.image) {
                cell.productImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"))
            } else {
                cell.productImageView.image = UIImage(named: "placeholderImage")
            }
            cell.numberLabel.text = "\(indexPath.item + 1)"
            cell.countLabel.text = "\(product.count)회"
            cell.nameLabel.text = product.name
            return cell
        } else if collectionView == closetView.drawerCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DrawerCollectionViewCell.identifier,
                for: indexPath
            ) as? DrawerCollectionViewCell else {
                fatalError("Unable to dequeue DrawerCollectionViewCell")
            }
            let item = drawerItems[indexPath.item]
            if let imageUrl = item.imageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                cell.productImageView.kf.setImage(with: url)
            } else {
                cell.productImageView.image = nil
            }
            cell.folderLabel.text = item.title
            cell.itemCountLabel.text = item.itemCountText
            return cell
        }
        return UICollectionViewCell()
    }
    
    // MARK: - UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == closetView.collectionView {
            let product = closetItems[indexPath.item]
            // 옷 선택 시 팝업 표시
            let popUpVC = PopUpViewController()
            popUpVC.modalPresentationStyle = .overCurrentContext
            popUpVC.modalTransitionStyle = .crossDissolve
            present(popUpVC, animated: true, completion: nil)
        } else if collectionView == closetView.drawerCollectionView {
            let selectedItem = drawerItems[indexPath.item]
            let drawerVC = DrawerViewController(drawerItem: selectedItem)
            navigationController?.pushViewController(drawerVC, animated: true)
        }
    }
}
