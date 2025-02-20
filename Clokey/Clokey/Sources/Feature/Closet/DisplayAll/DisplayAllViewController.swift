import UIKit
import SnapKit

class DisplayAllViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    // 스마트요약에서 넘어온 데이터들
    var selectedBaseCategoryName: String?
    var selectedCoreCategoryName: String?
    var selectedCoreCategoryId: Int64?
    var selectedSeason: String?
    
    var clokeyId: String = ""
    
    // MARK: - Properties
    private let displayAllView = DisplayAllView()
    
    // 의류 리스트 - 검색/정렬/필터링에 사용
    var clothItems: [ClosetModel] = []
    // 서버에서 받아온 원본 의류 데이터
    private var originalClothItems: [ClosetModel] = []
    
    // 검색 관련 변수
    private var currentSearchText: String = ""
    
    // 정렬 옵션
    enum SortOption: String {
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
    var currentSort: SortOption = .wear
    
    // API Service
    private let clothesService = ClothesService()
    private let searchService = SearchService()
    
    // 카테고리 선택 상태
    private var currentMainCategoryId: Int = 0
    private var currentSubCategoryId: Int? = nil
    
    // 페이징 관련 변수
    private var currentPage = 1
    private var isLoading = false
    private var hasMorePages = true
    
    // MARK: - Lifecycle
    override func loadView() {
        view = displayAllView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInitialSetup()
        setupKeyboardDismissGestures() // 키보드 제스처 설정
        
        // Delegate 설정
        displayAllView.customTotalSegmentView.delegate = self
        displayAllView.sortDropdownDelegate = self
        
        // 스마트요약에서 전달받은 값이 있다면 viewDidLoad 시점에 UI 업데이트 호출
        if let base = selectedBaseCategoryName,
           let core = selectedCoreCategoryName,
           let coreId = selectedCoreCategoryId {
            didSelectCategory(baseCategoryName: base,
                              coreCategoryName: core,
                              coreCategoryId: coreId,
                              season: selectedSeason)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 필요 시 카테고리 인디케이터 위치 업데이트 (주석 해제)
        // updateInitialIndicatorPosition()
    }
    
    // MARK: - 초기 설정
    private func configureInitialSetup() {
        setupNavigationBar()      // 네비게이션 바 설정
        setupCollectionView()     // 컬렉션 뷰 설정
        setupSegmentedControl()   // 카테고리 세그먼트 컨트롤 설정
        setupSearchField()        // 검색 필드 설정
        
        // 초기 카테고리 데이터 로드 (전체 카테고리, 인덱스 0)
        if currentMainCategoryId == 0 && currentSubCategoryId == nil {
            DispatchQueue.main.async {
                self.updateContent(for: 0)
            }
        }
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        let navBarManager = NavigationBarManager()
        navBarManager.addBackButton(to: navigationItem, target: self, action: #selector(backButtonTapped))
        navBarManager.setTitle(to: navigationItem,
                               title: "내 옷장",
                               font: .ptdBoldFont(ofSize: 20),
                               textColor: .black)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupCollectionView() {
        displayAllView.collectionView.dataSource = self
        displayAllView.collectionView.delegate = self
        displayAllView.collectionView.register(CustomCollectionViewCell.self,
                                               forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
    }
    
    private func setupSegmentedControl() {
        let segmentedControl = displayAllView.customTotalSegmentView.segmentedControl
        segmentedControl.addTarget(self,
                                   action: #selector(segmentChanged(_:)),
                                   for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0 // 기본은 전체 카테고리
    }
    
    private func setupSearchField() {
        displayAllView.searchField.textField.delegate = self
        displayAllView.searchField.textField.addTarget(self,
                                                       action: #selector(searchFieldDidChange(_:)),
                                                       for: .editingChanged)
    }
    
    // MARK: - 데이터 로드 및 업데이트
    private func loadInitialData() {
        let initialIndex = displayAllView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
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
        displayAllView.customTotalSegmentView.toggleCategoryButtons(isHidden: true)
        updateContentViewConstraints(forTotal: true)
    }
    
    private func handleSpecificCategorySelection(_ index: Int) {
        guard let category = CustomCategoryModel.getCategories(for: index) else { return }
        loadClothesData(categoryId: index)
        displayAllView.customTotalSegmentView.toggleCategoryButtons(isHidden: false)
        displayAllView.customTotalSegmentView.updateCategories(for: category.buttons)
        updateContentViewConstraints(forTotal: false)
    }
    
    private func updateContentViewConstraints(forTotal: Bool) {
        displayAllView.contentView.snp.remakeConstraints { make in
            if forTotal {
                make.top.equalTo(displayAllView.customTotalSegmentView.divideLine.snp.bottom).offset(10)
            } else {
                make.top.equalTo(displayAllView.customTotalSegmentView.categoryScrollView.snp.bottom)
            }
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    private func loadClothesData(categoryId: Int = 0,
                                 isNextPage: Bool = false,
                                 season: String = "ALL") {
        guard !isLoading && (hasMorePages || !isNextPage) else { return }
        isLoading = true
        let page = isNextPage ? currentPage + 1 : 1
        
        clothesService.getClothes(
            clokeyId: nil,
            categoryId: categoryId,
            season: season,
            sort: currentSort.rawValue,
            page: page,
            size: 12
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
                    self.currentPage = page
                } else {
                    self.originalClothItems = newItems
                    self.currentPage = 1
                }
                self.hasMorePages = !newItems.isEmpty
                self.filterItems()
            case .failure(let error):
                print("Error loading clothes: \(error)")
            }
        }
    }
    
    // MARK: - 검색 API 호출
    private func searchClothes(keyword: String) {
        guard !keyword.isEmpty else {
            loadInitialData()
            return
        }
        isLoading = true
        searchService.searchClothes(by: "name-and-brand",
                                    keyword: keyword,
                                    page: 1,
                                    size: 12) { [weak self] result in
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
                // 검색 시 기본 정렬 옵션을 '착용순'으로 초기화
                self.currentSort = .wear
                DispatchQueue.main.async {
                    self.displayAllView.sortButtonLabel.text = "착용순"
                    
                    self.currentMainCategoryId = 0
                    self.currentSubCategoryId = nil
                    self.displayAllView.customTotalSegmentView.segmentedControl.selectedSegmentIndex = 0
                    self.displayAllView.customTotalSegmentView.updateIndicatorPosition(for: 0)
                    self.displayAllView.customTotalSegmentView.toggleCategoryButtons(isHidden: true)
                    self.updateContentViewConstraints(forTotal: true)
                    
                    self.originalClothItems = newItems
                    self.clothItems = newItems
                    self.hasMorePages = !newItems.isEmpty
                    self.displayAllView.collectionView.reloadData()
                }
            case .failure(let error):
                print("Search API error: \(error)")
            }
        }
    }
    
    // MARK: - CollectionView DataSource & Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clothItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CustomCollectionViewCell.identifier,
            for: indexPath
        ) as? CustomCollectionViewCell else {
            fatalError("Unable to dequeue CustomCollectionViewCell")
        }
        let product = clothItems[indexPath.item]
        if let url = URL(string: product.image) {
            cell.productImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"))
        } else {
            cell.productImageView.image = UIImage(named: "placeholderImage")
        }
        cell.numberLabel.text = "\(indexPath.item + 1)"
        cell.countLabel.text = "\(product.count)회"
        cell.nameLabel.text = product.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == displayAllView.collectionView {
            let popUpVC = PopUpViewController()
            // closetItems를 ClothPreview 모델 배열로 변환해서 전달
            popUpVC.clothPreviews = clothItems.map { ClothPreview(id: $0.id, name: $0.name, wearNum: $0.count, imageUrl: $0.image) }
            popUpVC.currentIndex = indexPath.item
            popUpVC.clothId = Int64(popUpVC.clothPreviews[indexPath.item].id)
            popUpVC.modalPresentationStyle = .overCurrentContext
            popUpVC.modalTransitionStyle = .crossDissolve
            present(popUpVC, animated: true)
        }
    }
    
    // MARK: - Segment Control & SearchField Actions
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        currentMainCategoryId = index
        currentSubCategoryId = nil
        currentSearchText = ""
        displayAllView.searchField.textField.text = ""
        displayAllView.customTotalSegmentView.updateIndicatorPosition(for: index)
        updateContent(for: index)
        loadClothesData(categoryId: index)
    }
    
    @objc private func searchFieldDidChange(_ textField: UITextField) {
        let keyword = textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        currentSearchText = keyword
    }
}

// MARK: - Keyboard Dismiss Gestures
extension DisplayAllViewController {
    private func setupKeyboardDismissGestures() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        displayAllView.collectionView.keyboardDismissMode = .onDrag
    }
    
    @objc override func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - SortDropdownViewDelegate
extension DisplayAllViewController: SortDropdownViewDelegate {
    func didSelectSortOption(_ option: String) {
        currentSort = SortOption.from(option)
        displayAllView.sortButtonLabel.text = option
        let categoryId = currentSubCategoryId ?? currentMainCategoryId
        loadClothesData(categoryId: categoryId, isNextPage: false)
    }
}

// MARK: - UITextFieldDelegate
extension DisplayAllViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        currentMainCategoryId = 0
        currentSubCategoryId = nil
        displayAllView.customTotalSegmentView.segmentedControl.selectedSegmentIndex = 0
        displayAllView.customTotalSegmentView.updateIndicatorPosition(for: 0)
        searchClothes(keyword: currentSearchText)
        return true
    }
    
    private func filterItems() {
        if currentSearchText.isEmpty {
            clothItems = originalClothItems
        } else {
            clothItems = originalClothItems.filter {
                $0.name.lowercased().contains(currentSearchText.lowercased())
            }
        }
        DispatchQueue.main.async {
            self.displayAllView.collectionView.reloadData()
        }
    }
}

// MARK: - UIScrollViewDelegate
extension DisplayAllViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.height
        if offsetY > contentHeight - screenHeight - 100 {
            loadClothesData(categoryId: displayAllView.customTotalSegmentView.segmentedControl.selectedSegmentIndex, isNextPage: true)
        }
    }
}

// MARK: - CustomTotalSegmentViewDelegate
extension DisplayAllViewController: CustomTotalSegmentViewDelegate {
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
extension DisplayAllViewController: AddCategoryViewControllerDelegate {
    func didSelectCategory(_ categoryId: Int64, season: String?) {
        currentSubCategoryId = Int(categoryId)
        for mainIndex in 1...4 {
            if let categoryModel = CustomCategoryModel.getCategories(for: mainIndex),
               categoryModel.buttons.contains(where: { $0.categoryId == categoryId }) {
                let currentIndex = displayAllView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
                if currentIndex == 0 { updateContentViewConstraints(forTotal: false) }
                displayAllView.customTotalSegmentView.segmentedControl.selectedSegmentIndex = mainIndex
                displayAllView.customTotalSegmentView.updateIndicatorPosition(for: mainIndex)
                currentMainCategoryId = mainIndex
                displayAllView.customTotalSegmentView.toggleCategoryButtons(isHidden: false)
                displayAllView.customTotalSegmentView.updateCategories(for: categoryModel.buttons)
                for (buttonIndex, button) in categoryModel.buttons.enumerated() {
                    if button.categoryId == categoryId,
                       let buttonView = displayAllView.customTotalSegmentView.categoryButtonStackView.arrangedSubviews[buttonIndex] as? UIButton {
                        displayAllView.customTotalSegmentView.selectedCategoryButton = buttonView
                        displayAllView.customTotalSegmentView.updateButtonAppearance()
                        break
                    }
                }
                break
            }
        }
        loadClothesData(categoryId: Int(categoryId), isNextPage: false, season: season ?? "ALL")
        currentSearchText = ""
        displayAllView.searchField.textField.text = ""
    }
}

extension DisplayAllViewController: SmartSummationViewControllerDelegate {
    func didSelectCategory(baseCategoryName: String, coreCategoryName: String, coreCategoryId: Int64, season: String?) {
        // 전달받은 값을 사용해 UI 업데이트
        var targetMainIndex: Int = 0
        if baseCategoryName == "상의" {
            targetMainIndex = 1
        } else if baseCategoryName == "하의" {
            targetMainIndex = 2
        } else if baseCategoryName == "아우터" {
            targetMainIndex = 3
        } else if baseCategoryName == "악세서리" {
            targetMainIndex = 4
        }
        
        // UI 업데이트: 세그먼트 컨트롤, 인디케이터, 버튼 등
        displayAllView.customTotalSegmentView.segmentedControl.selectedSegmentIndex = targetMainIndex
        displayAllView.customTotalSegmentView.updateIndicatorPosition(for: targetMainIndex)
        currentMainCategoryId = targetMainIndex
        displayAllView.customTotalSegmentView.toggleCategoryButtons(isHidden: false)
        
        if let categoryModel = CustomCategoryModel.getCategories(for: targetMainIndex) {
            displayAllView.customTotalSegmentView.updateCategories(for: categoryModel.buttons)
            // 하위 카테고리 중 coreCategoryId와 일치하는 버튼 강조
            for (buttonIndex, button) in categoryModel.buttons.enumerated() {
                if button.categoryId == coreCategoryId,
                   let buttonView = displayAllView.customTotalSegmentView.categoryButtonStackView.arrangedSubviews[buttonIndex] as? UIButton {
                    displayAllView.customTotalSegmentView.selectedCategoryButton = buttonView
                    displayAllView.customTotalSegmentView.updateButtonAppearance()
                    break
                }
            }
        }
        
        // 컨텐츠 업데이트 호출 (예: updateContent(for:) 또는 loadClothesData)
        updateContent(for: targetMainIndex)
        loadClothesData(categoryId: Int(coreCategoryId), isNextPage: false, season: season ?? "ALL")
        currentSearchText = ""
        displayAllView.searchField.textField.text = ""
    }
}
