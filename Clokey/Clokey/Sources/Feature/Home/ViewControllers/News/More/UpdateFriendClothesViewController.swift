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
    
//    private func loadData() {
//        updates = UpdateFriendClothesModel.dummy()
//        
//        DispatchQueue.main.async {
//            self.updateFriendClothesView.updateFriendClothesCollectionView.reloadData()
//        }
//    }
    
    private func loadData() {
        let homeService = HomeService()
        homeService.fetchGetDetailIssuesData(
            section: "closet",
            page: 1
        ) { (result: Result<GetDetailIssuesClosetResponseDTO, NetworkError>) in
            switch result {
            case .success(let responseDTO):
                self.updates = responseDTO.dailyNewsResult.map { item in
                    return UpdateFriendClothesModel(profileImage: URL(string: item.profileImage)!, name: item.clokeyId, date: item.date, clothingImages: (item.images?.compactMap { URL(string: $0) })! )
                }
                
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
                    placeholder: UIImage(named: "profile_placeholder"), // 기본 이미지
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
//        cell.dateLabel.text = update.date
        // ✅ 날짜 포맷 변경 (시간 제거)
        let formattedDate = formatDate(update.date)
        cell.dateLabel.text = formattedDate // 날짜 변환 후 설정
        
        return cell
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // 기존 형식
        inputFormatter.locale = Locale(identifier: "ko_KR") // 한국 시간 설정
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd" // 원하는 형식
            return outputFormatter.string(from: date)
        }
        
        return dateString // 변환 실패 시 원본 반환
    }
}

// MARK: - UICollectionViewDelegate
extension UpdateFriendClothesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedUpdate = updates[indexPath.item]
        print("Selected Update: \(selectedUpdate.name)")
        // 추가 동작 (예: 상세 화면 이동) 구현
    }
}
