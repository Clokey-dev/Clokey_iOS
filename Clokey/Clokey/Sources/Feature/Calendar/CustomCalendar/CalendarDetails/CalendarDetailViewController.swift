//
//  CalendarDetailViewController.swift
//  Clokey
//
//  Created by 황상환 on 2/1/25.
//

import Foundation
import UIKit

class CalendarDetailViewController: UIViewController {
    
    private let calendarDetailView = CalendarDetailView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupData()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(calendarDetailView)
        
        calendarDetailView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupData() {
        // 예제 이미지 데이터 설정
        let sampleImages = ["test_cloth", "test_cloth", "test_cloth"]
        calendarDetailView.configureImages(sampleImages)
        
        // 예제 해시태그 데이터 설정
        let sampleHashtags = ["#연말룩", "#파티룩", "#원피스", "#2025년도 화이팅"]
        calendarDetailView.configureHashtags(sampleHashtags)
    }
}
