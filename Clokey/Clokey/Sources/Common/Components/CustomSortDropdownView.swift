//
//  SortDropdownView.swift
//  TestCollection
//
//  Created by 황상환 on 1/31/25.
//

import Foundation
import UIKit
import SnapKit
import Then

// 정렬 옵션 선택 시 호출되는 프로토콜
protocol SortDropdownViewDelegate: AnyObject {
    func didSelectSortOption(_ option: String)
}

class CustomSortDropdownView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    // 드롭다운 내 리스트를 표시하는 UITableView
    private let tableView = UITableView().then {
        $0.register(SortDropdownCell.self, forCellReuseIdentifier: "SortDropdownCell") // 커스텀 셀 등록
        $0.separatorStyle = .none  // 기본 separator 제거
        $0.isScrollEnabled = false // 리스트 높이 고정
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .white
        
        $0.rowHeight = 44
        $0.estimatedRowHeight = 44
    }
    
    // 드롭다운 옵션 목록
    private let options = ["착용순", "미착용순", "최신등록순", "오래된순"]
    
    // 현재 선택된 옵션
    private var selectedOption: String
    
    // 정렬 옵션 선택 시 동작할 delegate
    weak var delegate: SortDropdownViewDelegate?
    
    
    // MARK: - Init
    
    init(selectedOption: String) {
        self.selectedOption = selectedOption
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    // UI 설정
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 5
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addSubview(tableView)
    
        // 드롭다운 메뉴 경계 맞추기
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - UITableView DataSource & Delegate
    
    // 테이블 뷰의 셀 개수 반환 -> options.count로 반환
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    // 테이블 뷰 셀 메서드
    // SortDropdownCell에서 셀을 가져와서 띄움
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortDropdownCell", for: indexPath) as! SortDropdownCell
        let option = options[indexPath.row]
        
        // 마지막 아아탬 선택해서 언더바 유무 확인
        let isLast = indexPath.row == options.count - 1
        cell.configure(with: option, isSelected: option == selectedOption, isLast: isLast)
        
        return cell
    }
    
    // 사용자가 정렬 옵션을 선택 시 동작 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOption = options[indexPath.row]
        delegate?.didSelectSortOption(selectedOption) // 옵션 선택
        
        tableView.reloadData() // UI 업데이트
    }
    
    // MARK: - 커스텀 셀 클래스
    
    // 드롭다운 리스트 셀
    class SortDropdownCell: UITableViewCell {
        
        // 옵션 라벨
        private let titleLabel = UILabel().then {
            $0.textColor = .black
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
        
        // 선택된 옵션 체크 이미지
        private let checkmarkImageView = UIImageView().then {
            $0.image = UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = UIColor.mainBrown800
            $0.isHidden = true
        }
        
        // 리스트 구분선
        private let separatorView = UIView().then {
            $0.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        }
        
        // MARK: - sell Init
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupCell()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        // MARK: - sell Setup
        
        private func setupCell() {
            backgroundColor = .white
            selectionStyle = .none
            
            contentView.addSubview(titleLabel)
            contentView.addSubview(checkmarkImageView)
            contentView.addSubview(separatorView)
            
            // 체크마크 이미지
            checkmarkImageView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().offset(16)
            }
            
            // 옵션 라벨
            titleLabel.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalTo(checkmarkImageView.snp.trailing).offset(8)
            }
            
            // 리스트 구분선
            separatorView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.height.equalTo(1)
            }
        }
        
        // 셀의 내용을 업데이트하는 메서드
        func configure(with title: String, isSelected: Bool, isLast: Bool) {
            titleLabel.text = title
            checkmarkImageView.isHidden = !isSelected
            separatorView.isHidden = isLast
        }
    }
}
