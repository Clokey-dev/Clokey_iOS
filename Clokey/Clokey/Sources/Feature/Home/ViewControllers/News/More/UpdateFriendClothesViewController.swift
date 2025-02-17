//
//  UpdateFriendClothesViewController.swift
//  Clokey
//
//  Created by 한금준 on 1/17/25.
//

import UIKit
import Then
import SnapKit
import Kingfisher

class UpdateFriendClothesViewController: UIViewController {
    
    private let updateFriendClothesView = UpdateFriendClothesView()
    
    // MARK: - Properties
    private var updates: [UpdateFriendClothesModel] = []
    
    private var currentPage = 1
    private var isLoading = false
    private var hasMorePages = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = updateFriendClothesView
        
        setupDelegate()
        loadData()
        
        updateFriendClothesView.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        DispatchQueue.main.async {
            self.updateFriendClothesView.updateFriendClothesCollectionView.reloadData()
            self.updateCollectionViewHeight()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    
    private func updateCollectionViewHeight() {
        updateFriendClothesView.updateFriendClothesCollectionView.layoutIfNeeded()
        let contentHeight = updateFriendClothesView.updateFriendClothesCollectionView.contentSize.height
        print("Content Height: \(contentHeight)") // 디버깅용 출력
        
        updateFriendClothesView.updateFriendClothesCollectionView.snp.updateConstraints { make in
            make.height.equalTo(contentHeight)
        }
    }
    
    private func setupDelegate() {
        updateFriendClothesView.updateFriendClothesCollectionView.dataSource = self
        updateFriendClothesView.updateFriendClothesCollectionView.delegate = self
    }
    
    private func loadData(isNextPage: Bool = false) {
        guard !isLoading && (hasMorePages || !isNextPage) else { return }
        
        isLoading = true
        let nextPage = isNextPage ? currentPage + 1 : 1
        
        let homeService = HomeService()
        homeService.fetchGetDetailIssuesData(
            section: "closet",
            page: nextPage
        ) { (result: Result<GetDetailIssuesClosetResponseDTO, NetworkError>) in
            defer { self.isLoading = false }
            
            switch result {
            case .success(let responseDTO):
                let newResult = responseDTO.dailyNewsResult.map { item in
                    UpdateFriendClothesModel(
                        profileImage: URL(string: item.profileImage)!,
                        name: item.clokeyId,
                        date: item.date,
                        clothingImages: (item.images?.compactMap { URL(string: $0) })!
                    )
                }

                if isNextPage {
                    self.updates.append(contentsOf: newResult)
                    self.currentPage = nextPage
                } else {
                    self.updates = newResult
                    self.currentPage = 1
                }

                self.hasMorePages = !newResult.isEmpty

                DispatchQueue.main.async {
                    self.updateFriendClothesView.updateFriendClothesCollectionView.reloadData()
                    self.updateCollectionViewHeight()
                }

            case .failure(let error):
                print("Failed to load calendar data: \(error)")
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension UpdateFriendClothesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return updates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UpdateFriendClothesCollectionViewCell.identifier,
            for: indexPath
        ) as? UpdateFriendClothesCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let update = updates[indexPath.item]
        
        if let profileImageURL = update.profileImage {
                print("Loading profile image from URL: \(profileImageURL.absoluteString)") // 디버깅 로그
                cell.profileIcon.kf.setImage(
                    with: profileImageURL,
                    placeholder: UIImage(named: "profile_basic"), // 기본 이미지
                    options: nil,
                    progressBlock: nil,
                    completionHandler: { result in
                        switch result {
                        case .success(let value):
                            print("Profile Image loaded: \(value.source.url?.absoluteString ?? "")")
                        case .failure(let error):
                            print("Error loading profile image: \(error.localizedDescription)")
                        }
                    }
                )
            } else {
                print("Profile image URL is nil") // 프로필 이미지 URL이 없을 경우 로그
                cell.profileIcon.image = UIImage(named: "profile_placeholder")
            }
        
        // 이미지 로드
        let imageViews = [cell.image1, cell.image2, cell.image3]
        for (index, url) in update.clothingImages.enumerated() {
            guard index < imageViews.count else { break }
            imageViews[index].kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder"),
                options: nil,
                progressBlock: nil,
                completionHandler: { result in
                    switch result {
                    case .success(let value):
                        print("Image loaded: \(value.source.url?.absoluteString ?? "")")
                    case .failure(let error):
                        print("Error loading image: \(error.localizedDescription)")
                    }
                }
            )
        }
        
        // 텍스트 설정
        cell.nameLabel.text = update.name
        cell.dateLabel.text = update.date
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension UpdateFriendClothesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedUpdate = updates[indexPath.item]
        print("Selected Update: \(selectedUpdate.name)")
        
    }
}
