import UIKit
import SnapKit

final class ClosetViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - Properties
    private let closetView = ClosetView()
    
    // 서버에서 받아올 옷(제품) 데이터
    private var closetItems: [ClosetModel] = []
    // Drawer(폴더) 데이터
    private var drawerItems: [DrawerModel] = []
    
    // 정렬 옵션
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
        configureInitialSetup()
        
        // 초기 제품 데이터 로드 (첫 번째 세그먼트)
        loadInitialData()
        // 폴더 데이터 로드
        loadDrawers()
        
        // Delegate 설정 (CustomTotalSegmentViewDelegate 등)
        closetView.customTotalSegmentView.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleClothDeleted),
                                               name: Notification.Name("clothDeleted"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleClothEdit(_:)),
                                               name: Notification.Name("clothEdit"),
                                               object: nil)
    }
    
    // NotificationCenter 콜백
    @objc private func handleClothDeleted() {
        // 옷이 삭제된 뒤, 바로 ClosetViewController 데이터를 다시 불러옴
        loadClothesData(categoryId: currentMainCategoryId)
    }
    
    @objc private func handleClothEdit(_ notification: Notification) {
        //        loadClothesData(categoryId: currentMainCategoryId)
        if let clothIdValue = notification.userInfo?["clothId"] {
            print("clothId value: \(clothIdValue) and its type: \(type(of: clothIdValue))")
        } else {
            print("clothId not found in userInfo")
        }
        
        let addClothVC = AddClothViewController()
        if let clothId = notification.userInfo?["clothId"] as? Int64 {
            print("ClosetViewController received clothId: \(clothId)")
            addClothVC.clothId = Int64(clothId)
        }
        self.navigationController?.pushViewController(addClothVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // 새로 추가된 폴더가 있을 경우 최신 데이터를 불러옵니다.
        loadDrawers()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let selectedIndex = closetView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
        closetView.customTotalSegmentView.updateIndicatorPosition(for: selectedIndex)
    }
    
    // MARK: - 초기 설정
    private func configureInitialSetup() {
        setupNavigationBar()      // 네비게이션 바 설정 (필요하다면)
        setupCollectionView()     // 컬렉션 뷰 설정
        setupSegmentedControl()   // 카테고리 세그먼트 컨트롤 설정
        setupActions()            // 버튼 액션 일괄 등록
    }
    
    private func setupNavigationBar() {
        // 필요시 네비게이션 바 설정 (예: navigationItem.title = "옷장")
    }
    
    private func setupCollectionView() {
        // 옷 데이터 컬렉션
        closetView.collectionView.dataSource = self
        closetView.collectionView.delegate = self
        closetView.collectionView.register(CustomCollectionViewCell.self,
                                           forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        // 폴더(서랍) 컬렉션
        closetView.drawerCollectionView.dataSource = self
        closetView.drawerCollectionView.delegate = self
        closetView.drawerCollectionView.register(DrawerCollectionViewCell.self,
                                                 forCellWithReuseIdentifier: DrawerCollectionViewCell.identifier)
    }
    
    private func setupSegmentedControl() {
        let segmentedControl = closetView.customTotalSegmentView.segmentedControl
        segmentedControl.addTarget(self,
                                   action: #selector(segmentChanged(_:)),
                                   for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0 // 기본은 전체 카테고리
    }
    
    private func setupActions() {
        let actions: [(UIButton, Selector)] = [
            (closetView.seeAllButton, #selector(seeAllButtonTapped)),
            (closetView.editDrawerButton, #selector(editDrawerButtonTapped)),
            (closetView.banner1.bannerButton, #selector(bannerButtonTapped)),
            (closetView.banner2.bannerButton, #selector(bannerButton2Tapped))
        ]
        
        actions.forEach { button, selector in
            button.addTarget(self, action: selector, for: .touchUpInside)
        }
    }
    
    // MARK: - Empty State 업데이트
    private func updateEmptyStates() {
        // 옷(Closet) 컬렉션 뷰의 empty state 설정
        if closetItems.isEmpty {
            let emptyView = EmptyStateView(
                mainMessage: "아직 추가한 옷이 없어요!",
                subMessage: "내 옷장에 옷을 추가해서\n옷을 편리하게 관리해보세요."
            )
            closetView.collectionView.backgroundView = emptyView
        } else {
            closetView.collectionView.backgroundView = nil
        }
        
        // 서랍(Drawer) 컬렉션 뷰의 empty state 설정
        if drawerItems.isEmpty {
            let emptyDrawerView = EmptyStateView(
                mainMessage: "아직 생성한 서랍이 없어요!",
                subMessage: "내 옷장에 있는 옷으로 나만의 서랍을\n만들어 관리해보세요."
            )
            closetView.drawerCollectionView.backgroundView = emptyDrawerView
        } else {
            closetView.drawerCollectionView.backgroundView = nil
        }
    }
    
    // MARK: - 카테고리 선택 로직
    private func loadInitialData() {
        let initialIndex = closetView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
        updateContent(for: initialIndex)
    }
    
    private func updateContent(for index: Int) {
        currentMainCategoryId = index
        currentSubCategoryId = nil
        
        if index == 0 {
            handleTotalCategorySelection()
        } else if let category = CustomCategoryModel.getCategories(for: index) {
            handleSpecificCategorySelection(index, category: category)
        }
    }
    
    private func handleTotalCategorySelection() {
        loadClothesData(categoryId: 0)
        closetView.customTotalSegmentView.toggleCategoryButtons(isHidden: true)
        closetView.collectionView.snp.remakeConstraints { make in
            make.top.equalTo(closetView.customTotalSegmentView.divideLine.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.width.equalTo(353)
            make.height.equalTo(354)
        }
    }
    
    private func handleSpecificCategorySelection(_ index: Int, category: CustomCategoryModel) {
        loadClothesData(categoryId: index)
        closetView.customTotalSegmentView.toggleCategoryButtons(isHidden: false)
        closetView.customTotalSegmentView.updateCategories(for: category.buttons)
        closetView.collectionView.snp.remakeConstraints { make in
            make.top.equalTo(closetView.customTotalSegmentView.categoryScrollView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
            make.width.equalTo(353)
            make.height.equalTo(354)
        }
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        closetView.customTotalSegmentView.updateIndicatorPosition(for: index)
        updateContent(for: index)
    }
    
    // MARK: - API Methods
    private func loadClothesData(categoryId: Int, season: String = "ALL") {
        clothesService.getClothes(
            clokeyId: nil,
            categoryId: categoryId,
            season: season,
            sort: currentSort.rawValue,
            page: 1,
            size: 6
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
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
                    self.updateEmptyStates()
                }
            case .failure(let error):
                print("Error loading clothes: \(error)")
            }
        }
    }
    
    private func loadDrawers() {
        folderService.folderAll(page: 1) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let responseDTO):
                    self?.drawerItems = responseDTO.folders.toDrawerItems()
                    self?.closetView.drawerCollectionView.reloadData()
                    self?.updateEmptyStates()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "오류",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions (버튼)
    @objc private func bannerButtonTapped() {
        let arrangeVC = ArrangeClosetViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(arrangeVC, animated: true)
        } else {
            print("❌ ClosetViewController가 네비게이션 컨트롤러 안에 없음")
        }
    }
    
    @objc private func bannerButton2Tapped() {
        let smartVC = SmartSummationViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(smartVC, animated: true)
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
            let popUpVC = PopUpViewController()
            // closetItems를 ClothPreview 모델 배열로 변환해서 전달 (클래스 이름은 실제 모델에 맞게 변경)
            popUpVC.clothPreviews = closetItems.map { ClothPreview(id: $0.id, name: $0.name, wearNum: $0.count, imageUrl: $0.image) }
            popUpVC.currentIndex = indexPath.item
            popUpVC.clothId = Int64(popUpVC.clothPreviews[indexPath.item].id)
            popUpVC.modalPresentationStyle = .overCurrentContext
            popUpVC.modalTransitionStyle = .crossDissolve
            present(popUpVC, animated: true)
        } else if collectionView == closetView.drawerCollectionView {
            let selectedItem = drawerItems[indexPath.item]
            let drawerVC = DrawerViewController(drawerItem: selectedItem)
            navigationController?.pushViewController(drawerVC, animated: true)
        }
    }
    
}

// MARK: - CustomTotalSegmentViewDelegate
extension ClosetViewController: CustomTotalSegmentViewDelegate {
    func didSelectMainCategory(categoryId: Int) {
        currentMainCategoryId = categoryId
        currentSubCategoryId = nil
        loadClothesData(categoryId: categoryId)
    }
    
    func didSelectSubCategory(categoryId: Int) {
        currentSubCategoryId = categoryId
        loadClothesData(categoryId: categoryId)
    }
    
    func didTapSideBarButton() {
        let addCategoryVC = AddCategoryViewController()
        addCategoryVC.delegate = self
        navigationController?.pushViewController(addCategoryVC, animated: true)
    }
}

// MARK: - AddCategoryViewControllerDelegate
extension ClosetViewController: AddCategoryViewControllerDelegate {
    func didSelectCategory(_ categoryId: Int64, season: String?) {
        currentSubCategoryId = Int(categoryId)
        for mainIndex in 1...4 {
            if let categoryModel = CustomCategoryModel.getCategories(for: mainIndex),
               categoryModel.buttons.contains(where: { $0.categoryId == categoryId }) {
                let currentIndex = closetView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
                if currentIndex == 0 {
                    // "전체" 상태에서 특정 카테고리로 전환하면 레이아웃을 서브 카테고리용으로 재설정
                    closetView.collectionView.snp.remakeConstraints { make in
                        make.top.equalTo(closetView.customTotalSegmentView.categoryScrollView.snp.bottom)
                        make.centerX.equalToSuperview()
                        make.width.equalTo(353)
                        make.height.equalTo(354)
                    }
                }
                closetView.customTotalSegmentView.segmentedControl.selectedSegmentIndex = mainIndex
                closetView.customTotalSegmentView.updateIndicatorPosition(for: mainIndex)
                currentMainCategoryId = mainIndex
                closetView.customTotalSegmentView.toggleCategoryButtons(isHidden: false)
                closetView.customTotalSegmentView.updateCategories(for: categoryModel.buttons)
                for (buttonIndex, button) in categoryModel.buttons.enumerated() {
                    if button.categoryId == categoryId,
                       let buttonView = closetView.customTotalSegmentView.categoryButtonStackView.arrangedSubviews[buttonIndex] as? UIButton {
                        closetView.customTotalSegmentView.selectedCategoryButton = buttonView
                        closetView.customTotalSegmentView.updateButtonAppearance()
                        break
                    }
                }
                break
            }
        }
        loadClothesData(categoryId: Int(categoryId), season: season ?? "ALL")
    }
}
