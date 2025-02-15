//
//  ProfileViewController.swift
//  Clokey
//
//  Created by 황상환 on 1/10/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class ProfileViewController: UIViewController {
    private let mainView = MainView()
    // MARK: - Properties
    private let profileView = ProfileView()
    
    private let model = ProfileModel.dummy()
    
    private let membersService = MembersService()
    
    // MARK: - Lifecycle
    override func loadView() {
        
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.scrollView.contentInsetAdjustmentBehavior = .never
        fetchUserProfile(clokeyId: "john_doe123") // 사용자 임시 아이디

        bindData()
    }
    
    // 회원 조회
    private func fetchUserProfile(clokeyId: String) {
        membersService.getUserProfile(clokeyId: clokeyId) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                print("프로필 정보 가져오기 성공: \(response)")
                self.profileView.configure(with: response) // 데이터 전달
                
            case .failure(let error):
                print("프로필 정보 가져오기 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func bindData() {
        // 데이터를 PickView에 바인딩
        profileView.clothesImageView1.kf.setImage(with: URL(string: model.profileImageURLs[0]))
        profileView.clothesImageView2.kf.setImage(with: URL(string: model.profileImageURLs[1]))
        profileView.clothesImageView3.kf.setImage(with: URL(string: model.profileImageURLs[2]))
    }
}
