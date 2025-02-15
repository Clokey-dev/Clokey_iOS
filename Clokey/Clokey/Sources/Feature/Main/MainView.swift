//
//  MainView.swift
//  Clokey
//
//  Created by 황상환 on 1/10/25.
//

import UIKit
import SnapKit
import Then

final class MainView: UIView {
    
    // MARK: - UI Components
    let headerView = HeaderView()
    let contentView = UIView()
    let tabBarView = TabBarView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        [headerView, contentView, tabBarView].forEach { addSubview($0) }
    }
    
    private func setupConstraints() {
        
        headerView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(50)
        }
        
        // 화면 내용
        contentView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBarView.snp.top)
        }
        
        // 하단바
        tabBarView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    // HeaderView 표시/숨김 메서드
    func setHeaderViewHidden(_ isHidden: Bool) {
        headerView.isHidden = isHidden
        
        // 헤더뷰 제약조건
        if isHidden {
            headerView.snp.updateConstraints {
                $0.height.equalTo(0) // headerView 높이 0
            }
            contentView.snp.remakeConstraints {
                $0.top.equalTo(safeAreaLayoutGuide)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(tabBarView.snp.top)
            }
        } else {
            headerView.snp.updateConstraints {
                $0.height.equalTo(50) // headerView 높이 0
            }
            contentView.snp.remakeConstraints {
                $0.top.equalTo(headerView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(tabBarView.snp.top)
            }
        }
        
    }
}
