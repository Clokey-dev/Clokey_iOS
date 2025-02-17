import UIKit
import SnapKit

class ArrangeClosetViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let arrangeClosetView = ArrangeClosetView()

    // API를 통해 받아올 옷(제품) 데이터
    private var products: [ClosetModel] = []

    
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
    private let clothesService = ClothesService()

    override func loadView() {
        view = arrangeClosetView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()                     // 네비게이션 바, 뒤로가기 버튼 등 설정
        setupCollectionView()
        setupActions()
        setupSegmentedControl()
        loadInitialData()             // 초기 세그먼트에 맞는 데이터 로드
    }

    // MARK: - Setup Methods
    private func setupCollectionView() {
        let collectionView = arrangeClosetView.collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        // ArrangeClosetView에서 이미 셀 등록, estimatedItemSize는 .zero로 설정되어 있음
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = .zero
        }
    }

    private func setupActions() {
        arrangeClosetView.customTotalSegmentView.menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
    }

    @objc private func menuButtonTapped() {
        let categoryVC = AddCategoryViewController()
        categoryVC.modalPresentationStyle = .fullScreen
        categoryVC.modalTransitionStyle = .coverVertical
        present(categoryVC, animated: true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let initialIndex = arrangeClosetView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
        arrangeClosetView.customTotalSegmentView.updateIndicatorPosition(for: initialIndex)
    }

    private func setupUI() {
        let navBarManager = NavigationBarManager()
        navBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(backButtonTapped)
        )
        navBarManager.setTitle(
            to: navigationItem,
            title: "정리할 옷",
            font: .ptdBoldFont(ofSize: 20),
            textColor: .black
        )
    }

    private func setupSegmentedControl() {
        arrangeClosetView.customTotalSegmentView.segmentedControl.addTarget(
            self,
            action: #selector(segmentChanged(_:)),
            for: .valueChanged
        )
    }

    /// 초기 데이터 로드: 현재 선택된 세그먼트에 맞게 API 호출
    private func loadInitialData() {
        let initialIndex = arrangeClosetView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
        updateContent(for: initialIndex)
    }

    /// 세그먼트 변경 시 UI와 데이터를 업데이트합니다.
    private func updateContent(for index: Int) {
        if index == 0 {
            arrangeClosetView.customTotalSegmentView.toggleCategoryButtons(isHidden: true)
            arrangeClosetView.collectionView.snp.remakeConstraints { make in
                make.top.equalTo(arrangeClosetView.customTotalSegmentView.divideLine.snp.bottom).offset(16)
                make.leading.trailing.equalToSuperview().inset(20)
                make.bottom.equalToSuperview()
            }
        } else if let category = CustomCategoryModel.getCategories(for: index) {
            arrangeClosetView.customTotalSegmentView.toggleCategoryButtons(isHidden: false)
            arrangeClosetView.customTotalSegmentView.updateCategories(for: category.buttons)
            arrangeClosetView.collectionView.snp.remakeConstraints { make in
                make.top.equalTo(arrangeClosetView.customTotalSegmentView.categoryScrollView.snp.bottom)
                make.leading.trailing.equalToSuperview().inset(20)
                make.bottom.equalToSuperview()
            }
        }
        
        // API를 통해 옷 데이터를 불러옵니다. (항상 첫 페이지, 6개 cell)
        loadClothesData(categoryId: index)
    }

    /// ClothesService를 통해 옷 목록을 불러옵니다.
    private func loadClothesData(categoryId: Int, season: String = "ALL") {
        clothesService.getClothes(
            clokeyId: nil,
            categoryId: categoryId,
            season: season,
            sort: currentSort.rawValue,      // 정렬 기능이 필요 없으므로 빈 문자열 전달
            page: 1,       // 항상 첫 페이지 (고정)
            size: 6        // 6개의 cell만 표시
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
                    self.arrangeClosetView.collectionView.reloadData()
                }
                
            case .failure(let error):
                print("Error loading clothes: \(error)")
            }
        }
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
        
        // Kingfisher를 사용해 URL에서 이미지 비동기로 로드
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

    // MARK: - UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 선택 시 추가 동작이 필요한 경우 구현
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        arrangeClosetView.customTotalSegmentView.updateIndicatorPosition(for: index)
        updateContent(for: index)
    }

}
