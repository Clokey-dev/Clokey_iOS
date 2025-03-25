//
//  UpdateFriendCalendarViewController.swift
//  Clokey
//
//  Created by 한금준 on 1/17/25.
//

// 완료

import UIKit
import Kingfisher

class UpdateFriendCalendarViewController: UIViewController, UIGestureRecognizerDelegate,  UICollectionViewDelegate {
    private let navBarManager = NavigationBarManager()
    
    private let updateFriendCalendarView = UpdateFriendCalendarView()
    private var modelData: [UpdateFriendCalendarModel] = []
    
    private var currentPage = 1
    private var isLoading = false
    private var hasMorePages = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = updateFriendCalendarView
        setupNavigationBar()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        setupDelegate()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        DispatchQueue.main.async {
            self.updateFriendCalendarView.updateFriendCalendarCollectionView.reloadData()
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
            let fullText = "친구의 캘린더 업데이트 소식"
            let targetText = "캘린더"
            let attributedString = NSMutableAttributedString(string: fullText)
            
            // 전체 텍스트 스타일
            attributedString.addAttributes([
                .font: UIFont.ptdMediumFont(ofSize: 20),
                .foregroundColor: UIColor.black
            ], range: NSRange(location: 0, length: fullText.count))
            
            // "옷장"에 다른 스타일 적용
            if let targetRange = fullText.range(of: targetText) {
                let nsRange = NSRange(targetRange, in: fullText)
                attributedString.addAttributes([
                    .font: UIFont.ptdSemiBoldFont(ofSize: 20), // 예시로 굵게 처리
                    .foregroundColor: UIColor.black // 색상을 변경하려면 여기 설정
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
        updateFriendCalendarView.updateFriendCalendarCollectionView.layoutIfNeeded()
        let contentHeight = updateFriendCalendarView.updateFriendCalendarCollectionView.contentSize.height
        print("Content Height: \(contentHeight)") // 디버깅용 출력
        
        updateFriendCalendarView.updateFriendCalendarCollectionView.snp.updateConstraints { make in
            make.height.equalTo(contentHeight)
        }
    }
    
    private func setupDelegate() {
        updateFriendCalendarView.updateFriendCalendarCollectionView.dataSource = self
        updateFriendCalendarView.updateFriendCalendarCollectionView.delegate = self
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedUpdate = modelData[indexPath.item]
        print("Selected Update: \(selectedUpdate.name)")
        let followProfileVC = FollowProfileViewController(followId: selectedUpdate.name)
        navigationController?.pushViewController(followProfileVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == modelData.count - 1 {
            loadData(isNextPage: true)
        }
    }
}
