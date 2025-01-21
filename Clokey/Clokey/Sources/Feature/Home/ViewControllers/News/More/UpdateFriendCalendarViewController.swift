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
    private var modelData: [UpdateFriendCalendarModel] = [] // 데이터 캐싱
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = updateFriendCalendarView
        
        setupDelegate()
        loadData()
    }
    
    private func setupDelegate() {
        updateFriendCalendarView.updateFriendCalendarCollectionView.dataSource = self
    }
    
    private func loadData() {
        // 데이터를 로드하고 컬렉션 뷰를 리로드
        modelData = UpdateFriendCalendarModel.dummy()
        updateFriendCalendarView.updateFriendCalendarCollectionView.reloadData()
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
        cell.titleLabel.text = item.name
        
        return cell
    }
}
