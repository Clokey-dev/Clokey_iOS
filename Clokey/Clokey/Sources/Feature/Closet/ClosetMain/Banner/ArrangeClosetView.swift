import UIKit
import SnapKit
import Then

class ArrangeClosetView: UIView {
    
    // 배너 영역
    let BannerView = UIView().then {
        $0.backgroundColor = UIColor(named: "mainBrown50")
        $0.layer.cornerRadius = 20
    }
    
    let bannerImage = UIImageView().then {
        $0.image = UIImage(named: "bannerimage2")
        $0.contentMode = .scaleAspectFit
    }
    
    let bannerDescription = UILabel().then {
        $0.text = "겨울 옷을 정리할 시간입니다!\nOO님의 겨울 옷들을 보여드릴게요."
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .black
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    // 세그먼트 컨트롤 (카테고리 필터)
    let customTotalSegmentView = CustomTotalSegmentView(items: ["전체", "상의", "하의", "아우터", "기타"])
    
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


    // 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .white
        addSubviews()
        setupLayout()
    }

    private func addSubviews() {
        addSubview(BannerView)
        BannerView.addSubview(bannerImage)
        BannerView.addSubview(bannerDescription)
        
        addSubview(customTotalSegmentView)
        addSubview(collectionView)
    }

    private func setupLayout() {

        BannerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(72)
            make.width.equalTo(353)
        }

        bannerImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 70, height: 70))
        }

        bannerDescription.snp.makeConstraints { make in
            make.top.equalTo(BannerView.snp.top).offset(16)
            make.leading.equalTo(bannerImage.snp.trailing).offset(16)
        }

        customTotalSegmentView.snp.makeConstraints { make in
            make.top.equalTo(BannerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(90)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(customTotalSegmentView.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
}
