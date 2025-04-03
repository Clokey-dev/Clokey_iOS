import UIKit
import SnapKit
import Then

final class ClosetView: UIView {
    // MARK: - UI Components
    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }
    
    let contentView = UIView() // ScrollView 내부를 감싸는 View
    
    let customTotalSegmentView = CustomTotalSegmentView(items: ["전체", "상의", "하의", "아우터", "기타"])
    
    // 옷 데이터 컬렉션 뷰 (셀 크기 고정 및 왼쪽 정렬)
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 25
        layout.sectionInset = .zero  // 섹션 인셋 0으로 설정해 왼쪽부터 배치
        layout.estimatedItemSize = .zero
        let totalMargin: CGFloat = 40   // 좌우 inset 20씩
        let interitemSpacing: CGFloat = 10 * 2 // 아이템 간 간격 10씩 2칸
        let extraSpacing: CGFloat = 5            // 여유 공간
        let availableWidth = UIScreen.main.bounds.width - totalMargin - interitemSpacing - extraSpacing
        let itemWidth = availableWidth / 3
        let imageHeight = itemWidth * 4 / 3
        let cellHeight = imageHeight + 25  // 이미지 아래 5 + 라벨 20
        layout.itemSize = CGSize(width: itemWidth, height: cellHeight)

        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        return cv
    }()
    
    let seeAllButton = UIButton().then {
        $0.setTitle("전체보기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.contentHorizontalAlignment = .left
    }
    
    let frontIconView = UIImageView().then {
        $0.image = UIImage(named: "front_icon")
        $0.tintColor = UIColor(named: "mainBrown800")
        $0.contentMode = .scaleAspectFit
    }
    
    let bannerScrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.bounces = true
        $0.isScrollEnabled = true
    }
    
    let bannerStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 0
        $0.distribution = .fillEqually
    }
    
    let banner1 = ArrangeClosetBannerView()
    let banner2 = SmartSummationBannerView()
    
    let pageControl = UIPageControl().then {
        $0.numberOfPages = 2
        $0.currentPage = 0
        $0.pageIndicatorTintColor = UIColor(named: "textGray400")
        $0.currentPageIndicatorTintColor = UIColor(named: "textGray600")
    }
    
    let drawerTitle = UILabel().then {
        $0.text = "서랍"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        $0.textColor = .black
    }
    
    let editDrawerButton = UIButton().then {
        $0.setImage(UIImage(named: "plus_icon"), for: .normal)
        $0.tintColor = UIColor.mainBrown800
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    let drawerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 7
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.estimatedItemSize = .zero

        let horizontalSpacing = layout.minimumInteritemSpacing // 7 포인트
        let totalMargin: CGFloat = 20 + 20  // 좌우 margin 합계 40 포인트
        let availableWidth = UIScreen.main.bounds.width - totalMargin - horizontalSpacing
        let itemWidth = availableWidth / 2  // 두 개로 나누어 배치
        layout.itemSize = CGSize(width: itemWidth, height: 77)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.layer.cornerRadius = 10
        cv.showsHorizontalScrollIndicator = false
        cv.register(DrawerCollectionViewCell.self, forCellWithReuseIdentifier: DrawerCollectionViewCell.identifier)
        return cv
    }()
    
    // drawerCollectionView 높이를 동적으로 업데이트하기 위한 Constraint 참조
    var drawerCollectionViewHeightConstraint: Constraint?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        bannerScrollView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI and Constraints
    private func setupUI() {
        backgroundColor = .white
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(customTotalSegmentView)
        contentView.addSubview(bannerScrollView)
        contentView.addSubview(pageControl)
        contentView.addSubview(collectionView)
        contentView.addSubview(seeAllButton)
        contentView.addSubview(frontIconView)
        contentView.addSubview(drawerTitle)
        contentView.addSubview(editDrawerButton)
        contentView.addSubview(drawerCollectionView)
        
        bannerScrollView.addSubview(bannerStackView)
        bannerStackView.addArrangedSubview(banner1)
        bannerStackView.addArrangedSubview(banner2)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview() // 가로 스크롤 방지
            make.bottom.greaterThanOrEqualTo(drawerCollectionView.snp.bottom).offset(30)
        }
        
        customTotalSegmentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(90)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(customTotalSegmentView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(20)
            
            let totalMargin: CGFloat = 40   // 좌우 inset 20씩
            let interitemSpacing: CGFloat = 10 * 2  // 셀 사이 간격 10pt씩 2칸
            let extraSpacing: CGFloat = 5     // 추가 여유 공간
            let availableWidth = UIScreen.main.bounds.width - totalMargin - interitemSpacing - extraSpacing
            let itemWidth = availableWidth / 3
            
            let imageHeight = itemWidth * 4 / 3  // 이미지 3:4 비율
            let cellHeight = imageHeight + 25    // 이미지 아래 간격 5pt + 라벨 높이 20pt = 25pt
            let totalCollectionViewHeight = 2 * cellHeight + 30  // 2줄 셀 높이 + 행 간 간격 25pt
            
            make.height.equalTo(totalCollectionViewHeight)
        }


        
        seeAllButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(4)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(61)
            make.height.equalTo(44)
        }
        
        frontIconView.snp.makeConstraints { make in
            make.top.equalTo(seeAllButton.snp.top).offset(16)
            make.trailing.equalToSuperview().offset(-17)
            make.width.height.equalTo(12)
        }
        
        bannerScrollView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(60)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(105)
        }
        
        bannerStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(86)
            make.width.equalToSuperview().multipliedBy(2)
        }
        
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(bannerScrollView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        drawerTitle.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(20)
        }
        
        editDrawerButton.snp.makeConstraints { make in
            make.top.equalTo(drawerTitle.snp.top)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(15)
        }
        
        drawerCollectionView.snp.makeConstraints { make in
            make.top.equalTo(drawerTitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            // 기존 고정값 대신 Constraint 참조를 저장하여 나중에 업데이트 할 수 있게 함
            self.drawerCollectionViewHeightConstraint = make.height.equalTo(255).constraint
        }
    }
}

// MARK: - UIScrollViewDelegate (배너 페이지 컨트롤)
extension ClosetView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == bannerScrollView {
            let pageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
            pageControl.currentPage = pageIndex
        }
    }
}
