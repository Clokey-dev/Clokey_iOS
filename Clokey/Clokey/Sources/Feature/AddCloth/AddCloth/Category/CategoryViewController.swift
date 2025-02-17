
import UIKit

class CategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let addCategoryView = AddCategoryView()
    private var categories: [AddCategoryModel] = []
    private var selectedIndexPath: IndexPath? // 현재 선택된 버튼의 IndexPath를 저장
    
    override func loadView() {
        view = addCategoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories = [
            AddCategoryModel.getCategory(at: 0),
            AddCategoryModel.getCategory(at: 1),
            AddCategoryModel.getCategory(at: 2),
            AddCategoryModel.getCategory(at: 3)
        ].compactMap { $0 }  // nil 값 제거
        
        addCategoryView.toggleContainerView(hidden: true)
        
        setupCollectionView()
        setupActions()
        
        updateCompleteButtonState() // 완료 버튼 초기 상태 설정
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupCollectionView() {
        let layout = LeftAlignedCollectionViewFlowLayout() // 커스텀 레이아웃 사용
        layout.minimumInteritemSpacing = 13 // 버튼 간 간격
        layout.minimumLineSpacing = 10 // 줄 간 간격
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 40, right: 0) // 섹션 여백 설정
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 27)
        
        addCategoryView.categoryCollectionView.collectionViewLayout = layout
        addCategoryView.categoryCollectionView.dataSource = self
        addCategoryView.categoryCollectionView.delegate = self
        addCategoryView.categoryCollectionView.register(AddCategoryHeaderView.self,
                                                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                                        withReuseIdentifier: AddCategoryHeaderView.identifier)
        addCategoryView.categoryCollectionView.register(AddCategoryCollectionViewCell.self,
                                                        forCellWithReuseIdentifier: AddCategoryCollectionViewCell.identifier)
    }
    
    
    
    private func setupActions() {
        addCategoryView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        addCategoryView.completeButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    var clothName: String? // 전달받을 옷 이름
    

    
    @objc private func didTapNextButton() {
        // 선택된 IndexPath가 있는지 확인
        guard let selectedIndexPath = selectedIndexPath else {
            print("선택된 버튼이 없습니다.")
            return
        }

        // 선택된 버튼의 데이터 가져오기
        let section = selectedIndexPath.section
        let item = selectedIndexPath.item
        
        let selectedCategory = categories[section]
        let selectedButtonName = selectedCategory.buttons[item]
        let selectedClothesName = selectedButtonName.name // 버튼 이름
        let selectedClothesId = selectedButtonName.id     // 버튼 ID

        // WeatherChooseViewController로 데이터 전달
        let weatherVC = WeatherChooseViewController()
        weatherVC.clothName = clothName
        weatherVC.categoryName = selectedCategory.name // 카테고리 이름 전달
        weatherVC.categoryCloth = selectedClothesName        // 버튼 이름 전달
        weatherVC.categoryId = selectedClothesId        // 버튼 ID 전달
        //        weatherVC.categoryCloth = selectedButtonName // 선택된 버튼 이름 전달
        

        // 화면 전환
        navigationController?.pushViewController(weatherVC, animated: true)

        print("Selected Button: \(selectedButtonName), Category: \(selectedCategory.name)")
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].buttons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AddCategoryCollectionViewCell.identifier,
            for: indexPath
        ) as? AddCategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let item = categories[indexPath.section].buttons[indexPath.item]
//        cell.configure(with: item)
        cell.configure(with: item.name) // 이름만 전달
        
        // 선택 상태 초기화
        cell.updateAppearance(isSelected: false)
        
        // 버튼에 액션 추가
        cell.categoryButton.tag = indexPath.item
        cell.categoryButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        
        return cell
    }
    
    
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let point = sender.convert(sender.bounds.origin, to: addCategoryView.categoryCollectionView)
        guard let newIndexPath = addCategoryView.categoryCollectionView.indexPathForItem(at: point) else { return }
        
        // 선택된 상태라면 선택 해제
            if let previousIndexPath = selectedIndexPath, previousIndexPath == newIndexPath {
                if let previousCell = addCategoryView.categoryCollectionView.cellForItem(at: previousIndexPath) as? AddCategoryCollectionViewCell {
                    previousCell.updateAppearance(isSelected: false)
                }
                // 선택 해제
                selectedIndexPath = nil
            } else {
                // 새로운 버튼 선택 상태 업데이트
                if let previousIndexPath = selectedIndexPath {
                    if let previousCell = addCategoryView.categoryCollectionView.cellForItem(at: previousIndexPath) as? AddCategoryCollectionViewCell {
                        previousCell.updateAppearance(isSelected: false)
                    }
                }

                if let newCell = addCategoryView.categoryCollectionView.cellForItem(at: newIndexPath) as? AddCategoryCollectionViewCell {
                    newCell.updateAppearance(isSelected: true)
                }
                selectedIndexPath = newIndexPath
            }
           
           // 완료 버튼 상태 업데이트
           updateCompleteButtonState()
        
        print("Button at index \(newIndexPath.item) tapped!")
    }
    
    private func updateCompleteButtonState() {
        if selectedIndexPath != nil {
            // 활성화 상태
            addCategoryView.completeButton.isEnabled = true
            addCategoryView.completeButton.setTitleColor(UIColor.mainBrown800, for: .normal)
        } else {
            // 비활성화 상태
            addCategoryView.completeButton.isEnabled = false
            addCategoryView.completeButton.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    
    
    
    // MARK: - Header 설정 (섹션 헤더)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: AddCategoryHeaderView.identifier,
                for: indexPath
            ) as? AddCategoryHeaderView else {
                return UICollectionReusableView()
            }
            let categoryName = categories[indexPath.section].name
            header.configure(with: categoryName)
            return header
        }
        return UICollectionReusableView()
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let layout = collectionViewLayout as! UICollectionViewFlowLayout
//        let sectionInset = layout.sectionInset.left + layout.sectionInset.right
//        let interItemSpacing = layout.minimumInteritemSpacing
//        let maxRowWidth = collectionView.bounds.width - sectionInset
//        
//        let text = categories[indexPath.section].buttons[indexPath.item]
//        let textWidth = text.size(withAttributes: [.font: UIFont.systemFont(ofSize: 16)]).width
//        let buttonWidth = textWidth + 28
//        
//        if buttonWidth > maxRowWidth {
//            return CGSize(width: maxRowWidth, height: 32)
//        }
//        
//        return CGSize(width: buttonWidth, height: 32)
//    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            print("Error: Invalid collection view layout")
            return CGSize(width: 0, height: 0)
        }

        // Validate section and item indices
        guard !categories.isEmpty,
              indexPath.section < categories.count,
              indexPath.item < categories[indexPath.section].buttons.count else {
            print("Error: Invalid section or item index")
            return CGSize(width: 0, height: 0)
        }

        let sectionInset = layout.sectionInset.left + layout.sectionInset.right
        let interItemSpacing = layout.minimumInteritemSpacing
        let maxRowWidth = collectionView.bounds.width - sectionInset

        // Extract the name of the button
        let text = categories[indexPath.section].buttons[indexPath.item].name

        // Calculate the size of the text
        let textWidth = (text as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 16)]).width
        let buttonWidth = textWidth + 28 // Add padding for the button

        if buttonWidth > maxRowWidth {
            return CGSize(width: maxRowWidth, height: 32)
        }

        return CGSize(width: buttonWidth, height: 32)
    }
}



class LeftAlignedCollectionViewFlowLayout1: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        var leftMargin: CGFloat = sectionInset.left
        var maxY: CGFloat = -1.0
        
        attributes.forEach { layoutAttribute in
            // 셀만 정렬 (헤더/푸터 제외)
            if layoutAttribute.representedElementCategory == .cell {
                // 새로운 줄로 넘어가면 왼쪽 마진 초기화
                if layoutAttribute.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }
                
                // 셀의 X 좌표를 왼쪽 정렬
                layoutAttribute.frame.origin.x = leftMargin
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY, maxY)
            }
        }
        
        return attributes
    }
}
