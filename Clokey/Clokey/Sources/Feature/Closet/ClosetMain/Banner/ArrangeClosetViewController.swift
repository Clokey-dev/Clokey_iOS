import UIKit
import SnapKit

class ArrangeClosetViewController: UIViewController {
    
    private let arrangeClosetView = ArrangeClosetView()
    
    // API를 통해 받아올 옷(제품) 데이터
    private var products: [ClosetModel] = []
    
    // 사용자의 clokeyId (예: 사용자 고유 아이디 혹은 닉네임)
    var clokeyId: String = ""
    
    // 카테고리 선택 상태 (ClosetViewController와 동일한 역할)
    private var currentMainCategoryId: Int = 0
    private var currentSubCategoryId: Int? = nil
    
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
        print("[ArrangeClosetVC] viewDidLoad")
        setupUI()              // 네비게이션 바, 뒤로가기 버튼 등 설정
        setupCollectionView()
        setupSegmentedControl()
        loadInitialData()      // 초기 세그먼트에 맞는 데이터 로드
        
        // customTotalSegmentView의 delegate 설정
        arrangeClosetView.customTotalSegmentView.delegate = self
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        let navBarManager = NavigationBarManager()
        navBarManager.addBackButton(to: navigationItem,
                                    target: self,
                                    action: #selector(backButtonTapped))
        navBarManager.setTitle(to: navigationItem,
                               title: "정리할 옷",
                               font: .ptdBoldFont(ofSize: 20),
                               textColor: .black)
    }
    
    private func setupCollectionView() {
        let collectionView = arrangeClosetView.collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = .zero
        }
    }
    
    private func setupSegmentedControl() {
        arrangeClosetView.customTotalSegmentView.segmentedControl.addTarget(self,
                                                                            action: #selector(segmentChanged(_:)),
                                                                            for: .valueChanged)
    }
    
    private func loadInitialData() {
        let initialIndex = arrangeClosetView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
        print("[ArrangeClosetVC] loadInitialData - initialIndex: \(initialIndex)")
        updateContent(for: initialIndex)
    }
    
    private func updateContent(for index: Int) {
        print("[ArrangeClosetVC] updateContent - index: \(index)")
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
        loadClothesData(categoryId: index)
    }
    
    private func loadClothesData(categoryId: Int, season: String = "WINTER") {
        print("[ArrangeClosetVC] loadClothesData - categoryId: \(categoryId), season: \(season)")
        clothesService.getClothes(clokeyId: nil,
                                  categoryId: categoryId,
                                  season: season,
                                  sort: currentSort.rawValue,
                                  page: 1,
                                  size: 12) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                print("[ArrangeClosetVC] API success - clothPreviews count: \(response.clothPreviews.count)")
                self.clokeyId = response.nickname
                DispatchQueue.main.async {
                    self.arrangeClosetView.bannerDescription.text =
                        "겨울 옷을 정리할 시간입니다!\n\(self.clokeyId)님의 겨울 옷들을 보여드릴게요."
                }
                let newItems = response.clothPreviews.map { preview in
                    ClosetModel(id: preview.id,
                                image: preview.imageUrl,
                                count: preview.wearNum,
                                name: preview.name)
                }
                self.products = newItems
                print("[ArrangeClosetVC] products updated - count: \(self.products.count)")
                DispatchQueue.main.async {
                    print("[ArrangeClosetVC] collectionView.reloadData() 호출")
                    self.arrangeClosetView.collectionView.reloadData()
                }
            case .failure(let error):
                print("[ArrangeClosetVC] Error loading clothes: \(error)")
                self.showAlerT(title: "네트워크 오류",
                               message: "인터넷 연결이 끊겼습니다.")
            }
        }
    }
    
    private func showAlerT(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        print("[ArrangeClosetVC] segmentChanged - selectedIndex: \(index)")
        arrangeClosetView.customTotalSegmentView.updateIndicatorPosition(for: index)
        updateContent(for: index)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension ArrangeClosetViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("[ArrangeClosetVC] numberOfItemsInSection - count: \(products.count)")
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier,
                                                            for: indexPath) as? CustomCollectionViewCell else {
            fatalError("Unable to dequeue CustomCollectionViewCell")
        }
        let product = products[indexPath.item]
        if let url = URL(string: product.image) {
            cell.productImageView.kf.setImage(with: url,
                                              placeholder: UIImage(named: "placeholderImage"))
        } else {
            cell.productImageView.image = UIImage(named: "placeholderImage")
        }
        cell.numberLabel.text = "\(indexPath.item + 1)"
        cell.countLabel.text = "\(product.count)회"
        cell.nameLabel.text = product.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("[ArrangeClosetVC] didSelectItemAt - index: \(indexPath.item)")
        // 추가 동작 구현 가능
    }
}

// MARK: - CustomTotalSegmentViewDelegate
extension ArrangeClosetViewController: CustomTotalSegmentViewDelegate {
    func didSelectMainCategory(categoryId: Int) {
        print("[ArrangeClosetVC] didSelectMainCategory - categoryId: \(categoryId)")
        currentMainCategoryId = categoryId
        currentSubCategoryId = nil
        loadClothesData(categoryId: categoryId)
    }
    
    func didSelectSubCategory(categoryId: Int) {
        print("[ArrangeClosetVC] didSelectSubCategory - categoryId: \(categoryId)")
        currentSubCategoryId = categoryId
        loadClothesData(categoryId: categoryId)
    }
    
    func didTapSideBarButton() {
        print("[ArrangeClosetVC] didTapSideBarButton")
        let addCategoryVC = AddCategoryViewController()
        addCategoryVC.delegate = self
        addCategoryVC.defaultSeason = "WINTER" // 기본 시즌 WINTER로 설정
        navigationController?.pushViewController(addCategoryVC, animated: true)
    }
}

// MARK: - AddCategoryViewControllerDelegate
extension ArrangeClosetViewController: AddCategoryViewControllerDelegate {
    func didSelectCategory(_ categoryId: Int64, season: String?) {
        print("[ArrangeClosetVC] didSelectCategory delegate 호출 - categoryId: \(categoryId), season: \(season ?? "WINTER")")
        currentSubCategoryId = Int(categoryId)
        for mainIndex in 1...4 {
            if let categoryModel = CustomCategoryModel.getCategories(for: mainIndex),
               categoryModel.buttons.contains(where: { $0.categoryId == categoryId }) {
                let currentIndex = arrangeClosetView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
                if currentIndex == 0 {
                    // "전체" 상태에서 특정 카테고리로 전환하면 레이아웃을 서브 카테고리용으로 재설정
                    arrangeClosetView.collectionView.snp.remakeConstraints { make in
                        make.top.equalTo(arrangeClosetView.customTotalSegmentView.categoryScrollView.snp.bottom)
                        make.centerX.equalToSuperview()
                        let totalMargin: CGFloat = 40   // 좌우 inset 20씩
                        let interitemSpacing: CGFloat = 10 * 2  // 셀 사이 간격 10pt씩 2칸
                        let extraSpacing: CGFloat = 5     // 추가 여유 공간
                        let availableWidth = UIScreen.main.bounds.width - totalMargin - interitemSpacing - extraSpacing
                        let itemWidth = availableWidth / 3
                        
                        let imageHeight = itemWidth * 4 / 3  // 이미지 3:4 비율
                        let cellHeight = imageHeight + 25    // 이미지 아래 간격 5pt + 라벨 높이 20pt = 25pt
                        let totalCollectionViewHeight = 2 * cellHeight + 30  // 2줄 셀 높이 + 행 간 간격 25pt
                        
                        make.height.equalTo(totalCollectionViewHeight)
                        make.width.equalTo(UIScreen.main.bounds.width - 40)
                    }
                }
                arrangeClosetView.customTotalSegmentView.segmentedControl.selectedSegmentIndex = mainIndex
                arrangeClosetView.customTotalSegmentView.updateIndicatorPosition(for: mainIndex)
                currentMainCategoryId = mainIndex
                arrangeClosetView.customTotalSegmentView.toggleCategoryButtons(isHidden: false)
                arrangeClosetView.customTotalSegmentView.updateCategories(for: categoryModel.buttons)
                for (buttonIndex, button) in categoryModel.buttons.enumerated() {
                    if button.categoryId == categoryId,
                       let buttonView = arrangeClosetView.customTotalSegmentView.categoryButtonStackView.arrangedSubviews[buttonIndex] as? UIButton {
                        arrangeClosetView.customTotalSegmentView.selectedCategoryButton = buttonView
                        arrangeClosetView.customTotalSegmentView.updateButtonAppearance()
                        break
                    }
                }
                break
            }
        }
        loadClothesData(categoryId: Int(categoryId), season: season ?? "WINTER")
    }
}
