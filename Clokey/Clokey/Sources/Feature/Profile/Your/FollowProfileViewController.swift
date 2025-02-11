//
//  FollowProfileViewController.swift
//  Clokey
//
//  Created by 한금준 on 1/29/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

class FollowProfileViewController: UIViewController {

    // MARK: - Properties
    private let followProfileView = FollowProfileView()
    
    private let model = FollowProfileModel.dummy()
    
    // MARK: - Lifecycle
    override func loadView() {
        view = followProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followProfileView.scrollView.contentInsetAdjustmentBehavior = .never

//        bindData()
        fetchClothes()
        fetchCalendar()
    }
    
    private func bindData() {
        // 데이터를 PickView에 바인딩
        followProfileView.clothesImageView1.kf.setImage(with: URL(string: model.profileImageURLs[0]))
        followProfileView.clothesImageView2.kf.setImage(with: URL(string: model.profileImageURLs[1]))
        followProfileView.clothesImageView3.kf.setImage(with: URL(string: model.profileImageURLs[2]))
    }
    
    func fetchClothes() {
        // 공개 여부 확인 (예제: model.isPublic이 true일 때만 가져옴)
        guard model.isPublic else {
            // 비공개 상태일 경우 UI를 비우기
            followProfileView.updateClothesPrivateState(isPrivate: true)
            return
        }
        
        // 모델에서 이미지 URL 가져오기
        let recommendedClothes: [String] = model.profileImageURLs
        
        // UI 업데이트 (비어 있는지 확인)
        followProfileView.updateClothesPrivateState(isPrivate: recommendedClothes.isEmpty)
        
        // 이미지 설정
        if !recommendedClothes.isEmpty {
            followProfileView.clothesImageView1.kf.setImage(with: URL(string: recommendedClothes[0]))
            followProfileView.clothesImageView2.kf.setImage(with: URL(string: recommendedClothes[1]))
            followProfileView.clothesImageView3.kf.setImage(with: URL(string: recommendedClothes[2]))
        }
    }
    
    func fetchCalendar() {
        // 공개 여부 확인 (예제: model.isPublic이 true일 때만 가져옴)
        guard model.isPublic else {
            // 비공개 상태일 경우 privateStackView 표시
            followProfileView.updateCalendarPrivateState(isPrivate: true)
            return
        }

        // 공개 상태일 경우 기존 UI 유지
        followProfileView.updateCalendarPrivateState(isPrivate: false)
    }

}
