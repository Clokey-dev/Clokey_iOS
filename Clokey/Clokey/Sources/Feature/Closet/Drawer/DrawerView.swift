import UIKit
import SnapKit

final class DrawerView: UIView, UICollectionViewDataSource {
    
    // MARK: - Properties
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 111, height: 167)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ClosetCollectionViewCell.self, forCellWithReuseIdentifier: ClosetCollectionViewCell.identifier)
        return collectionView
    }()
    
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
