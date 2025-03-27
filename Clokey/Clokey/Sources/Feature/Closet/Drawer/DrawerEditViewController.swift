import UIKit
import SnapKit

// MARK: - Protocol
protocol DrawerEditViewControllerDelegate: AnyObject {
    func didSelectTags(_ tags: [(id: Int, image: UIImage, title: String)])
}

// MARK: - DrawerEditViewController
class DrawerEditViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Types
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
    
    // MARK: - Properties
    /// 폴더 ID (편집 시 사용). 새 폴더 생성 시에는 nil
    private var folderId: Int64?
    
    /// 선택된 아이템 배열 (cloth id, image, title)
    private var selectedItems: [(id: Int, image: UIImage, title: String)] = [] {
        didSet {
            updateCompleteButtonState()
        }
    }
    
    /// 정렬 옵션 (기본값 착용순)
    private var currentSort: SortOption = .wear
    
    /// 카테고리 선택 상태
    private var currentMainCategoryId: Int = 0
    private var currentSubCategoryId: Int? = nil
    
    /// 제품 데이터: API를 통해 받아올 옷 목록
    private var products: [ClosetModel] = []
    private var originalClothItems: [ClosetModel] = []
    
    // 페이징 관련 변수
    private var currentPage = 1
    private let pageSize = 12
    private var isLoading = false
    private var hasMorePages = true
    
    //편집하기 눌렀을 때 넘길 옷 목록
    private var preselectedItems: [(id: Int, image: UIImage, title: String)] = []

    
    // Delegate
    weak var delegate: DrawerEditViewControllerDelegate?
    
    // DrawerEditView (커스텀 뷰)
    private let drawerEditView = DrawerEditView()
    
    // 확인(완료) 버튼
    private lazy var completeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(completeButtonTapped))
        button.isEnabled = false
        button.tintColor = .clear
        return button
    }()
    
    // API 서비스 (옷 데이터)
    private let clothesService = ClothesService()
    
    // MARK: - Initializer
    init(folderId: Int64? = nil, preselectedItems: [(id: Int, image: UIImage, title: String)] = []) {
        self.folderId = folderId
        self.preselectedItems = preselectedItems
        self.selectedItems = preselectedItems
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = drawerEditView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInitialSetup()
        // Delegate 설정 (카테고리, 정렬 관련)
        drawerEditView.customTotalSegmentView.delegate = self
        drawerEditView.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)

        // 현재 세그먼트 인덱스 확인
        let selectedIndex = drawerEditView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
        
        // 전체(인덱스 0)인지 여부에 따라 forTotal 결정
        let isTotal = (selectedIndex == 0)
        
        // 이미 데이터는 로드되어 있을 것이므로, 제약만 다시 설정
        updateContentViewConstraints(forTotal: isTotal)
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 초기 인디케이터 위치 업데이트 필요 시 추가
    }
    
    // MARK: - 초기 설정
    private func configureInitialSetup() {
        setupUI()
        setupCollectionView()
        setupSegmentedControl()
        // 초기 데이터 로드 (전체 카테고리, 인덱스 0)
        DispatchQueue.main.async {
            self.updateContent(for: 0)
        }
    }
    
    private func setupUI() {
        navigationItem.rightBarButtonItem = completeButton
        
        let navBarManager = NavigationBarManager()
        navBarManager.addBackButton(to: navigationItem, target: self, action: #selector(backButtonTapped))
        navBarManager.setTitle(to: navigationItem, title: "아이템 선택하기", font: .ptdBoldFont(ofSize: 20), textColor: .black)
    }
    
    private func setupCollectionView() {
        drawerEditView.collectionView.dataSource = self
        drawerEditView.collectionView.delegate = self
        drawerEditView.collectionView.register(CustomCollectionViewCell.self,
                                               forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        drawerEditView.collectionView.allowsMultipleSelection = true
    }
    
    private func setupSegmentedControl() {
        let segmentedControl = drawerEditView.customTotalSegmentView.segmentedControl
        segmentedControl.addTarget(
            self,
            action: #selector(segmentChanged(_:)),
            for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0 // 기본은 전체 카테고리
    }
    
    // MARK: - 데이터 로드 및 업데이트
    private func loadInitialData() {
        let initialIndex = drawerEditView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
        updateContent(for: initialIndex)
    }
    
    private func updateContent(for index: Int) {
        if index == 0 {
            handleTotalCategorySelection()
        } else {
            handleSpecificCategorySelection(index)
        }
    }
    
    private func handleTotalCategorySelection() {
        loadClothesData(categoryId: 0)
        drawerEditView.customTotalSegmentView.toggleCategoryButtons(isHidden: true)
        updateContentViewConstraints(forTotal: true)
    }
    
    private func handleSpecificCategorySelection(_ index: Int) {
        guard let category = CustomCategoryModel.getCategories(for: index) else { return }
        loadClothesData(categoryId: index)
        drawerEditView.customTotalSegmentView.toggleCategoryButtons(isHidden: false)
        drawerEditView.customTotalSegmentView.updateCategories(for: category.buttons)
        updateContentViewConstraints(forTotal: false)
    }
    
    private func updateContentViewConstraints(forTotal: Bool) {
        drawerEditView.contentView.snp.remakeConstraints { make in
            if forTotal {
                make.top.equalTo(drawerEditView.customTotalSegmentView.divideLine.snp.bottom).offset(10)
            } else {
                make.top.equalTo(drawerEditView.customTotalSegmentView.categoryScrollView.snp.bottom)
            }
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
        
    }
    
    private func loadClothesData(categoryId: Int, isNextPage: Bool = false, season: String = "ALL") {
        // 현재 로딩 중이 아니며, 다음 페이지 요청일 경우 추가 데이터가 있어야 진행
        guard !isLoading && (hasMorePages || !isNextPage) else { return }
        isLoading = true
        let page = isNextPage ? currentPage + 1 : 1

        clothesService.getClothes(
            clokeyId: nil,
            categoryId: categoryId,
            season: season,
            sort: currentSort.rawValue,
            page: page,
            size: pageSize
        ) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
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
                
                if isNextPage {
                    self.originalClothItems.append(contentsOf: newItems)
                    self.products.append(contentsOf: newItems)
                    self.currentPage = page
                } else {
                    self.originalClothItems = newItems
                    self.products = newItems
                    self.currentPage = 1
                }
                
                // 응답받은 아이템 개수가 pageSize 이상이면 더 불러올 페이지가 있다고 판단
                self.hasMorePages = newItems.count >= self.pageSize
                
                DispatchQueue.main.async {
                    self.drawerEditView.collectionView.reloadData()
                    // 기존에 선택된 아이템 복원
                    for (idx, product) in self.products.enumerated() {
                        if self.selectedItems.contains(where: { $0.title == product.name }) {
                            let indexPath = IndexPath(item: idx, section: 0)
                            self.drawerEditView.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                        }
                    }
                }
            case .failure(let error):
                print("Error loading clothes: \(error)")
            }
        }
    }
    
    // MARK: - Button State
    private func updateCompleteButtonState() {
        completeButton.isEnabled = !selectedItems.isEmpty
        completeButton.tintColor = selectedItems.isEmpty ? .clear : UIColor(named: "pointOrange800")
    }
    
    // MARK: - Actions
    @objc private func completeButtonTapped() {
        let selectedData = selectedItems.map { (id: $0.id, image: $0.image, title: $0.title) }
        delegate?.didSelectTags(selectedData)
        
        let selectedClothes = products.filter { product in
            selectedItems.contains(where: { $0.id == product.id })
        }
        
        let drawerInfoVC = DrawerInfoViewController(folderId: folderId, selectedClothes: selectedClothes)
        navigationController?.pushViewController(drawerInfoVC, animated: true)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        drawerEditView.customTotalSegmentView.updateIndicatorPosition(for: index)
        updateContent(for: index)
    }
    
    @objc private func menuButtonTapped() {
        let categoryVC = AddCategoryViewController()
        navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    // MARK: - UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CustomCollectionViewCell.identifier,
            for: indexPath
        ) as? CustomCollectionViewCell else {
            fatalError("Unable to dequeue CustomCollectionViewCell")
        }
        
        let product = products[indexPath.item]
        if let url = URL(string: product.image) {
            cell.productImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"))
        } else {
            cell.productImageView.image = UIImage(named: "placeholderImage")
        }
        cell.numberLabel.text = "\(indexPath.item + 1)"
        cell.countLabel.text = "\(product.count)회"
        cell.nameLabel.text = product.name
        cell.isSelectable = true
        let isSelected = selectedItems.contains(where: { $0.title == product.name })
        cell.setSelected(isSelected)
        
        return cell
    }
    
    // MARK: - UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleItemSelection(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        handleItemDeselection(at: indexPath)
    }
    
    private func handleItemSelection(at indexPath: IndexPath) {
        guard let cell = drawerEditView.collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell else { return }
        let product = products[indexPath.item]
        cell.setSelected(true)
        if let currentImage = cell.productImageView.image {
            selectedItems.append((id: product.id, image: currentImage, title: product.name))
        }
    }
    
    private func handleItemDeselection(at indexPath: IndexPath) {
        guard let cell = drawerEditView.collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell else { return }
        let product = products[indexPath.item]
        cell.setSelected(false)
        selectedItems.removeAll { $0.title == product.name }
    }
}

// MARK: - SortDropdownViewDelegate
extension DrawerEditViewController: SortDropdownViewDelegate {
    func didSelectSortOption(_ option: String) {
        currentSort = SortOption.from(option)
        drawerEditView.sortButtonLabel.text = option
        let categoryId = currentSubCategoryId ?? currentMainCategoryId
        loadClothesData(categoryId: categoryId, isNextPage: false)
    }
}

extension DrawerEditViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.height
        if offsetY > contentHeight - screenHeight - 100 {
            loadClothesData(categoryId: drawerEditView.customTotalSegmentView.segmentedControl.selectedSegmentIndex, isNextPage: true)
        }
    }
}

// MARK: - CustomTotalSegmentViewDelegate
extension DrawerEditViewController: CustomTotalSegmentViewDelegate {
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
extension DrawerEditViewController: AddCategoryViewControllerDelegate {
    func didSelectCategory(_ categoryId: Int64, season: String?) {
        currentSubCategoryId = Int(categoryId)
        for mainIndex in 1...4 {
            if let categoryModel = CustomCategoryModel.getCategories(for: mainIndex),
               categoryModel.buttons.contains(where: { $0.categoryId == categoryId }) {
                let currentIndex = drawerEditView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
                if currentIndex == 0 {
                    // "전체" 상태에서 특정 카테고리로 전환하면 레이아웃을 서브 카테고리용으로 재설정
                    drawerEditView.collectionView.snp.remakeConstraints { make in
                        make.top.equalTo(drawerEditView.customTotalSegmentView.categoryScrollView.snp.bottom)
                        make.leading.trailing.equalToSuperview()
                        make.bottom.equalToSuperview()
                    }
                }
                drawerEditView.customTotalSegmentView.segmentedControl.selectedSegmentIndex = mainIndex
                drawerEditView.customTotalSegmentView.updateIndicatorPosition(for: mainIndex)
                currentMainCategoryId = mainIndex
                drawerEditView.customTotalSegmentView.toggleCategoryButtons(isHidden: false)
                drawerEditView.customTotalSegmentView.updateCategories(for: categoryModel.buttons)
                for (buttonIndex, button) in categoryModel.buttons.enumerated() {
                    if button.categoryId == categoryId,
                       let buttonView = drawerEditView.customTotalSegmentView.categoryButtonStackView.arrangedSubviews[buttonIndex] as? UIButton {
                        drawerEditView.customTotalSegmentView.selectedCategoryButton = buttonView
                        drawerEditView.customTotalSegmentView.updateButtonAppearance()
                        break
                    }
                }
                break
            }
        }
        loadClothesData(categoryId: Int(categoryId), isNextPage: false, season: season ?? "ALL")
    }
}
