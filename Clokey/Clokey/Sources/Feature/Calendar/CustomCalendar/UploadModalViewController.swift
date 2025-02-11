//
//  UploadModalViewController.swift
//  Clokey
//
//  Created by 황상환 on 1/20/25.
//

import UIKit
import SnapKit

class UploadModalViewController: UIViewController {
    
    private var selectedDate: Date?
    
    private let modalView = UploadModalView()
    // Modal이 Calendar를 약하게 참조.
    weak var sourceViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.7)
        setupModalView()
        setupActions()
    }
    
    private func setupModalView() {
        view.addSubview(modalView)
        modalView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(400)
        }
        
    }
    
    func setDate(_ date: Date) {
        self.selectedDate = date
        modalView.setDate(date)
    }
    
    private func setupActions() {
       modalView.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        modalView.getAddButton().addTarget(self,
                                         action: #selector(addButtonTapped),
                                         for: .touchUpInside)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    // OOTD 기록페이지로 네비게이션
    @objc private func addButtonTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let recordVC = RecordOOTDViewController()
            if let date = self.selectedDate {
                recordVC.setDate(date)
            }
            self.sourceViewController?.navigationController?.pushViewController(recordVC, animated: true)
        }
    }
}
