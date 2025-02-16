//
//  TagClothViewController.swift
//  Clokey
//
//  Created by 황상환 on 1/24/25.
//

import UIKit
import SnapKit
import Then

protocol TagClothViewControllerDelegate: AnyObject {
    func didSelectTags(_ tags: [(id: Int, image: UIImage, title: String)])
}

class TagClothViewController: UIViewController {
    
    // MARK: - Types
    
    // 정렬 타입 설정
    private enum SortOption: String {
        case wear = "WEAR"
        case notWear = "NOT_WEAR"
        case latest = "LATEST"
        case oldest = "OLDEST"
        
        static func from(_ text: String) -> SortOption {
            switch text {
            case "착용순": return .wear
            case "미착용순": return .notWear
            case "최신등록순": return .latest
            case "오래된순": return .oldest
            default: return .wear
            }
        }
    }
    
    // MARK: - Properties
    
    // 태그 선택 완료된 데이터를 전달하는 delegate 프로토콜
    weak var delegate: TagClothViewControllerDelegate?
    
    // 사용자가 선택한 의류 태그 리스트
    private var selectedItems: [(id: Int, image: UIImage, title: String)] = [] {
        didSet { updateConfirmButtonState() } // 확인 버튼 활성화/비활성화 설정
    }
    
    // 정렬 옵션 초기화
    private var currentSort: SortOption = .wear
    
    // 의류 리스트 - 검색/정렬/필터링 때 사용
    private var clothItems: [TagClothModel] = []
    
    // 서버에서 받아온 원본 의류 데이터
    private var originalClothItems: [TagClothModel] = []
    
    // 검색 필드 초기화
    private var currentSearchText: String = ""
    
    // API Service
    private let clothesService = ClothesService()
    
    // TODO: 임시 데이터로 토큰으로 교체 예정
//    private let clokeyId = "dbrdldh11"
    
    // TagClothView 뷰
    let tagClothView = TagClothView()
    
    // 현재 선택된 카테고리 ID 변수 추가
    private var currentMainCategoryId: Int = 0
    private var currentSubCategoryId: Int? = nil
    
    // 서버에서 받아온 옷 데이터 페이징 변수들
    private var currentPage = 1
    private var isLoading = false
    private var hasMorePages = true
    
    // 확인 버튼
    private lazy var confirmButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "확인", style: .done,
                                     target: self,
                                     action: #selector(confirmButtonTapped))
        button.isEnabled = false
        button.tintColor = .clear
        return button
    }()
    
    // MARK: - Lifecycle Methods
    override func loadView() {
        view = tagClothView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInitialSetup()
        setupKeyboardDismissGestures() // 키보드 제스처 설정
        tagClothView.customTotalSegmentView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateInitialIndicatorPosition() // 카테고리 위치 업데이트
    }
    
    // MARK: - Configuration Methods
    private func configureInitialSetup() {
        setupNavigationBar() // 최상단 네비게이션 바
        setupCollectionView() // 옷 컬렉션 뷰
        setupSegmentedControl() // 카테고리 세그먼트 컨트롤
        setupSearchField() // 검색 기능
        configureTagClothView() // TagClothView의 delegate 설정
        
        // 카테고리 데이터 불러오기 설정
        DispatchQueue.main.async {
            self.updateContent(for: 0)
        }
    }
    
    // 네비게이션 설정
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = confirmButton
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
    
    // 셀 선택 및 데이터 로딩 처리
    private func setupCollectionView() {
        tagClothView.collectionView.delegate = self
        tagClothView.collectionView.dataSource = self
        tagClothView.collectionView.allowsMultipleSelection = true
    }
    
    // 세그먼트 컨트롤 (카테고리 선택 UI) 설정
    private func setupSegmentedControl() {
        let segmentedControl = tagClothView.customTotalSegmentView.segmentedControl
        segmentedControl.addTarget(
            self,
            action: #selector(segmentChanged(_:)),
            for: .valueChanged
        )
        segmentedControl.selectedSegmentIndex = 0 // 기본을 전체로
    }
    
    // TagClothView에서 발생하는 이벤트 처리
    private func configureTagClothView() {
        tagClothView.delegate = self
    }
    
    // 세그먼트 컨트롤 하단 선택 인디케이터 위치 초기화
    private func updateInitialIndicatorPosition() {
        let initialIndex = tagClothView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
        tagClothView.customTotalSegmentView.updateIndicatorPosition(for: initialIndex)
    }
    
    // MARK: - API (Data Handling)
    private func loadClothesData(categoryId: Int = 0, isNextPage: Bool = false, season: String = "ALL") {
        // isLoading이 true일 -> 중복 요청을 방지하기 위해 조기 종료
        // hasMorePages가 false -> 더 이상 데이터가 없으므로 추가 요청 방지
        guard !isLoading && (hasMorePages || !isNextPage) else { return }
        
        isLoading = true
        let page = isNextPage ? currentPage + 1 : 1
        
        clothesService.getClothes(
            clokeyId: nil,
            categoryId: categoryId,
            season: season, 
            sort: currentSort.rawValue,
            page: page,
            size: 12
        ) { [weak self] result in
            self?.isLoading = false // 새로운 요청 가능~
            
            switch result {
            case .success(let response):
                let newItems = response.clothPreviews.map { preview in
                    TagClothModel(
                        id: Int(preview.id),
                        image: preview.imageUrl,
                        count: preview.wearNum,
                        name: preview.name
                    )
                }
                // 페이징 처리
                if isNextPage {
                    self?.originalClothItems.append(contentsOf: newItems)
                    self?.currentPage = page
                } else {
                    self?.originalClothItems = newItems
                    self?.currentPage = 1
                }
                
                // 데이터가 비어있지 않으면 추가 요청
                self?.hasMorePages = !newItems.isEmpty
                self?.filterItems() // 검색어 필터링 해서 화면 갱신
            case .failure(let error):
                print("Error loading clothes: \(error)")
            }
        }
    }
    
    // 선택된 아이템 다시 불러와서 표시 함수 - 중요한 역할을 함.
    private func restoreSelectionStates() {
        for (index, item) in clothItems.enumerated() {
            if selectedItems.contains(where: { $0.id == item.id }) { // id로 구분
                let indexPath = IndexPath(item: index, section: 0)
                tagClothView.collectionView.selectItem(
                    at: indexPath,
                    animated: false,
                    scrollPosition: []
                )
            }
        }
    }
    
    // MARK: - UI Updates
    // 전체보기 or 특정 카테고리 보기 설정
    private func updateContent(for index: Int) {
        if index == 0 {
            handleTotalCategorySelection()
        } else {
            handleSpecificCategorySelection(index)
        }
    }
    
    // 전체 카테고리 - 모든 의류 데이터 불러옴
    private func handleTotalCategorySelection() {
        loadClothesData(categoryId: 0)
        tagClothView.customTotalSegmentView.toggleCategoryButtons(isHidden: true)
        updateContentViewConstraints(forTotal: true)
    }
    
    // 특정 카테고리 - 선택된 카테고리에 맞는 의류 데이터 불러옴
    private func handleSpecificCategorySelection(_ index: Int) {
        
        guard let category = CustomCategoryModel.getCategories(for: index) else {
            return
        }

        loadClothesData(categoryId: index)
        tagClothView.customTotalSegmentView.toggleCategoryButtons(isHidden: false)
        tagClothView.customTotalSegmentView.updateCategories(for: category.buttons)
        updateContentViewConstraints(forTotal: false)
    }

    
    // 카테고리 변경할 때마다 레이아웃 재설정..
    private func updateContentViewConstraints(forTotal: Bool) {
        tagClothView.contentView.snp.remakeConstraints {
            if forTotal {
                $0.top.equalTo(tagClothView.customTotalSegmentView.divideLine.snp.bottom).offset(10)
            } else {
                $0.top.equalTo(tagClothView.customTotalSegmentView.categoryScrollView.snp.bottom)
            }
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
    
    // 태그 할 옷 선택 시, 확인 버튼 활성화 설정
    private func updateConfirmButtonState() {
        confirmButton.isEnabled = !selectedItems.isEmpty
        confirmButton.tintColor = selectedItems.isEmpty ? .clear : UIColor(named: "pointOrange800")
    }
    
    // MARK: - Actions
    // 뒤로가기
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    // 확인 버튼
    @objc private func confirmButtonTapped() {
        delegate?.didSelectTags(selectedItems)
        dismiss(animated: true)
    }
}

// MARK: - CollectionView Methods
// 의류 데이터 컬렉션 뷰 - 데이터 처리 & 이벤트 설정
extension TagClothViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // 셀 갯수 반환 (clothItems)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clothItems.count
    }
    // 각 셀 구성 메서드 (cellForItemAt)
    // dequeueReusableCell을 사용해서 재사용 가능 셀 불러옴
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CustomCollectionViewCell.identifier,
            for: indexPath
        ) as? CustomCollectionViewCell else {
            fatalError("Failed to dequeue CustomCollectionViewCell")
        }
        
        configureCell(cell, at: indexPath)
        return cell
    }
    // 의류 데이터 셀에 표시
    private func configureCell(_ cell: CustomCollectionViewCell, at indexPath: IndexPath) {
        let item = clothItems[indexPath.item]
        
        cell.numberLabel.text = "\(indexPath.item + 1)"
        cell.countLabel.text = "\(item.count)회"
        cell.nameLabel.text = item.name
        
        configureCellImage(cell, with: item.image)
        cell.setSelected(selectedItems.contains { $0.id == item.id })
    }
    // 비동기 이미지 로딩 (Kingfisher)
    private func configureCellImage(_ cell: CustomCollectionViewCell, with imageUrlString: String) {
        if let imageURL = URL(string: imageUrlString) {
            cell.productImageView.kf.setImage(
                with: imageURL,
                placeholder: UIImage(named: "test_cloth")
            )
        } else {
            cell.productImageView.image = UIImage(named: "test_cloth")
        }
    }
    // 셀 선택
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleItemSelection(at: indexPath)
    }
    // 셀 선택 해제
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        handleItemDeselection(at: indexPath)
    }
    // 선택한 셀을 선택 상태로 변경
    private func handleItemSelection(at indexPath: IndexPath) {
        guard let cell = tagClothView.collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell else { return }
        
        let item = clothItems[indexPath.item]
        cell.setSelected(true)
        
        if let currentImage = cell.productImageView.image {
            selectedItems.append((id: item.id, image: currentImage, title: item.name))
        }
    }
    // 선택한 셀을 해제 상태로 변경
    private func handleItemDeselection(at indexPath: IndexPath) {
        guard let cell = tagClothView.collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell else { return }
        
        let item = clothItems[indexPath.item]
        cell.setSelected(false)
        selectedItems.removeAll { $0.id == item.id }
    }
}

// MARK: - keyboard
extension TagClothViewController {
    private func setupKeyboardDismissGestures() {
        // 빈 공간 터치
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // CollectionView 스크롤
        tagClothView.collectionView.keyboardDismissMode = .onDrag
    }
    
    @objc internal override func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - SortDropdownViewDelegate
extension TagClothViewController: SortDropdownViewDelegate {
    func didSelectSortOption(_ option: String) {
        currentSort = SortOption.from(option)
        // 현재 선택된 서브 카테고리가 있으면 그 ID를 사용하고,
        // 없다면 메인 카테고리 ID를 사용
        let categoryId = currentSubCategoryId ?? currentMainCategoryId
        loadClothesData(categoryId: categoryId)
    }
}
// MARK: - UISearchTextFieldDelegate
extension TagClothViewController: UISearchTextFieldDelegate {
    // 검색 필드 입력 처리
    private func setupSearchField() {
        tagClothView.searchField.textField.delegate = self
        // 사용자가 타이핑할 때마다 실행
        tagClothView.searchField.textField.addTarget(
            self,
            action: #selector(searchFieldDidChange),
            for: .editingChanged
        )
    }
    // 검색어 필터링
    private func filterItems() {
        // 검색창이 비어있을 때 -> 원본 데이터
        if currentSearchText.isEmpty {
            clothItems = originalClothItems
        } else {
            // 검색어가 입력되면 필터링 시작
            clothItems = originalClothItems.filter {
                $0.name.lowercased().contains(currentSearchText)
            }
        }
        tagClothView.collectionView.reloadData()
    }
    
    // 사용자가 검색어 입력하면 currentSearchText 업데이트
    @objc private func searchFieldDidChange(_ textField: UITextField) {
        currentSearchText = textField.text?.lowercased() ?? ""
        filterItems()
    }
    
    // 세그먼트 감지해서 loadClothesData로 알맞은 index 값 전송
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        currentMainCategoryId = index
        currentSubCategoryId = nil  // 메인 카테고리 변경 시 서브 카테고리 초기화
        
        // 선택된 카테고리에 맞는 데이터를 로드
        tagClothView.customTotalSegmentView.updateIndicatorPosition(for: index)
        updateContent(for: index)
        loadClothesData(categoryId: index)
    }

}

// MARK: - UIScrollViewDelegate
extension TagClothViewController: UIScrollViewDelegate {
    // 화면 하단에 가까워지면 자동으로 다음 페이지 로드
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.height
        
        if offsetY > contentHeight - screenHeight - 100 {
            loadClothesData(
                categoryId: tagClothView.customTotalSegmentView.segmentedControl.selectedSegmentIndex,
                isNextPage: true
            )
        }
    }
}

// MARK: - CustomTotalSegmentViewDelegate
extension TagClothViewController: CustomTotalSegmentViewDelegate {
    // 메인 카테고리 선택 시
    func didSelectMainCategory(categoryId: Int) {
        currentMainCategoryId = categoryId
        currentSubCategoryId = nil
        loadClothesData(categoryId: categoryId)
    }
    // 하위 카테고리 선택 시
    func didSelectSubCategory(categoryId: Int) {
        currentSubCategoryId = categoryId
        loadClothesData(categoryId: categoryId)
    }
    
    // 카테고리 뷰 눌렀을 때
    func didTapSideBarButton() {
        let addCategoryVC = AddCategoryViewController()
        addCategoryVC.delegate = self // delegate 설정
        navigationController?.pushViewController(addCategoryVC, animated: true)
    }
}

extension TagClothViewController: AddCategoryViewControllerDelegate {
    func didSelectCategory(_ categoryId: Int64, season: String?) {
        // category ID 업데이트
        currentSubCategoryId = Int(categoryId)
        
        // categoryId를 통해 메인 카테고리 찾기
        for mainIndex in 1...4 {
            if let categoryModel = CustomCategoryModel.getCategories(for: mainIndex) {
                if categoryModel.buttons.contains(where: { $0.categoryId == categoryId }) {
                    // 전체(index=0) 상태에서 특정 카테고리로 변경될 때의 레이아웃 처리
                    let currentIndex = tagClothView.customTotalSegmentView.segmentedControl.selectedSegmentIndex
                    if currentIndex == 0 {
                        updateContentViewConstraints(forTotal: false)
                    }
                    
                    // 메인 카테고리 세그먼트 선택
                    tagClothView.customTotalSegmentView.segmentedControl.selectedSegmentIndex = mainIndex
                    
                    // 세부 카테고리 버튼들 보이게 설정
                    tagClothView.customTotalSegmentView.toggleCategoryButtons(isHidden: false)
                    
                    // 해당 카테고리의 버튼들 업데이트
                    tagClothView.customTotalSegmentView.updateCategories(for: categoryModel.buttons)
                    
                    // 선택된 버튼 찾아서 선택 상태로 만들기
                    for (buttonIndex, button) in categoryModel.buttons.enumerated() {
                        if button.categoryId == categoryId {
                            if let buttonView = tagClothView.customTotalSegmentView.categoryButtonStackView.arrangedSubviews[buttonIndex] as? UIButton {
                                tagClothView.customTotalSegmentView.selectedCategoryButton = buttonView
                                tagClothView.customTotalSegmentView.updateButtonAppearance()
                            }
                            break
                        }
                    }
                    break
                }
            }
        }
        
        loadClothesData(
            categoryId: Int(categoryId),
            isNextPage: false,
            season: season ?? "ALL"
        )
    }
}
