import UIKit
import SnapKit
import Then

class DisplayAllView: UIView {
    // MARK: - Properties
    
    // 커스텀 세그먼트 뷰
    let customTotalSegmentView = CustomTotalSegmentView(items: ["전체", "상의", "하의", "아우터", "기타"])
    
    // 검색 필드
    let searchField: CustomSearchField = {
        let field = CustomSearchField()
        return field
    }()
    
    // 정렬 버튼과 컬렉션 뷰를 함께 감싸는 컨텐츠 뷰
    let contentView = UIView()
    
    // 정렬 라벨
    let sortButtonLabel: UILabel = {
        let label = UILabel()
        label.text = "착용순"
        label.textColor = .black
        label.font = UIFont.ptdMediumFont(ofSize: 12)
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
        $0.estimatedItemSize = .zero
        
        let totalMargin: CGFloat = 40
        let interitemSpacing: CGFloat = 10 * 2
        let extraSpacing: CGFloat = 5            // 여유 공간
        
        let availableWidth = UIScreen.main.bounds.width - totalMargin - interitemSpacing - extraSpacing
        let itemWidth = floor(availableWidth / 3)
        let itemHeight = itemWidth * 4 / 3       // 3:4 비율
        $0.itemSize = CGSize(width: itemWidth, height: itemHeight + 15)
    }).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = true
        $0.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
    }
    
    // 외부에서 드롭다운 delegate를 설정할 수 있도록
    weak var sortDropdownDelegate: SortDropdownViewDelegate?
    
    // 드롭다운 뷰 (이름 변경)
    var customSortDropdownView: CustomSortDropdownView?
    
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
        addSubview(customTotalSegmentView)
        addSubview(searchField)
        addSubview(contentView)
        
        contentView.addSubview(sortButtonStack)
        contentView.addSubview(collectionView)
        collectionView.contentInset.bottom = 20
        collectionView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -7)
        sortButtonStack.addArrangedSubview(sortButtonLabel)
        sortButtonStack.addArrangedSubview(sortButtonIcon)
        sortButtonStack.addSubview(sortButton)
        
        sortButtonIcon.snp.makeConstraints {
            $0.width.equalTo(15)
            $0.height.equalTo(18)
        }
        
        sortButtonStack.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        sortButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(sortButtonStack.snp.bottom).offset(5)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        searchField.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        customTotalSegmentView.snp.makeConstraints {
            $0.top.equalTo(searchField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(90)
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(customTotalSegmentView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        sortButton.addTarget(self, action: #selector(toggleDropdown), for: .touchUpInside)
    }
    
    // MARK: - 드롭다운 관련 기능
    @objc private func toggleDropdown() {
        if customSortDropdownView == nil {
            showDropdown()
        } else {
            hideDropdown()
        }
    }
    
    private func showDropdown() {
        let dropdown = CustomSortDropdownView(selectedOption: sortButtonLabel.text ?? "착용순")
        // 외부에서 할당된 delegate를 사용
        dropdown.delegate = sortDropdownDelegate
        customSortDropdownView = dropdown
        
        addSubview(dropdown)
        dropdown.snp.makeConstraints {
            $0.top.equalTo(sortButtonStack.snp.bottom).offset(5)
            $0.trailing.equalTo(sortButtonStack)
            $0.width.equalTo(160)
            $0.height.equalTo(180)
        }
    }
    
    private func hideDropdown() {
        customSortDropdownView?.removeFromSuperview()
        customSortDropdownView = nil
    }
}
