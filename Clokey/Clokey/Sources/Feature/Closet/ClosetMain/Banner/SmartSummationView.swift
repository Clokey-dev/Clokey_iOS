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
        $0.text = "지난 7일 간 OO님의 옷 데이터를 모았어요!\n자주 착용한 옷과 착용하지 않은 옷입니다!"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .black
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    let dateLabel = UILabel().then {
        $0.text = "2025년 01월 18일 기준"
        $0.font = UIFont.ptdRegularFont(ofSize: 14)
        $0.textColor = .darkGray
        $0.textAlignment = .center
    }
    
    let categoryButton1 = UIButton().then {
        $0.setTitle("상의", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.backgroundColor = UIColor.mainBrown800
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
    }

    let TitleLabel1 = UILabel().then {
        $0.text = "카테고리의"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 14)
        $0.textColor = .black
    }
    
    let categoryButton2 = UIButton().then {
        $0.setTitle("후드/맨투맨", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.backgroundColor = UIColor.mainBrown800
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
    }
    let TitleLabel2 = UILabel().then {
        $0.text = "를(을) 즐겨입었어요!"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 14)
        $0.textColor = .black
    }
    // 자주 입은 옷 섹션 라벨
    let frequentTitleLabel = UILabel().then {
        $0.text = " - 일주일간 평균 4회 착용"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .black
    }
    
    let freCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.estimatedItemSize = .init(width: 111, height: 167)
        $0.minimumInteritemSpacing = 10
    }).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false // 스크롤뷰 내에서 개별 스크롤 방지
        $0.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
    }
    
    let seeAllButton = UIButton().then {
        $0.setTitle("후드/맨투먄 전체보기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        $0.contentHorizontalAlignment = .left//text 왼쪽 정렬
    }
        
    let frontIconView = UIImageView().then{
        $0.image = UIImage(named: "front_icon")
        $0.tintColor = UIColor(named: "mainBrown800")
        $0.contentMode = .scaleAspectFit
    }
    
    let categoryButton3 = UIButton().then {
        $0.setTitle("후드/맨투맨", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.backgroundColor = UIColor.mainBrown800
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
    }

    let TitleLabel3 = UILabel().then {
        $0.text = "카테고리의"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 14)
        $0.textColor = .black
    }
    
    let categoryButton4 = UIButton().then {
        $0.setTitle("후드/맨투맨", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.backgroundColor = UIColor.mainBrown800
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
    }
    let TitleLabel4 = UILabel().then {
        $0.text = "를(을) 안입었어요."
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 14)
        $0.textColor = .black
    }
    // 자주 입은 옷 섹션 라벨
    let infrequentTitleLabel = UILabel().then {
        $0.text = " - 일주일간 평균 4회 착용"
        $0.font = UIFont.ptdMediumFont(ofSize: 14)
        $0.textColor = .black
    }
    
    let infreCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.estimatedItemSize = .init(width: 111, height: 167)
        $0.minimumInteritemSpacing = 10
    }).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false // 스크롤뷰 내에서 개별 스크롤 방지
        $0.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
    }
    
    let seeAllButton2 = UIButton().then {
        $0.setTitle("셔츠 전체보기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 12)
        $0.contentHorizontalAlignment = .left//text 왼쪽 정렬
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
        // 배너 영역
        addSubview(bannerView)
        bannerView.addSubview(bannerImage)
        bannerView.addSubview(bannerDescription)
        
        // 날짜 라벨
        addSubview(dateLabel)
        
        // 첫 번째 라인 (categoryButton1, TitleLabel1, categoryButton2, TitleLabel2)
        addSubview(categoryButton1)
        addSubview(TitleLabel1)
        addSubview(categoryButton2)
        addSubview(TitleLabel2)
        
        // 자주 입은 옷 섹션
        addSubview(frequentTitleLabel)
        addSubview(freCollectionView)
        addSubview(seeAllButton)
        addSubview(frontIconView)
        
        // 두 번째 라인 (categoryButton3, TitleLabel3, categoryButton4, TitleLabel4)
        addSubview(categoryButton3)
        addSubview(TitleLabel3)
        addSubview(categoryButton4)
        addSubview(TitleLabel4)
        
        // 잘 안 입은 옷 섹션
        addSubview(infrequentTitleLabel)
        addSubview(infreCollectionView)
        addSubview(seeAllButton2)
        addSubview(frontIconView2)
    }

      
    private func setupConstraints() {
        // 배너 영역
        bannerView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(72)
            $0.width.equalTo(353)
        }
        
        bannerImage.snp.makeConstraints {
            $0.leading.equalTo(bannerView.snp.leading).offset(10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(70)
        }
        
        bannerDescription.snp.makeConstraints {
            $0.leading.equalTo(bannerImage).offset(5)
            $0.trailing.equalTo(bannerView.snp.trailing).offset(-33)
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
            $0.width.equalTo(56)
            $0.height.equalTo(29)
        }
        
        TitleLabel1.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(21)
            $0.leading.equalTo(categoryButton1.snp.trailing).offset(8)
        }
        
        categoryButton2.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(19)
            $0.leading.equalTo(TitleLabel1.snp.trailing).offset(12)
            $0.width.equalTo(56)
            $0.height.equalTo(29)
        }
        
        TitleLabel2.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(21)
            $0.leading.equalTo(categoryButton1.snp.trailing).offset(8)        }
        
        // 자주 입은 옷 섹션
        frequentTitleLabel.snp.makeConstraints {
            $0.top.equalTo(categoryButton1.snp.bottom).offset(11)
            $0.leading.equalTo(bannerView.snp.leading)
        }
        
        freCollectionView.snp.makeConstraints {
            $0.top.equalTo(frequentTitleLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(167)
            $0.width.equalTo(373)
        }
        
        // closetView참고
        seeAllButton.snp.makeConstraints {
            $0.top.equalTo(freCollectionView.snp.bottom).offset(8)
            $0.trailing.equalTo(bannerView.snp.trailing)
            $0.width.equalTo(60)//
            $0.height.equalTo(44)
        }
        
        frontIconView.snp.makeConstraints {
            $0.top.equalTo(freCollectionView.snp.bottom).offset(8)
            $0.leading.equalTo(seeAllButton.snp.trailing).offset(-9)
            $0.width.height.equalTo(12)
        }
        
        // 두 번째 라인: [categoryButton3] [TitleLabel3] [categoryButton4] [TitleLabel4]
        categoryButton3.snp.makeConstraints {
            $0.top.equalTo(freCollectionView.snp.bottom).offset(59)
            $0.leading.equalTo(bannerView.snp.leading)
            $0.width.equalTo(56)
            $0.height.equalTo(29)
        }
        
        TitleLabel3.snp.makeConstraints {
            $0.top.equalTo(freCollectionView.snp.bottom).offset(65)
            $0.leading.equalTo(categoryButton3.snp.trailing).offset(8)
        }
        
        categoryButton4.snp.makeConstraints {
            $0.top.equalTo(freCollectionView.snp.bottom).offset(59)
            $0.leading.equalTo(TitleLabel3.snp.trailing).offset(12)
            $0.width.equalTo(56)
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
            $0.centerX.equalToSuperview()
            $0.height.equalTo(167)
            $0.width.equalTo(373)
        }

        
        seeAllButton2.snp.makeConstraints {
            $0.top.equalTo(infreCollectionView.snp.bottom).offset(8)
            $0.trailing.equalTo(bannerView.snp.trailing)
            $0.width.equalTo(60)//
            $0.height.equalTo(44)
        }
        
        frontIconView2.snp.makeConstraints {
            $0.top.equalTo(infreCollectionView.snp.bottom).offset(8)
            $0.leading.equalTo(seeAllButton2.snp.trailing).offset(-9)
            $0.width.height.equalTo(12)
        }
        
    }

    
}
