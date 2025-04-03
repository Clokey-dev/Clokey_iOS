import UIKit
import SnapKit

final class DrawerView: UIView, UICollectionViewDataSource {
    
    // MARK: - Properties
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.scrollDirection = .vertical
            $0.minimumLineSpacing = 20
            $0.minimumInteritemSpacing = 10
            $0.estimatedItemSize = .zero
            
            let totalMargin: CGFloat = 40   // 좌우 inset 20씩
            let interitemSpacing: CGFloat = 10 * 2 // 아이템 간 간격 10씩 2칸
            let extraSpacing: CGFloat = 5            // 여유 공간
            let availableWidth = UIScreen.main.bounds.width - totalMargin - interitemSpacing - extraSpacing
            let itemWidth = availableWidth / 3
            let imageHeight = itemWidth * 4 / 3
            let cellHeight = imageHeight + 25  // 이미지 아래 5 + 라벨 20
            
            $0.itemSize = CGSize(width: itemWidth, height: cellHeight)
        }
    ).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.register(ClosetCollectionViewCell.self, forCellWithReuseIdentifier: ClosetCollectionViewCell.identifier)
    }
    private var products: [ClosetModel] = []
    private var shouldHideNumberLabel: Bool = false
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupCollectionView()
    }
    
    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .white
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(32)

            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(10)
        }
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
    }
    
    // MARK: - Public Methods
    func configure(with products: [ClosetModel], hideNumberLabel: Bool) {
        self.products = products
        self.shouldHideNumberLabel = hideNumberLabel
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClosetCollectionViewCell.identifier, for: indexPath) as? ClosetCollectionViewCell else {
            fatalError("Unable to dequeue ClosetCollectionViewCell")
        }
        
//        let product = products[indexPath.item]
//        cell.configureCell(with: product, hideNumberLabel: shouldHideNumberLabel)
//        
        return cell
    }
}
