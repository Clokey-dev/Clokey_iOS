//
//  UpdateFriendCalendarViewController.swift
//  Clokey
//
//  Created by 한금준 on 1/17/25.
//

// 완료

import UIKit
import Kingfisher

class UpdateFriendCalendarViewController: UIViewController {
    
    private let updateFriendCalendarView = UpdateFriendCalendarView()
    private var modelData: [UpdateFriendCalendarModel] = []
    
    private var currentPage = 1
    private var isLoading = false
    private var hasMorePages = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = updateFriendCalendarView
        
        setupDelegate()
        loadData()
        
        updateFriendCalendarView.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        DispatchQueue.main.async {
            self.updateFriendCalendarView.updateFriendCalendarCollectionView.reloadData()
            self.updateCollectionViewHeight()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func updateCollectionViewHeight() {
        updateFriendCalendarView.updateFriendCalendarCollectionView.layoutIfNeeded()
        let contentHeight = updateFriendCalendarView.updateFriendCalendarCollectionView.contentSize.height
        print("Content Height: \(contentHeight)") // 디버깅용 출력
        
        updateFriendCalendarView.updateFriendCalendarCollectionView.snp.updateConstraints { make in
            make.height.equalTo(contentHeight)
        }
    }
    
    private func setupDelegate() {
        updateFriendCalendarView.updateFriendCalendarCollectionView.dataSource = self
    }
    
    private func loadData(isNextPage: Bool = false) {
        guard !isLoading && (hasMorePages || !isNextPage) else { return }
        
        isLoading = true
        let nextPage = isNextPage ? currentPage + 1 : 1
        
        let homeService = HomeService()
        homeService.fetchGetDetailIssuesData(
            section: "calendar",
            page: nextPage
        ) { (result: Result<GetDetailIssuesCalendarResponseDTO, NetworkError>) in
            defer { self.isLoading = false }
            
            switch result {
            case .success(let responseDTO):
                let newResult: [UpdateFriendCalendarModel] = responseDTO.dailyNewsResult.compactMap { item -> UpdateFriendCalendarModel? in
                    DispatchQueue.main.async {
                        self.updateFriendCalendarView.subTitle.text = item.date
                    }

                    guard let eventImageURLString = item.imageUrl,
                          let eventImageURL = URL(string: eventImageURLString) else {
                        print("Invalid event image URL for item: \(item.clokeyId)")
                        return nil
                    }

                    let profileImageURL = URL(string: item.profileImage)

                    return UpdateFriendCalendarModel(
                        imageUrl: eventImageURL,
                        name: item.clokeyId,
                        profileImage: profileImageURL
                    )
                }

                if isNextPage {
                    self.modelData.append(contentsOf: newResult)
                    self.currentPage = nextPage
                } else {
                    self.modelData = newResult
                    self.currentPage = 1
                }

                self.hasMorePages = !newResult.isEmpty 

                DispatchQueue.main.async {
                    self.updateFriendCalendarView.updateFriendCalendarCollectionView.reloadData()
                    self.updateCollectionViewHeight()
                }

            case .failure(let error):
                print("Failed to load calendar data: \(error)")
            }
        }
    }
}

extension UpdateFriendCalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UpdateFriendCalendarCollectionViewCell.identifier,
            for: indexPath
        ) as? UpdateFriendCalendarCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        // 모델 데이터로 셀 구성
        let item = modelData[indexPath.row]
        if let url = item.imageUrl as URL? {
            cell.imageView.kf.setImage(with: url) // Kingfisher를 사용한 이미지 설정
        } else {
            cell.imageView.image = UIImage(named: "placeholder") // 기본 이미지
        }
        
        if let profileUrl = item.profileImage {
            cell.iconImageView.kf.setImage(
                with: profileUrl,
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
            cell.iconImageView.image = UIImage(named: "profile_placeholder") // 기본 이미지
        }
        
        cell.titleLabel.text = item.name
        
        return cell
    }
}
