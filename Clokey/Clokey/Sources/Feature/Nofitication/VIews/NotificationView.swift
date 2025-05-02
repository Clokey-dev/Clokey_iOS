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
        
       
        addSubview(tableView)


        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(28)
            
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
}
extension UIButton {
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // 터치 영역을 확장할 여분의 크기 (예: 상하좌우 10pt씩 확장)
        let margin: CGFloat = 10
        let largerArea = bounds.insetBy(dx: -margin, dy: -margin)
        return largerArea.contains(point)
    }
}
