//
//  TagClothView.swift
//  Clokey
//
//  Created by 황상환 on 1/31/25.
//

import Foundation
import UIKit
import SnapKit
import Then

final class TagClothView: UIView, SortDropdownViewDelegate {

    // MARK: - Properties
    
    // 커스텀 세그먼트 뷰
    let customTotalSegmentView = CustomTotalSegmentView(items: ["전체", "상의", "하의", "아우터", "기타"])
    
    var dropdownView: CustomSortDropdownView?
    weak var delegate: AnyObject? 

    // 검색 필드
    let searchField: CustomSearchField = {
        let field = CustomSearchField()
        return field
    }()
    
    // 정렬 버튼과 컬렉션 뷰를 함께 감싸는 컨텐츠 뷰 (위치 변경 시 함께 이동하도록 설정)
    let contentView = UIView()

    // 정렬 라벨
    private let sortButtonLabel: UILabel = {
        let label = UILabel()
        label.text = "착용순"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    // 정렬 아이콘
    private let sortButtonIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .black
        return imageView
    }()
    
    // 정렬 버튼
    private let sortButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        return button
    }()
    
    // 정렬 버튼 + 아이콘 스택뷰
    private let sortButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()
    
    // 컬렉션 뷰
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumInteritemSpacing = 10
        $0.minimumLineSpacing = 20
        $0.estimatedItemSize = .zero  // 셀 크기 자동 조정 비활성화
        
        // 한 줄에 3개 배치
        let totalMargin: CGFloat = 40  // 좌우 inset 20씩
        let interitemSpacing: CGFloat = 10 * 2  // 아이템 간 간격
        let availableWidth = UIScreen.main.bounds.width - totalMargin - interitemSpacing
        let itemWidth = availableWidth / 3  // 3등분

        // 4:3 비율 유지
        let imageHeight = itemWidth * (4.0/3.0)
        let labelHeight: CGFloat = 20
        let itemHeight = imageHeight + 5 + labelHeight

        $0.itemSize = CGSize(width: itemWidth, height: itemHeight) // 셀 크기 고정
    }).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = true  // 스크롤 활성화
        $0.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .white

        // UI
        addSubview(customTotalSegmentView)
        addSubview(searchField)
        addSubview(contentView)

        contentView.addSubview(sortButtonStack)
        contentView.addSubview(collectionView)

        // 내 옷 검색하기
        searchField.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // 커스텀 세그먼트
        customTotalSegmentView.snp.makeConstraints {
            $0.top.equalTo(searchField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(90)
        }

        // 정렬버튼 + 컬렉션 뷰
        contentView.snp.makeConstraints {
            $0.top.equalTo(customTotalSegmentView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // 정렬 버튼
        sortButtonStack.addArrangedSubview(sortButtonLabel)
        sortButtonStack.addArrangedSubview(sortButtonIcon)
        sortButtonStack.addSubview(sortButton)

        sortButtonIcon.snp.makeConstraints {
            $0.width.equalTo(15)
            $0.height.equalTo(18)
        }

        // 정렬 버튼 - contentView 내부
        sortButtonStack.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(30)
        }

        sortButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // 컬렉션 뷰 - 정렬 버튼 하단
        collectionView.snp.makeConstraints {
            $0.top.equalTo(sortButtonStack.snp.bottom).offset(5)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // 드롭다운 설정
        sortButton.addTarget(self, action: #selector(toggleDropdown), for: .touchUpInside)
    }

    // MARK: - 정렬 옵션 드롭다운 관련 기능

    // 드롭다운 표시 토글
    @objc private func toggleDropdown() {
        if dropdownView == nil {
            showDropdown()
        } else {
            hideDropdown()
        }
    }

    // 드롭다운 표시
    private func showDropdown() {
        let dropdown = CustomSortDropdownView(selectedOption: sortButtonLabel.text ?? "착용순")
        dropdown.delegate = self
        dropdownView = dropdown
        
        addSubview(dropdown)
        
        dropdown.snp.makeConstraints {
            $0.top.equalTo(sortButtonStack.snp.bottom).offset(5)
            $0.trailing.equalTo(sortButtonStack)
            $0.width.equalTo(160)
            $0.height.equalTo(180)
        }
    }

    // 드롭다운 숨김
    private func hideDropdown() {
        dropdownView?.removeFromSuperview()
        dropdownView = nil
    }

    // 정렬 옵션 선택 시 처리
    func didSelectSortOption(_ option: String) {
        sortButtonLabel.text = option
        hideDropdown()
        (delegate as? SortDropdownViewDelegate)?.didSelectSortOption(option)
    }
}


