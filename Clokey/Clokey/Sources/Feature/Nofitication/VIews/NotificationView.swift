//
//  NotificationView.swift
//  Clokey
//
//  Created by 소민준 on 2/11/25.
//

//
//  NotificationView.swift
//  Alarm
//
//  Created by 소민준 on 2/11/25.
//

import UIKit
import SnapKit

class NotificationView: UIView {
    
    //  뒤로 가기 버튼
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "goback"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    //  타이틀 라벨
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "알림"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    //  테이블 뷰
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NotificationCell.self, forCellReuseIdentifier: "NotificationCell")
        
        return tableView
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(tableView)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(10) //  width 고정
            make.height.equalTo(20) //  height 고정
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.leading.equalTo(backButton.snp.trailing).offset(20)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(18)
            
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
