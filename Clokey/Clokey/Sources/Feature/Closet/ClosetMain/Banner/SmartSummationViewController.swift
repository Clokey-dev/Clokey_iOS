import UIKit

class SmartSummationViewController: UIViewController {
    
    // MARK: - UI & Service
    private let summationView = SmartSummationView()
    private let clothesService = ClothesService()
    
    // MARK: - Data
    private var frequentClothes: [ClothPreviewDTO] = []
    private var infrequentClothes: [ClothPreviewDTO] = []
    
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
        // SmartSummationView를 루트 뷰로 설정
        self.view = summationView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViews()
        fetchSmartSummationData()
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
                if response.isSuccess {
                    let frequent = response.result.frequentResult
                    let infrequent = response.result.infrequentResult
                    
                    DispatchQueue.main.async {
                        // 업데이트: 자주 입은 옷 섹션
                        self.summationView.categoryButton1.setTitle(frequent.baseCategoryName, for: .normal)
                        self.summationView.categoryButton2.setTitle(frequent.coreCategoryName, for: .normal)
                        self.summationView.frequentTitleLabel.text = " - 일주일간 평균 \(frequent.usage)회 착용"
                        
                        // 최대 3개 셀만 사용
                        self.frequentClothes = Array(frequent.clothPreviews.prefix(3))
                        self.summationView.freCollectionView.reloadData()
                        
                        // 업데이트: 잘 안 입은 옷 섹션
                        self.summationView.categoryButton3.setTitle(infrequent.baseCategoryName, for: .normal)
                        self.summationView.categoryButton4.setTitle(infrequent.coreCategoryName, for: .normal)
                        self.summationView.infrequentTitleLabel.text = " - 일주일간 평균 \(infrequent.usage)회 착용"
                        
                        self.infrequentClothes = Array(infrequent.clothPreviews.prefix(3))
                        self.summationView.infreCollectionView.reloadData()
                    }
                } else {
                    print("스마트 요약 API 응답 실패: isSuccess false")
                }
            case .failure(let error):
                print("스마트 요약 API 호출 실패: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - UICollectionViewDataSource & DelegateFlowLayout
extension SmartSummationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // 두 컬렉션 뷰 모두 섹션은 1개
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == summationView.freCollectionView {
            return frequentClothes.count
        } else {
            return infrequentClothes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 팀에서 사용하는 CustomCollectionViewCell을 그대로 사용
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier,
                                                            for: indexPath) as? CustomCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let cloth: ClothPreviewDTO = (collectionView == summationView.freCollectionView)
            ? frequentClothes[indexPath.item]
            : infrequentClothes[indexPath.item]
        
        // 직접 셀의 프로퍼티에 값을 할당하여 구성
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
    
    // 셀 크기 설정 (FlowLayout)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 디자인에 맞춰 111 x 167 크기로 반환
        return CGSize(width: 111, height: 167)
    }
}
