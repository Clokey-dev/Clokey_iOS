//
//  RecordTagClothViewController.swift
//  Clokey
//
//  Created by 황상환 on 2/7/25.
//

import Foundation
import UIKit
import SnapKit
import Then

class TaggedClothCell: UICollectionViewCell {
    static let identifier = "TaggedClothCell"
    
    // MARK: - UI Components
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 5
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .black
        $0.textAlignment = .left
        $0.numberOfLines = 2
    }
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func configure(imageUrl: String, name: String) {
        if let url = URL(string: imageUrl) {
            imageView.kf.setImage(with: url)
        }
        nameLabel.text = name
    }
}

class RecordTagClothViewController: UIViewController {
    
    // MARK: - Properties
    private struct TaggedCloth {
        let clothId: Int
        let imageUrl: String
        let name: String
    }
    
    private var cloths: [ClothDTO] = []

    private var taggedClothes: [TaggedCloth] = []
    
    // MARK: - Init
    init(cloths: [ClothDTO]) {
        self.cloths = cloths
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "태그한 옷"
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .black
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 16
        
        let width = 120.0
        let height = 160.0
        layout.itemSize = CGSize(width: width, height: height + 20) 
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.register(TaggedClothCell.self, forCellWithReuseIdentifier: TaggedClothCell.identifier)
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupClothsData()
        
        collectionView.dataSource = self
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(collectionView)
        
        containerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(300)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(200)
        }
        
        // 바깥 영역 탭하면 닫히도록
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOutside))
        view.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    // 옷 데이터 불러오기
    private func setupClothsData() {
        taggedClothes = cloths.map { cloth in
            TaggedCloth(
                clothId: cloth.clothId,
                imageUrl: cloth.clothImageUrl,
                name: cloth.clothName
            )
        }
        collectionView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func didTapOutside() {
        dismiss(animated: false)
    }
}

// MARK: - UICollectionViewDataSource
extension RecordTagClothViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taggedClothes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaggedClothCell.identifier, for: indexPath) as! TaggedClothCell
        let item = taggedClothes[indexPath.item]
        cell.configure(imageUrl: item.imageUrl, name: item.name)
        return cell
    }
}
