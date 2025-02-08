//
//  TagClothViewController.swift
//  Clokey
//
//  Created by 황상환 on 1/24/25.
//

import UIKit
import SnapKit
import Then

// MARK: - Protocol
// 태그된 아이템을 선택했을 때 델리게이트를 통해 전달하는 프로토콜
protocol TagClothViewControllerDelegate: AnyObject {
    func didSelectTags(_ tags: [(image: UIImage, title: String)])
}

class TagClothViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Properties
    weak var delegate: TagClothViewControllerDelegate?

    // 선택된 옷 저장 배열
    private var selectedItems: [(image: UIImage, title: String)] = [] {
        didSet {
            updateConfirmButtonState()
        }
    }

    // TagClothView 뷰
    private let tagClothView = TagClothView()

    // 현재 옷 목록 데이터
    private var clothItems: [TagClothModel] = []

    // 확인버튼
    private lazy var confirmButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(confirmButtonTapped))
        button.isEnabled = false // 비활성화
        button.tintColor = .clear
        return button
    }()

    // MARK: - Lifecycle

    override func loadView() {
        view = tagClothView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        loadDummyData() // 더미 데이터 로드
        loadInitialData()
        setupSegmentedControl()
    }

    // 뷰가 다시 그려질 때, 인디케이터 위치 업데이트
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let initialIndex = tagClothView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
        tagClothView.customTotalSegmentView.updateIndicatorPosition(for: initialIndex)
    }

    // MARK: - Setup Methods

    private func setupUI() {
        navigationItem.rightBarButtonItem = confirmButton

        // 커스텀 네비게이션 버튼/타이틀
        let navBarManager = NavigationBarManager()
        navBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        navBarManager.setTitle(
            to: navigationItem,
            title: "태그하기",
            font: .ptdBoldFont(ofSize: 20),
            textColor: .black
        )
    }

    private func setupCollectionView() {
        tagClothView.collectionView.delegate = self
        tagClothView.collectionView.dataSource = self
        tagClothView.collectionView.allowsMultipleSelection = true
    }

    private func setupSegmentedControl() {
        // 세그먼트 선택 변경 시 이벤트 리스너 등록
        tagClothView.customTotalSegmentView.segmentedControl.addTarget(
            self,
            action: #selector(segmentChanged(_:)),
            for: .valueChanged
        )
    }

    // MARK: - Data Handling

    // 초기 데이터 로드
    private func loadDummyData() {
        clothItems = TagClothModel.getDummyData(for: 0)
        tagClothView.collectionView.reloadData()
    }

    private func loadInitialData() {
        let initialIndex = tagClothView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
        updateContent(for: initialIndex)
    }

    // 선택된 세그먼트에 따라 컬렉션 뷰 위치 업데이트
    private func updateContent(for index: Int) {
        if index == 0 { // 전체 선택 시
            clothItems = TagClothModel.getDummyData(for: index)
            tagClothView.customTotalSegmentView.toggleCategoryButtons(isHidden: true)

            tagClothView.contentView.snp.remakeConstraints {
                $0.top.equalTo(tagClothView.customTotalSegmentView.divideLine.snp.bottom).offset(10)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.bottom.equalToSuperview()
            }
        } else {
            // 전체 외 나머지 설정
            if let category = CustomCategoryModel.getCategories(for: index) {
                clothItems = TagClothModel.getDummyData(for: index)

                tagClothView.customTotalSegmentView.toggleCategoryButtons(isHidden: false)
                tagClothView.customTotalSegmentView.updateCategories(for: category.buttons)

                tagClothView.contentView.snp.remakeConstraints {
                    $0.top.equalTo(tagClothView.customTotalSegmentView.categoryScrollView.snp.bottom)
                    $0.leading.trailing.equalToSuperview().inset(20)
                    $0.bottom.equalToSuperview()
                }
            }
        }
        // reloadData 호출을 여기서만 하고
        tagClothView.collectionView.reloadData()
        
        // 선택 상태 복원
        for (index, item) in clothItems.enumerated() {
            if selectedItems.contains(where: { $0.title == item.name }) {
                let indexPath = IndexPath(item: index, section: 0)
                tagClothView.collectionView.selectItem(
                    at: indexPath,
                    animated: false,
                    scrollPosition: []
                )
            }
        }
    }

    // MARK: - Button State
    // 확인버튼 활성화 메서드
    private func updateConfirmButtonState() {
        if selectedItems.isEmpty {
            confirmButton.isEnabled = false
            confirmButton.tintColor = .clear
        } else {
            confirmButton.isEnabled = true
            confirmButton.tintColor = UIColor(named: "pointOrange800")
        }
    }
    
    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clothItems.count
    }

    // CustomCollectionViewCell 사용해서 컬렉션 뷰 구현
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CustomCollectionViewCell.identifier,
            for: indexPath
        ) as? CustomCollectionViewCell else {
            fatalError("Failed to dequeue CustomCollectionViewCell")
        }

        // 옷 정보 설정
        let item = clothItems[indexPath.item]
        cell.numberLabel.text = "\(indexPath.item + 1)"
        cell.countLabel.text = "\(item.count)회"
        cell.nameLabel.text = item.name
        cell.productImageView.image = item.image
        
        // 셀의 선택 상태 설정
        let isSelected = selectedItems.contains(where: { $0.title == item.name })
        cell.setSelected(isSelected)

        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell else { return }
        
        let item = clothItems[indexPath.item]
        
        // 이미 선택된 아이템인지 확인
        if selectedItems.contains(where: { $0.title == item.name }) {
            // 이미 선택된 아이템이면 선택 해제
            cell.setSelected(false)
            selectedItems.removeAll { $0.title == item.name }
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            // 선택되지 않은 아이템이면 선택
            cell.setSelected(true)
            selectedItems.append((image: item.image, title: item.name))
        }
        
        updateConfirmButtonState()
    }

    // MARK: - Actions

    // 뒤로 가기 버튼 동작
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }

    // 확인버튼 클릭 시 선택된 태그를 델리게이트를 통해 전달하고 뷰 닫기
    @objc private func confirmButtonTapped() {
        // 선택된 아이템에서 필요한 정보만 전달
        let selectedData = selectedItems.map { item in
            // numberLabel과 countLabel 관련 데이터는 전달하지 않음
            (image: item.image, title: item.title)
        }
        delegate?.didSelectTags(selectedData)
        dismiss(animated: true)
    }
    
    // 세그먼트 컨트롤 변경 시 호출되는 메서드
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        tagClothView.customTotalSegmentView.updateIndicatorPosition(for: index)
        updateContent(for: index)
    }
}
