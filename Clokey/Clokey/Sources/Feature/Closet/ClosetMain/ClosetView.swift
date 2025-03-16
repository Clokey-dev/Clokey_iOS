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
        layout.minimumLineSpacing = 20
        layout.sectionInset = .zero
        layout.estimatedItemSize = .zero
        let totalMargin: CGFloat = 40
        let interitemSpacing: CGFloat = 10 * 2
        let availableWidth = UIScreen.main.bounds.width - totalMargin - interitemSpacing
        let itemWidth = availableWidth / 3
        layout.itemSize = CGSize(width: itemWidth, height: 167)
        
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
        
        let horizontalSpacing = layout.minimumInteritemSpacing
        let totalMargin: CGFloat = 20 + 20
        let availableWidth = UIScreen.main.bounds.width - totalMargin - horizontalSpacing
        let itemWidth = availableWidth / 2
        layout.itemSize = CGSize(width: itemWidth, height: 77)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.layer.cornerRadius = 10
        cv.showsHorizontalScrollIndicator = false
        cv.register(DrawerCollectionViewCell.self, forCellWithReuseIdentifier: DrawerCollectionViewCell.identifier)
        return cv
    }()
    
    // drawerCollectionView 높이 제약을 업데이트하기 위한 참조
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
            // drawerCollectionView의 바텀을 포함하도록 설정
            make.bottom.equalTo(drawerCollectionView.snp.bottom).offset(30)
        }
        
        customTotalSegmentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(90)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(customTotalSegmentView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(354)
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
        
        // drawerCollectionView의 높이 제약을 동적으로 업데이트하기 위해 Constraint 참조를 저장
        drawerCollectionView.snp.makeConstraints { make in
            make.top.equalTo(drawerTitle.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            self.drawerCollectionViewHeightConstraint = make.height.equalTo(0).constraint
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
