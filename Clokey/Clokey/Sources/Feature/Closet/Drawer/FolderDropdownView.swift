//
//  FolderDropdownView.swift
//  Clokey
//
//  Created by 한태빈 on 2/8/25.
//
import UIKit
import SnapKit
import Then

// 드롭다운 옵션 선택 시 호출되는 프로토콜
protocol FolderDropdownViewDelegate: AnyObject {
    func didSelectEditFolder()   // "폴더 편집하기" 선택 시 호출
    func didSelectDeleteFolder() // "폴더 삭제하기" 선택 시 호출
}

class FolderDropdownView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    // 드롭다운 내 리스트를 표시하는 UITableView
    private let tableView = UITableView().then {
        $0.register(FolderDropdownCell.self, forCellReuseIdentifier: "FolderDropdownCell")
        $0.separatorStyle = .none  // 기본 separator 제거
        $0.isScrollEnabled = false // 스크롤 비활성화
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .white
        
        // 두 옵션이므로 각 셀의 높이를 (75 / 2)로 설정
        $0.rowHeight = 37.5
        $0.estimatedRowHeight = 37.5
    }
    
    // 드롭다운 옵션 목록
    private let options = ["폴더 편집하기", "폴더 삭제하기"]
    
    // 현재 선택된 옵션 (초기값은 "폴더 편집하기")
    private var selectedOption: String
    
    // 옵션 선택 시 동작할 delegate
    weak var delegate: FolderDropdownViewDelegate?
    
    // 전체 사이즈: width 143, height 75
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 143, height: 75)
    }
    
    // MARK: - Init
    
    init(selectedOption: String = "폴더 편집하기") {
        self.selectedOption = selectedOption
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 10
        // 그림자 설정 (위 코드와 동일)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 5
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addSubview(tableView)
        // 드롭다운 메뉴 전체 크기에 맞추어 tableView 제약 설정
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - UITableView DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    // 셀 구성 (마지막 셀은 구분선 숨김 처리)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderDropdownCell", for: indexPath) as! FolderDropdownCell
        let option = options[indexPath.row]
        let isLast = indexPath.row == options.count - 1
        cell.configure(with: option, isSelected: option == selectedOption, isLast: isLast)
        return cell
    }
    
    // 옵션 선택 시 delegate 호출하여 네비게이션 동작 수행
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOption = options[indexPath.row]
        
        if indexPath.row == 0 {
            // "폴더 편집하기" 선택: DrawerEditViewController로 이동
            delegate?.didSelectEditFolder()
        } else if indexPath.row == 1 {
            // "폴더 삭제하기" 선택: ClosetViewController로 이동
            delegate?.didSelectDeleteFolder()
        }
        
        tableView.reloadData() // UI 업데이트
    }
    
    // MARK: - 커스텀 셀 클래스
    
    class FolderDropdownCell: UITableViewCell {
        
        
        
        // 옵션 아이콘 이미지 뷰 (연필 또는 휴지통)
           private let iconImageView = UIImageView().then {
               $0.contentMode = .scaleAspectFit
           }
        
        // 옵션 라벨
        private let titleLabel = UILabel().then {
            $0.textColor = .black
            $0.font = UIFont.ptdMediumFont(ofSize: 14)
        }
        
        // 리스트 구분선
        private let separatorView = UIView().then {
            $0.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        }
        
        // MARK: - 셀 Init
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupCell()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - 셀 Setup
        
        private func setupCell() {
            backgroundColor = .white
            selectionStyle = .none
            
            contentView.addSubview(iconImageView)
            contentView.addSubview(titleLabel)
            contentView.addSubview(separatorView)
            
            
            iconImageView.snp.makeConstraints { make in
                        make.centerY.equalToSuperview()
                        make.leading.equalToSuperview().offset(16)
                        make.width.height.equalTo(20) // 아이콘 크기 조정 가능
                    }
            
            // 옵션 라벨 제약
            titleLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            }
            
            // 구분선 제약 (마지막 셀인 경우 숨김)
            separatorView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
                make.height.equalTo(1)
            }
        }
        
        func configure(with title: String, isSelected: Bool, isLast: Bool) {
            titleLabel.text = title
            separatorView.isHidden = isLast
            
            // 옵션에 따라 아이콘 이미지 변경
            if title == "폴더 편집하기" {
                iconImageView.image = UIImage(named: "write_icon")?.withRenderingMode(.alwaysTemplate)
                iconImageView.tintColor = UIColor.mainBrown800 // 기존 색상 사용
            } else if title == "폴더 삭제하기" {
                iconImageView.image = UIImage(named: "trash_icon")?.withRenderingMode(.alwaysTemplate)
                iconImageView.tintColor = UIColor.mainBrown800
            }
        }
    }
}
