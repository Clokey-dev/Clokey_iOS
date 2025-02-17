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

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.estimatedItemSize = .init(width: 111, height: 167)
        $0.minimumInteritemSpacing = 10
        $0.minimumLineSpacing = 20
    }).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false // 스크롤뷰 내에서 개별 스크롤 방지
        $0.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
    }

    let seeAllButton = UIButton().then {
        $0.setTitle("전체보기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.contentHorizontalAlignment = .left//text 왼쪽 정렬
    }
        
    let frontIconView = UIImageView().then{
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
    
    let editDrawerButton = UIButton().then{
        $0.setImage(UIImage(named: "plus_icon"), for: .normal)
        $0.tintColor = UIColor.mainBrown800
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    let drawerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.estimatedItemSize = .init(width: 173, height: 77)
        $0.minimumInteritemSpacing = 7
        $0.minimumLineSpacing = 12
    }).then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 10
        $0.showsHorizontalScrollIndicator = false
        $0.register(DrawerCollectionViewCell.self, forCellWithReuseIdentifier: DrawerCollectionViewCell.identifier)
    }

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
        // 배너 추가
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
            make.width.equalToSuperview()// 가로 스크롤 방지
            make.bottom.equalTo(drawerCollectionView.snp.bottom).offset(30)// 항상 contentView 크기가 더 크게, 전체 높이 설정
        }

        customTotalSegmentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(34)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(90)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(customTotalSegmentView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(353)
            make.height.equalTo(354)
        }
        
        seeAllButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(4)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(61)
            make.height.equalTo(44)
        }
        
        frontIconView.snp.makeConstraints{ make in
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
            make.height.equalTo(95)
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
//            make.leading.trailing.equalToSuperview().inset(18)
            make.centerX.equalToSuperview()
            make.height.equalTo(255)
            make.width.equalTo(353)
        }
    }
}

extension ClosetView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        pageControl.currentPage = pageIndex
    }
}

/*더 수정할 부분 : DrawerCollectionView 이거 6개 너무 가라임, height 같은거 좀 더 수정 가능,
 seeAllButton 이거 그냥 빛좋은 개살구임
 화면 연결 아직 미구현
 */
