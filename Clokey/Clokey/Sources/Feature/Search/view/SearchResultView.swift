//
//  SearchResultView.swift
//  Clokey
//
//  Created by 소민준 on 2/11/25.
//


import UIKit
import SnapKit
import Then

class SearchResultView: UIView {
    
    // 🔹 뒤로 가기 버튼
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "goback"), for: .normal)
        $0.contentMode = .scaleAspectFit
    }
    
    // 🔹 검색 제목
    let searchTitleLabel = UILabel().then {
        $0.text = "검색"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .black
    }
    
    // 🔹 검색창
    let searchField = CustomSearchField()
    
    // 🔹 탭 버튼 컨테이너
    let segmentedContainerView = UIView()
    
    // 🔹 계정 버튼
    let accountButton = UIButton(type: .system).then {
        $0.setTitle("계정", for: .normal)
        $0.setTitleColor(UIColor(named: "pointOrange800"), for: .normal)
        $0.titleLabel?.font = UIFont.ptdBoldFont(ofSize: 20)
    }
    
    // 🔹 해시태그 버튼
    let hashtagButton = UIButton(type: .system).then {
        $0.setTitle("해시태그", for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.ptdBoldFont(ofSize: 20)
    }
    
    // 🔹 탭 구분선
    let separatorLine = UIView().then {
        $0.backgroundColor = .lightGray
    }
    
    // 🔹 인디케이터 (애니메이션 포함)
    let indicatorView = UIView().then {
        $0.backgroundColor = UIColor(named: "pointOrange800")
        $0.layer.cornerRadius = 2
    }
    
    // 🔹 계정 검색 결과 CollectionView
    let accountsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 70)
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        $0.collectionViewLayout = layout
        $0.backgroundColor = .white
        $0.isScrollEnabled = true
        $0.clipsToBounds = true
    }
    
    // 🔹 해시태그 검색 결과 CollectionView (이미지 표시)
    let hashtagsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero

        // 🔹 가로 너비를 3등분
        let itemWidth = (UIScreen.main.bounds.width - 10) / 3
        layout.itemSize = CGSize(width: itemWidth, height: 172)

        $0.collectionViewLayout = layout
        $0.backgroundColor = .lightGray
        $0.isScrollEnabled = true
        $0.clipsToBounds = true
    }
    
    
    
    // 🔹 검색 결과 없음 표시
    let emptyLabel = UILabel().then {
        $0.text = "검색 결과가 없습니다."
        $0.textColor = .gray
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        addSubview(backButton)
        addSubview(searchTitleLabel)
        addSubview(searchField)
        addSubview(segmentedContainerView)
        segmentedContainerView.addSubview(accountButton)
        segmentedContainerView.addSubview(hashtagButton)
        segmentedContainerView.addSubview(indicatorView)
        addSubview(accountsCollectionView)
        addSubview(hashtagsCollectionView)
        addSubview(emptyLabel)
        addSubview(separatorLine)
        

        backButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(19)
            make.width.equalTo(10)
            make.height.equalTo(20)
        }

        searchTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.leading.equalTo(backButton.snp.trailing).offset(20)
        }

        searchField.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(13)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }

        segmentedContainerView.snp.makeConstraints { make in
            make.top.equalTo(searchField.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }

        accountButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        hashtagButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        indicatorView.snp.makeConstraints { make in
            make.centerX.equalTo(accountButton.snp.centerX)
            make.bottom.equalTo(segmentedContainerView.snp.bottom).offset(-2)
            make.width.equalTo(88)
            make.height.equalTo(5)
        }

        accountsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedContainerView.snp.bottom).offset(0)
            make.leading.trailing.bottom.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        hashtagsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedContainerView.snp.bottom).offset(0)
            make.leading.trailing.bottom.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        accountsCollectionView.isHidden = false
        hashtagsCollectionView.isHidden = true
    }
    
}
