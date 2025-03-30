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

class UpdateFriendClothesViewController: UIViewController, UIGestureRecognizerDelegate {
    private let navBarManager = NavigationBarManager()
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
        setupNavigationBar()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        setupDelegate()
        loadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        DispatchQueue.main.async {
            self.updateFriendClothesView.updateFriendClothesCollectionView.reloadData()
            self.updateCollectionViewHeight()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // 네비게이션 설정
    private func setupNavigationBar() {
        let backButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: config)
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .mainBrown800
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        let titleLabel: UILabel = UILabel().then {
                let fullText = "팔로우 중인 옷장 업데이트 소식"
                let targetText = "옷장"
                let attributedString = NSMutableAttributedString(string: fullText)
        
                // 전체 텍스트 스타일
                attributedString.addAttributes([
                    .font: UIFont.ptdMediumFont(ofSize: 20),
                    .foregroundColor: UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0)
                ], range: NSRange(location: 0, length: fullText.count))
        
                // "캘린더"에 다른 스타일 적용
                if let targetRange = fullText.range(of: targetText) {
                    let nsRange = NSRange(targetRange, in: fullText)
                    attributedString.addAttributes([
                        .font: UIFont.ptdSemiBoldFont(ofSize: 20), // 예시로 굵게 처리
                        .foregroundColor: UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0) // 색상을 변경하려면 여기 설정
                    ], range: nsRange)
                }
        
                $0.attributedText = attributedString
            }

        let titleItem = UIBarButtonItem(customView: titleLabel)

        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: backButton), titleItem]
    }
    
    // 뒤로가기
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

                self.hasMorePages = nextPage < 3

                DispatchQueue.main.async {
                    self.isLoading = false
                    self.updateFriendClothesView.updateFriendClothesCollectionView.reloadData()
                    self.updateCollectionViewHeight()
                }

            case .failure(let error):
                print("Failed to load calendar data: \(error)")
                self.showAlert(title: "네트워크 오류", message: "인터넷 연결이 원활하지 않아요.\n잠시 후 다시 시도해 주세요.")
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
                            self.showAlert(title: "네트워크 오류", message: "인터넷 연결이 원활하지 않아요.\n잠시 후 다시 시도해 주세요.")
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
                        self.showAlert(title: "네트워크 오류", message: "인터넷 연결이 원활하지 않아요.\n잠시 후 다시 시도해 주세요.")
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
        let displayAllVC = DisplayAllViewController()
        displayAllVC.clokeyId = selectedUpdate.name
        navigationController?.pushViewController(displayAllVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == updates.count - 1 {
            loadData(isNextPage: true)
        }
    }
}
