import UIKit


class DisplayAllViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    // MARK: - Properties
    private let displayAllView = DisplayAllView()
    // 데이터 모델: ClosetModel을 사용 (TagClothViewController의 TagClothModel과 유사)
    private var clothItems: [ClosetModel] = []
    private var originalClothItems: [ClosetModel] = []
    
    // 검색
    private var currentSearchText: String = ""
    
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
    
    // API Service
    private let clothesService = ClothesService()
    
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
        setupUI()
        setupCollectionView()
        setupActions()
        setupSegmentedControl()
        setupSearchField()
        loadInitialData()
    }
    
    // MARK: - UI 설정
    private func setupUI() {
        let navBarManager = NavigationBarManager()
        navBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(backButtonTapped)
        )
        navBarManager.setTitle(
            to: navigationItem,
            title: "내 옷장",
            font: .ptdBoldFont(ofSize: 20),
            textColor: .black
        )
    }
    
    private func setupCollectionView() {
        displayAllView.collectionView.dataSource = self
        displayAllView.collectionView.delegate = self
        displayAllView.collectionView.register(
            CustomCollectionViewCell.self,
            forCellWithReuseIdentifier: CustomCollectionViewCell.identifier
        )
    }
    
    private func setupSegmentedControl() {
        displayAllView.customTotalSegmentView.segmentedControl.addTarget(
            self,
            action: #selector(segmentChanged(_:)),
            for: .valueChanged
        )
    }
    
    private func setupActions() {
        displayAllView.customTotalSegmentView.menuButton.addTarget(
            self,
            action: #selector(menuButtonTapped),
            for: .touchUpInside
        )
    }
    
    private func setupSearchField() {
        // displayAllView에 searchField가 있다고 가정합니다.
        displayAllView.searchField.textField.delegate = self
        displayAllView.searchField.textField.addTarget(
            self,
            action: #selector(searchFieldDidChange(_:)),
            for: .editingChanged
        )
    }
    
    // MARK: - 데이터 로드 및 업데이트
    private func loadInitialData() {
        let initialIndex = displayAllView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
        updateContent(for: initialIndex)
    }
    
    private func updateContent(for index: Int) {
        if index == 0 {
            // "전체" 선택 시 카테고리 버튼 숨김 및 전체 데이터 로드
            displayAllView.customTotalSegmentView.toggleCategoryButtons(isHidden: true)
            displayAllView.contentView.snp.remakeConstraints {
                $0.top.equalTo(displayAllView.customTotalSegmentView.divideLine.snp.bottom).offset(10)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.bottom.equalToSuperview()
            }
            currentMainCategoryId = 0
            currentSubCategoryId = nil
            loadClothesData(categoryId: 0)
        } else if let category = CustomCategoryModel.getCategories(for: index) {
            // 특정 카테고리 선택 시 카테고리 버튼 표시 및 데이터 로드
            displayAllView.customTotalSegmentView.toggleCategoryButtons(isHidden: false)
            displayAllView.customTotalSegmentView.updateCategories(for: category.buttons)
            displayAllView.contentView.snp.remakeConstraints {
                $0.top.equalTo(displayAllView.customTotalSegmentView.categoryScrollView.snp.bottom)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.bottom.equalToSuperview()
            }
            currentMainCategoryId = index
            currentSubCategoryId = nil
            loadClothesData(categoryId: index)
        }
    }
    
    private func loadClothesData(categoryId: Int = 0, isNextPage: Bool = false, season: String = "ALL") {
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
                // response.clothPreviews를 ClosetModel로 매핑 (필요에 따라 ClosetModel 생성자를 수정하세요)
                let newItems = response.clothPreviews.map { preview in
                    return ClosetModel(
                        id: Int(preview.id),
                        image: preview.imageUrl,
                        count :preview.wearNum,
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
    
    private func filterItems() {
        if currentSearchText.isEmpty {
            clothItems = originalClothItems
        } else {
            clothItems = originalClothItems.filter {
                $0.name.lowercased().contains(currentSearchText)
            }
        }
        DispatchQueue.main.async {
            self.displayAllView.collectionView.reloadData()
        }
    }
    
    // MARK: - Actions
    @objc private func menuButtonTapped() {
        let categoryVC = AddCategoryViewController()
        categoryVC.modalPresentationStyle = .fullScreen
        categoryVC.modalTransitionStyle = .coverVertical
        present(categoryVC, animated: true, completion: nil)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        displayAllView.customTotalSegmentView.updateIndicatorPosition(for: index)
        updateContent(for: index)
    }
    
    @objc private func searchFieldDidChange(_ textField: UITextField) {
        currentSearchText = textField.text?.lowercased() ?? ""
        filterItems()
    }
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clothItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CustomCollectionViewCell.identifier,
            for: indexPath
        ) as? CustomCollectionViewCell else {
            fatalError("Unable to dequeue CustomCollectionViewCell")
        }
        let product = clothItems[indexPath.item]

        // Kingfisher를 사용해 URL에서 이미지를 비동기로 로딩
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
    
    // MARK: - CollectionView Delegate (팝업 표시)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let popupVC = PopUpViewController()
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        present(popupVC, animated: true, completion: nil)
    }
    
    // MARK: - Pagination (스크롤 이벤트)
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.height
        
        if offsetY > contentHeight - screenHeight - 100 {
            let categoryId = currentSubCategoryId ?? currentMainCategoryId
            loadClothesData(categoryId: categoryId, isNextPage: true)
        }
    }
    
    // MARK: - 네비게이션 뒤로가기
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
