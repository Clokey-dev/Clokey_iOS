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
    private var detailData: HistoryDetailResponseDTO?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if let detailData = detailData {
            calendarDetailView.configure(with: detailData) // UI 업데이트
        }
    }

    func setDetailData(_ data: HistoryDetailResponseDTO) {
        self.detailData = data
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(calendarDetailView)
        
        calendarDetailView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
