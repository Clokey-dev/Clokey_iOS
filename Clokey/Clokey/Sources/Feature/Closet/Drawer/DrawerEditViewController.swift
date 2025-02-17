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
            updateCompleteButtonState() // 선택/해제에 따라 확인 버튼 상태 업데이트
        }
    }

    // 정렬 옵션 (현재는 사용하지 않음)
    private var currentSort: SortOption = .wear

    // 제품 데이터: API를 통해 받아올 옷 목록
    private var products: [ClosetModel] = []

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
    /// - Parameter folderId: 폴더 편집 시 사용; 새 폴더 생성 시에는 nil
    init(folderId: Int64? = nil) {
        self.folderId = folderId
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
        
        // 편집 모드 vs 생성 모드 판단 예시
        if let fid = folderId, fid != 0 {
            print("DrawerEditViewController 편집 모드 - folderId = \(fid)")
        } else {
            print("DrawerEditViewController 생성 모드")
        }
        
        setupUI()
        setupCollectionView()
        setupActions()
        setupSegmentedControl()
        loadInitialData()  // API 호출을 통해 초기 데이터 로드
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let initialIndex = drawerEditView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
        drawerEditView.customTotalSegmentView.updateIndicatorPosition(for: initialIndex)
    }

    // MARK: - Setup Methods
    private func setupUI() {
        navigationItem.rightBarButtonItem = completeButton
        
        let navBarManager = NavigationBarManager()
        navBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(backButtonTapped)
        )
        navBarManager.setTitle(
            to: navigationItem,
            title: "아이템 선택하기",
            font: .ptdBoldFont(ofSize: 20),
            textColor: .black
        )
    }

    private func setupCollectionView() {
        drawerEditView.collectionView.dataSource = self
        drawerEditView.collectionView.delegate = self
        drawerEditView.collectionView.register(
            CustomCollectionViewCell.self,
            forCellWithReuseIdentifier: CustomCollectionViewCell.identifier
        )
        drawerEditView.collectionView.allowsMultipleSelection = true
    }

    private func setupSegmentedControl() {
        drawerEditView.customTotalSegmentView.segmentedControl.addTarget(
            self,
            action: #selector(segmentChanged(_:)),
            for: .valueChanged
        )
    }

    private func setupActions() {
        drawerEditView.customTotalSegmentView.menuButton.addTarget(
            self,
            action: #selector(menuButtonTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Data Handling
    /// 초기 데이터 로드: 현재 선택된 세그먼트에 따라 API 호출
    private func loadInitialData() {
        let initialIndex = drawerEditView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
        updateContent(for: initialIndex)
    }

    /// 세그먼트 인덱스에 따라 UI 업데이트 후 API 호출
    private func updateContent(for index: Int) {
        if index == 0 {
            // 전체 선택 시: 서브 카테고리 버튼 숨김
            drawerEditView.customTotalSegmentView.toggleCategoryButtons(isHidden: true)
            drawerEditView.contentView.snp.remakeConstraints { make in
                make.top.equalTo(drawerEditView.customTotalSegmentView.divideLine.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview().inset(20)
                make.bottom.equalToSuperview()
            }
            loadClothesData(categoryId: 0)
        } else if let category = CustomCategoryModel.getCategories(for: index) {
            // 특정 카테고리 선택 시: 서브 카테고리 버튼 표시
            drawerEditView.customTotalSegmentView.toggleCategoryButtons(isHidden: false)
            drawerEditView.customTotalSegmentView.updateCategories(for: category.buttons)
            drawerEditView.contentView.snp.remakeConstraints { make in
                make.top.equalTo(drawerEditView.customTotalSegmentView.categoryScrollView.snp.bottom)
                make.leading.trailing.equalToSuperview().inset(20)
                make.bottom.equalToSuperview()
            }
            loadClothesData(categoryId: index)
        }
    }

    /// ClothesService를 통해 옷 목록을 API로 불러옵니다.
    private func loadClothesData(categoryId: Int, season: String = "ALL") {
        clothesService.getClothes(
            clokeyId: nil,
            categoryId: categoryId,
            season: season,
            sort: currentSort.rawValue, 
            page: 1,       // 항상 첫 페이지
            size: 6        // 필요에 따라 표시할 cell 개수 조정
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let newItems = response.clothPreviews.map { preview in
                    ClosetModel(
                        id: preview.id,
                        image: preview.imageUrl,
                        count: preview.wearNum,
                        name: preview.name
                    )
                }
                self.products = newItems
                DispatchQueue.main.async {
                    self.drawerEditView.collectionView.reloadData()
                    
                    // 이미 선택한 항목 복원
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
        // Kingfisher를 사용해 URL로부터 이미지 비동기 로드
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
