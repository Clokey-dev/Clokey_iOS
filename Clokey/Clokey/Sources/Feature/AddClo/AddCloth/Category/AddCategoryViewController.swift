
import UIKit

class AddCategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let addCategoryView = AddCategoryView()
    private var categories: [AddCategoryModel] = []

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

        setupCollectionView()
        setupActions()
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
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
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
        cell.configure(with: item)
        return cell
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let sectionInset = layout.sectionInset.left + layout.sectionInset.right
        let interItemSpacing = layout.minimumInteritemSpacing
        let maxRowWidth = collectionView.bounds.width - sectionInset

        let text = categories[indexPath.section].buttons[indexPath.item]
        let textWidth = text.size(withAttributes: [.font: UIFont.systemFont(ofSize: 16)]).width
        let buttonWidth = textWidth + 28

        if buttonWidth > maxRowWidth {
            return CGSize(width: maxRowWidth, height: 32)
        }

        return CGSize(width: buttonWidth, height: 32)
    }
}



class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
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
