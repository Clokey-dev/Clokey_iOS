//
//  SmartSummationView.swift
//  Clokey
//
//  Created by 한태빈 on 2/17/25.
//

import UIKit
import SnapKit
import Then

class SmartSummationView: UIView {
    
    // 스크롤뷰 추가
    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = true
        $0.alwaysBounceVertical = true
    }
    
    // 스크롤뷰 내부의 컨텐츠 뷰
    let contentView = UIView().then {
        $0.backgroundColor = .white
    }
    
    // 배너 영역
    let bannerView = UIView().then {
        $0.backgroundColor = UIColor(named: "mainBrown50")
        $0.layer.cornerRadius = 20
    }
    
    let bannerImage = UIImageView().then {
        $0.image = UIImage(named: "bannerimage1")
        $0.contentMode = .scaleAspectFit
    }
    
    let bannerDescription = UILabel().then {
        $0.text = "지난 30일 간 사용자님의 옷 데이터를 모았어요!\n자주 착용한 옷과 착용하지 않은 옷입니다!"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .black
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    let dateLabel = UILabel().then {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 기준"
        $0.text = dateFormatter.string(from: Date())
        $0.font = UIFont.ptdRegularFont(ofSize: 14)
        $0.textColor = .darkGray
        $0.textAlignment = .center
    }
    
    let categoryButton1 = UIButton().then { button in
        var config = UIButton.Configuration.filled()
        config.title = ""
        config.baseBackgroundColor = .mainBrown800
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.ptdRegularFont(ofSize: 13)
            return outgoing
        }
        
        config.background.strokeColor = UIColor(named: "mainBrown800") ?? .brown
        config.background.strokeWidth = 1
        config.background.cornerRadius = 10
        
        button.configuration = config
    }

    let TitleLabel1 = UILabel().then {
        $0.text = "카테고리의"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 14)
        $0.textColor = .black
    }
    
    let categoryButton2 = UIButton().then { button in
        var config = UIButton.Configuration.filled()
        config.title = ""
        config.baseBackgroundColor = .mainBrown800
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.ptdRegularFont(ofSize: 13)
            return outgoing
        }
        
        config.background.strokeColor = UIColor(named: "mainBrown800") ?? .brown
        config.background.strokeWidth = 1
        config.background.cornerRadius = 10
        
        button.configuration = config
    }

    let TitleLabel2 = UILabel().then {
        $0.text = "를(을) 즐겨입었어요!"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 14)
        $0.textColor = .black
    }
    // 자주 입은 옷 섹션 라벨
    let frequentTitleLabel = UILabel().then {
        $0.text = " - 한달 간 4회 착용"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .black
    }
    
    let freCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        layout.sectionInset = .zero  // 섹션 인셋 0으로 설정해 왼쪽부터 배치
        layout.estimatedItemSize = .zero
        let totalMargin: CGFloat = 40   // 좌우 inset 20씩
        let interitemSpacing: CGFloat = 10 * 2 // 아이템 간 간격 10씩 2칸
        let extraSpacing: CGFloat = 5            // 여유 공간
        let availableWidth = UIScreen.main.bounds.width - totalMargin - interitemSpacing - extraSpacing
        let itemWidth = availableWidth / 3
        let imageHeight = itemWidth * 4 / 3
        let cellHeight = imageHeight + 25  // 이미지 아래 5 + 라벨 20
        layout.itemSize = CGSize(width: itemWidth-10, height: cellHeight)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        return cv
    }()
    
    let seeAllButton = UIButton().then {
        $0.setTitle("후드/맨투맨 전체보기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        $0.contentHorizontalAlignment = .left//text 왼쪽 정렬
        $0.sizeToFit()

    }
        
    let frontIconView = UIImageView().then{
        $0.image = UIImage(named: "front_icon")
        $0.tintColor = UIColor(named: "mainBrown800")
        $0.contentMode = .scaleAspectFit
    }
    
    let categoryButton3 = UIButton().then { button in
        var config = UIButton.Configuration.filled()
        config.title = ""
        config.baseBackgroundColor = .mainBrown200
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.ptdRegularFont(ofSize: 13)
            return outgoing
        }
        
        config.background.strokeColor = UIColor(named: "mainBrown200") ?? .brown
        config.background.strokeWidth = 1
        config.background.cornerRadius = 10
        
        button.configuration = config
    }


    let TitleLabel3 = UILabel().then {
        $0.text = "카테고리의"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 14)
        $0.textColor = .black
    }
    
    let categoryButton4 = UIButton().then { button in
        var config = UIButton.Configuration.filled()
        config.title = ""
        config.baseBackgroundColor = .mainBrown200
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.ptdRegularFont(ofSize: 13)
            return outgoing
        }
        
        config.background.strokeColor = UIColor(named: "mainBrown200") ?? .brown
        config.background.strokeWidth = 1
        config.background.cornerRadius = 10
        
        button.configuration = config
    }

    let TitleLabel4 = UILabel().then {
        $0.text = "를(을) 안입었어요."
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 14)
        $0.textColor = .black
    }
    // 자주 입은 옷 섹션 라벨
    let infrequentTitleLabel = UILabel().then {
        $0.text = " - 한달간 4회 착용"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .black
    }
    
    let infreCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        layout.sectionInset = .zero  // 섹션 인셋 0으로 설정해 왼쪽부터 배치
        layout.estimatedItemSize = .zero
        // 한 줄에 3개씩 배치하려면:
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
    
    let seeAllButton2 = UIButton().then {
        $0.setTitle("셔츠 전체보기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        $0.contentHorizontalAlignment = .left//text 왼쪽 정렬
        $0.sizeToFit()
    }
        
    let frontIconView2 = UIImageView().then{
        $0.image = UIImage(named: "front_icon")
        $0.tintColor = UIColor(named: "mainBrown800")
        $0.contentMode = .scaleAspectFit
    }
    
    // MARK: - Initializer
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
      
      // MARK: - Setup
      
    private func setupUI() {
        backgroundColor = .white
        
        // 스크롤뷰 및 컨텐츠 뷰 추가
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 배너 영역
        contentView.addSubview(bannerView)
        bannerView.addSubview(bannerImage)
        bannerView.addSubview(bannerDescription)
        
        // 날짜 라벨
        contentView.addSubview(dateLabel)
        
        // 첫 번째 라인
        contentView.addSubview(categoryButton1)
        contentView.addSubview(TitleLabel1)
        contentView.addSubview(categoryButton2)
        contentView.addSubview(TitleLabel2)
        
        // 자주 입은 옷 섹션
        contentView.addSubview(frequentTitleLabel)
        contentView.addSubview(freCollectionView)
        contentView.addSubview(seeAllButton)
        contentView.addSubview(frontIconView)
        
        // 두 번째 라인
        contentView.addSubview(categoryButton3)
        contentView.addSubview(TitleLabel3)
        contentView.addSubview(categoryButton4)
        contentView.addSubview(TitleLabel4)
        
        // 잘 안 입은 옷 섹션
        contentView.addSubview(infrequentTitleLabel)
        contentView.addSubview(infreCollectionView)
        contentView.addSubview(seeAllButton2)
        contentView.addSubview(frontIconView2)
    }

      
    private func setupConstraints() {
        
        // 스크롤뷰 제약 조건
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }
        
        // 컨텐츠 뷰 제약 조건
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide) // 가로 너비는 스크롤뷰와 동일하게
        }

        // 배너 영역
        bannerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(72)
            $0.width.equalTo(353)
        }
        
        bannerImage.snp.makeConstraints {
            $0.leading.equalTo(bannerView.snp.leading).offset(15)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(43)
        }
        
        bannerDescription.snp.makeConstraints {
            $0.leading.equalTo(bannerImage.snp.trailing).offset(5)
            $0.trailing.equalTo(bannerView.snp.trailing).offset(-10)
            $0.centerY.equalToSuperview()
        }
        
        // 날짜 라벨
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(bannerView.snp.bottom).offset(17)
            $0.leading.equalTo(bannerView.snp.leading)
        }
        
        // 첫 번째 라인: [categoryButton1] [TitleLabel1] [categoryButton2] [TitleLabel2]
        categoryButton1.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(19)
            $0.leading.equalTo(bannerView.snp.leading)
            $0.height.equalTo(29)
        }
        
        TitleLabel1.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(25)
            $0.leading.equalTo(categoryButton1.snp.trailing).offset(8)
        }
        
        categoryButton2.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(19)
            $0.leading.equalTo(TitleLabel1.snp.trailing).offset(12)
            $0.height.equalTo(29)
        }
        
        TitleLabel2.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(25)
            $0.leading.equalTo(categoryButton2.snp.trailing).offset(8)        }
        
        // 자주 입은 옷 섹션
        frequentTitleLabel.snp.makeConstraints {
            $0.top.equalTo(categoryButton1.snp.bottom).offset(11)
            $0.leading.equalTo(bannerView.snp.leading)
        }
        
        freCollectionView.snp.makeConstraints {
            $0.top.equalTo(frequentTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(167)
            $0.width.equalTo(373)
        }
        
        // closetView참고
        seeAllButton.snp.makeConstraints {
            $0.top.equalTo(freCollectionView.snp.bottom).offset(8)
            $0.trailing.equalTo(bannerView.snp.trailing).offset(-10)
            $0.height.equalTo(44)
        }
        
        frontIconView.snp.makeConstraints {
            $0.top.equalTo(freCollectionView.snp.bottom).offset(24)
            $0.leading.equalTo(seeAllButton.snp.trailing).offset(10)
            $0.width.equalTo(6)
            $0.height.equalTo(12)
        }
        
        // 두 번째 라인: [categoryButton3] [TitleLabel3] [categoryButton4] [TitleLabel4]
        categoryButton3.snp.makeConstraints {
            $0.top.equalTo(freCollectionView.snp.bottom).offset(59)
            $0.leading.equalTo(bannerView.snp.leading)
            $0.height.equalTo(29)
        }
        
        TitleLabel3.snp.makeConstraints {
            $0.top.equalTo(freCollectionView.snp.bottom).offset(65)
            $0.leading.equalTo(categoryButton3.snp.trailing).offset(8)
        }
        
        categoryButton4.snp.makeConstraints {
            $0.top.equalTo(freCollectionView.snp.bottom).offset(59)
            $0.leading.equalTo(TitleLabel3.snp.trailing).offset(12)
            $0.height.equalTo(29)
        }
        
        TitleLabel4.snp.makeConstraints {
            $0.top.equalTo(freCollectionView.snp.bottom).offset(65)
            $0.leading.equalTo(categoryButton4.snp.trailing).offset(8)
        }
        
        // 잘 안 입은 옷 섹션
        infrequentTitleLabel.snp.makeConstraints {
            $0.top.equalTo(categoryButton3.snp.bottom).offset(11)
            $0.leading.equalTo(bannerView.snp.leading)
        }
        
        infreCollectionView.snp.makeConstraints {
            $0.top.equalTo(infrequentTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(167)
            $0.width.equalTo(373)
        }

        
        seeAllButton2.snp.makeConstraints {
            $0.top.equalTo(infreCollectionView.snp.bottom).offset(8)
            $0.trailing.equalTo(bannerView.snp.trailing).offset(-10)
            $0.height.equalTo(44)
        }
        
        frontIconView2.snp.makeConstraints {
            $0.top.equalTo(infreCollectionView.snp.bottom).offset(24)
            $0.leading.equalTo(seeAllButton2.snp.trailing).offset(10)
            $0.width.height.equalTo(12)
            $0.bottom.equalTo(contentView).offset(-20) // 이 줄이 중요합니다!
        }
        
        // 중요: contentView의 bottom constraint 추가
        // 스크롤 영역을 결정하기 위해 contentView의 마지막 요소와 contentView의 bottom 사이에 간격 설정
        seeAllButton2.snp.makeConstraints {
            $0.bottom.equalTo(contentView).offset(-20) // 하단 여백 20 추가
        }
    }
}
