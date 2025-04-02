import UIKit

protocol SmartSummationViewControllerDelegate: AnyObject {
    func didSelectCategory(baseCategoryName: String, coreCategoryName: String, coreCategoryId: Int64, season: String?)
}

class SmartSummationViewController: UIViewController {
    
    // MARK: - UI & Service
    private let summationView = SmartSummationView()
    private let clothesService = ClothesService()
    
    // MARK: - Data
    private var frequentClothes: [ClothPreviewDTO] = []
    private var infrequentClothes: [ClothPreviewDTO] = []
    
    // 전체 정보를 저장 (frequentResult, infrequentResult)
    private var frequentResult: SummaryClothPreviewDTO?
    private var infrequentResult: SummaryClothPreviewDTO?
    
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

    weak var delegate: SmartSummationViewControllerDelegate?
    
    override func loadView() {
        self.view = summationView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupCollectionViews()
        fetchSmartSummationData()
        fetchNickname()
    }
    
    private func setupUI() {
        let navBarManager = NavigationBarManager()
        navBarManager.addBackButton(to: navigationItem, target: self, action: #selector(backButtonTapped))
        navBarManager.setTitle(to: navigationItem, title: "스마트 요약", font: .ptdBoldFont(ofSize: 20), textColor: .black)
    }
    
    private func setupActions() {
        summationView.seeAllButton.addTarget(self, action: #selector(seeAllButton1Tapped), for: .touchUpInside)
        summationView.seeAllButton2.addTarget(self, action: #selector(seeAllButton2Tapped), for: .touchUpInside)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // seeAllButton1 (자주 착용한 옷)
    @objc private func seeAllButton1Tapped() {
        guard let result = self.frequentResult else { return }
        let displayAllVC = DisplayAllViewController()
        displayAllVC.loadViewIfNeeded() // viewDidLoad가 호출되도록 함
        displayAllVC.didSelectCategory(
             baseCategoryName: result.baseCategoryName,
             coreCategoryName: result.coreCategoryName,
             coreCategoryId: result.coreCategoryId,
             season: "ALL"
        )
        navigationController?.pushViewController(displayAllVC, animated: true)
    }

    // seeAllButton2 (잘 안 착용한 옷)
    @objc private func seeAllButton2Tapped() {
        guard let result = self.infrequentResult else { return }
        let displayAllVC = DisplayAllViewController()
        displayAllVC.loadViewIfNeeded() // viewDidLoad가 호출되도록 함
        displayAllVC.didSelectCategory(
             baseCategoryName: result.baseCategoryName,
             coreCategoryName: result.coreCategoryName,
             coreCategoryId: result.coreCategoryId,
             season: "ALL"
        )
        navigationController?.pushViewController(displayAllVC, animated: true)
    }

    // MARK: - CollectionView Setup
    private func setupCollectionViews() {
        summationView.freCollectionView.dataSource = self
        summationView.freCollectionView.delegate = self
        
        summationView.infreCollectionView.dataSource = self
        summationView.infreCollectionView.delegate = self
    }
    
    // MARK: - API Data Fetching
    private func fetchSmartSummationData() {
        clothesService.getSmartSummationClothes { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let frequent = response.frequentResult
                let infrequent = response.infrequentResult
                
                // 저장
                self.frequentResult = frequent
                self.infrequentResult = infrequent
                
                DispatchQueue.main.async {
                    self.summationView.categoryButton1.setTitle(frequent.baseCategoryName, for: .normal)
                    self.summationView.categoryButton2.setTitle(frequent.coreCategoryName, for: .normal)
                    self.summationView.frequentTitleLabel.text = " - 한달간 \(frequent.usage)회 착용"
                    self.frequentClothes = Array(frequent.clothPreviews.prefix(3))
                    self.summationView.seeAllButton.setTitle("\(frequent.coreCategoryName)말고 다른 옷 보러가기", for: .normal)
                    self.summationView.freCollectionView.reloadData()
                    
                    self.summationView.categoryButton3.setTitle(infrequent.baseCategoryName, for: .normal)
                    self.summationView.categoryButton4.setTitle(infrequent.coreCategoryName, for: .normal)
                    self.summationView.infrequentTitleLabel.text = " - 한달간 \(infrequent.usage)회 착용"
                    self.infrequentClothes = Array(infrequent.clothPreviews.prefix(3))
                    self.summationView.seeAllButton2.setTitle("옷장 구석에서 \(infrequent.coreCategoryName) 찾아보기", for: .normal)
                    self.summationView.infreCollectionView.reloadData()
                    
                    // 데이터가 없다면 EmptyStateView 표시 (배너영역은 유지)
                    self.updateEmptyState()
                }
            case .failure(let error):
                print("스마트 요약 API 호출 실패: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.updateEmptyState()
                }
            }
        }
    }
    
    /// 기존 스마트 요약 API에서 닉네임을 받아오는 걸 이걸로 대체.
    private func fetchNickname() {
        clothesService.getClothes(
            clokeyId: nil,
            categoryId: 0, 
            season: "ALL",
            sort: "WEAR",
            page: 1,
            size: 1
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.summationView.bannerDescription.text =
                        "지난 30일 간 \(response.nickname)님의 옷 데이터를 모았어요!\n자주 착용한 옷과 착용하지 않은 옷입니다!"
                }
            case .failure(let error):
                print("닉네임 호출 실패: \(error.localizedDescription)")
//                self.showErrorAlert()

            }
        }
    }
    
    // MARK: - Empty State Handling
    private func updateEmptyState() {
        if frequentClothes.isEmpty && infrequentClothes.isEmpty {
            for subview in summationView.subviews {
                if subview is EmptyStateView {
                    subview.removeFromSuperview()
                }
            }
            let emptyView = EmptyStateView(
                mainMessage: "아직 캘린더에 기록을 추가하지 않았어요!",
                subMessage: "캘린더에 기록을 추가해 나만의 스타일을 자랑하고,\n 스마트 요약 기능도 이용해 보세요."
            )
            summationView.addSubview(emptyView)
            emptyView.snp.makeConstraints { make in
                make.top.equalTo(summationView.bannerView.snp.bottom)
                make.leading.trailing.bottom.equalToSuperview()
            }
        } else {
            for subview in summationView.subviews {
                if subview is EmptyStateView {
                    subview.removeFromSuperview()
                }
            }
        }
    }
}

extension SmartSummationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (collectionView == summationView.freCollectionView) ? frequentClothes.count : infrequentClothes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier,
                                                            for: indexPath) as? CustomCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let cloth = (collectionView == summationView.freCollectionView) ? frequentClothes[indexPath.item] : infrequentClothes[indexPath.item]
        if let url = URL(string: cloth.imageUrl) {
            cell.productImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"))
        } else {
            cell.productImageView.image = UIImage(named: "placeholderImage")
        }
        cell.countLabel.text = "\(cloth.wearNum)회"
        cell.nameLabel.text = cloth.name
        cell.numberLabel.text = "\(indexPath.item + 1)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 111, height: 167)
    }
}
