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
    
    // coreCategoryId 외에 전체 정보를 저장 (frequentResult, infrequentResult)
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

    override func loadView() {
        self.view = summationView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupCollectionViews()
        fetchSmartSummationData()
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
                let nickname = response.nickname
                
                // 저장
                self.frequentResult = frequent
                self.infrequentResult = infrequent
                
                DispatchQueue.main.async {
                    self.summationView.bannerDescription.text =
                        "지난 7일 간 \(nickname)님의 옷 데이터를 모았어요!\n자주 착용한 옷과 착용하지 않은 옷입니다!"
                    
                    self.summationView.categoryButton1.setTitle(frequent.baseCategoryName, for: .normal)
                    self.summationView.categoryButton2.setTitle(frequent.coreCategoryName, for: .normal)
                    self.summationView.frequentTitleLabel.text = " - 일주일간 평균 \(frequent.usage)회 착용"
                    self.frequentClothes = Array(frequent.clothPreviews.prefix(3))
                    self.summationView.seeAllButton.setTitle("\(frequent.coreCategoryName)말고 다른 옷 보러가기", for: .normal)
                    self.summationView.freCollectionView.reloadData()
                    
                    self.summationView.categoryButton3.setTitle(infrequent.baseCategoryName, for: .normal)
                    self.summationView.categoryButton4.setTitle(infrequent.coreCategoryName, for: .normal)
                    self.summationView.infrequentTitleLabel.text = " - 일주일간 평균 \(infrequent.usage)회 착용"
                    self.infrequentClothes = Array(infrequent.clothPreviews.prefix(3))
                    self.summationView.seeAllButton2.setTitle("옷장 구석에서 \(infrequent.coreCategoryName) 찾아보기", for: .normal)
                    self.summationView.infreCollectionView.reloadData()
                }
            case .failure(let error):
                print("스마트 요약 API 호출 실패: \(error.localizedDescription)")
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
