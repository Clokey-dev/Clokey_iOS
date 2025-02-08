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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.updateFriendCalendarView.updateFriendCalendarCollectionView.reloadData()
            self.updateCollectionViewHeight()
        }
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
    
    private func loadData() {
        modelData = UpdateFriendCalendarModel.dummy()
        for item in modelData {
            guard let url = item.imageUrl as URL? else {
                print("Invalid URL for item: \(item.name)")
                continue
            }
            print("Loaded data: \(item.name), imageUrl: \(url.absoluteString)")
        }
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
