//
//  UpdateFriendClothesViewController.swift
//  Clokey
//
//  Created by 한금준 on 1/17/25.
//

import UIKit
import Then

class UpdateFriendClothesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    private var updates: [UpdateFriendClothesModel] = [
        UpdateFriendClothesModel(
            profileImage: "profile_icon",
            name: "티라미수케이크",
            date: "24.11.09",
            clothingImages: ["clothing1", "clothing2", "clothing3"]
        ),
        UpdateFriendClothesModel(
            profileImage: "profile_icon",
            name: "닉네임",
            date: "날짜",
            clothingImages: ["clothing4", "clothing5", "clothing6"]
        ),
        UpdateFriendClothesModel(
            profileImage: "profile_icon",
            name: "닉네임",
            date: "날짜",
            clothingImages: ["clothing4", "clothing5", "clothing6"]
        ),
        UpdateFriendClothesModel(
            profileImage: "profile_icon",
            name: "닉네임",
            date: "날짜",
            clothingImages: ["clothing4", "clothing5", "clothing6"]
        )
    ]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "친구의 옷장 업데이트 소식"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    /// 구분 선
    private let lineView = UIView().then {
        $0.backgroundColor = .systemGray5
    }
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add Title Label
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        view.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)  // 화면 전체 너비
            $0.height.equalTo(1)  // 높이 1포인트
        }
        
        // Add Collection View
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            UpdateFriendClothesCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: UpdateFriendClothesCollectionReusableView.identifier
        )
        collectionView.register(
            UpdateFriendClothesFooterCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: UpdateFriendClothesFooterCollectionReusableView.identifier
        )
        collectionView.register(
            UpdateFriendClothesCollectionViewCell.self,
            forCellWithReuseIdentifier: UpdateFriendClothesCollectionViewCell.identifier
        )
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return updates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return updates[section].clothingImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UpdateFriendClothesCollectionViewCell.identifier,
            for: indexPath
        ) as? UpdateFriendClothesCollectionViewCell else {
            return UICollectionViewCell()
        }
        let imageName = updates[indexPath.section].clothingImages[indexPath.item]
        cell.configure(with: imageName)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 10) // Footer 높이 설정
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            // Header 처리
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: UpdateFriendClothesCollectionReusableView.identifier,
                for: indexPath
            ) as? UpdateFriendClothesCollectionReusableView else {
                return UICollectionReusableView()
            }
            
            let update = updates[indexPath.section]
            header.configure(profileImage: update.profileImage, name: update.name, date: update.date)
            return header
            
        } else if kind == UICollectionView.elementKindSectionFooter {
            // Footer 처리
            guard let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: UpdateFriendClothesFooterCollectionReusableView.identifier,
                for: indexPath
            ) as? UpdateFriendClothesFooterCollectionReusableView else {
                return UICollectionReusableView()
            }
            return footer
        }
        return UICollectionReusableView()
    }
}
