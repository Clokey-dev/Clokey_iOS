//
//  CalendarDetailView.swift
//  Clokey
//
//  Created by 황상환 on 2/1/25.
//

import Foundation
import UIKit
import SnapKit
import Then

class CalendarDetailView: UIView {
    
    // MARK: - Properties

    // 네비게이션
    let navBarManager = NavigationBarManager()

    // 이미지 배열
    private var images: [String] = []
    
    // MARK: - UI Components
    // 프로필 정보 헤더 스택
    private let profileHeaderStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .equalSpacing
        $0.alignment = .center
//        $0.backgroundColor = .gray
    }
    private let profileImage = UIImageView().then {
        $0.image = UIImage(named: "profile_test")
        $0.tintColor = .gray
    }
    
    private let nameLabel = UILabel().then {
        $0.text = "햄스터 강아지"
        $0.font = .ptdMediumFont(ofSize: 16)
        $0.textColor = .black
    }
    
    private let leftStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
    }
    
    private let plusButton = UIButton().then {
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.tintColor = .black
    }
    
    // 이미지 뷰
    private let ImageCollectionView: UICollectionView =  {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear

        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        return collectionView
    }()
    
    // 페이지 컨트롤
    private let pageControl = UIPageControl().then {
        $0.currentPage = 0
        $0.currentPageIndicatorTintColor = .black
        $0.pageIndicatorTintColor = .lightGray
    }
    
    // 하단
    private let footerStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
//        $0.backgroundColor = .gray
    }
    
    // 하트&좋아요 컨테츠 뷰
    private let heartNLikeContentView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let likeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "heart"), for: .normal)
    }

    private let likeLabel = UILabel().then {
        $0.text = "250"
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    private let commentButton = UIButton().then {
        $0.setImage(UIImage(systemName: "message"), for: .normal)
    }
    
    // content라벨
    private let contentLabel = UILabel().then {
        $0.text = "연말 파티 즐거웠다."
    }
    
    // 해시태그 라벨
    private let hashtagsLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .orange
    }
    
    // 날짜 라벨
    private let dateLabel = UILabel().then {
        $0.text = "2024.11.26 (TUE)"
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .black
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .white
        
        ImageCollectionView.dataSource = self
        ImageCollectionView.delegate = self
        
        // 네비게이션 뒤로가기
//        navBarManager.addBackButton(
//            to: navigationItem,
//            target: self,
//            action: #selector(didTapBackButton)
//        )

        // 네비게이션 타이틀
//        navBarManager.setTitle(
//            to: navigationItem,
//            title: "",
//            font: .systemFont(ofSize: 18, weight: .semibold), textColor: .black
//        )
        
        addSubview(profileHeaderStackView)
        
        // 왼쪽 스택뷰에 프로필 이미지와 이름 추가
        leftStackView.addArrangedSubview(profileImage)
        leftStackView.addArrangedSubview(nameLabel)
        
        // 프로필 헤더 스택뷰에 왼쪽 스택뷰와 더보기 버튼 추가
        profileHeaderStackView.addArrangedSubview(leftStackView)
        profileHeaderStackView.addArrangedSubview(plusButton)
        
        addSubview(ImageCollectionView)
        addSubview(pageControl)
        addSubview(footerStack)
        
        // 하단 스택뷰도 마찬가지로 수정
        footerStack.addArrangedSubview(heartNLikeContentView)
        footerStack.addArrangedSubview(contentLabel)
        footerStack.addArrangedSubview(hashtagsLabel)
        footerStack.addArrangedSubview(dateLabel)
        
        // 하트&좋아요 수정
        heartNLikeContentView.addSubview(likeButton)
        heartNLikeContentView.addSubview(likeLabel)
        heartNLikeContentView.addSubview(commentButton)
        
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.tintColor = .black

        commentButton.setImage(UIImage(systemName: "message"), for: .normal)
        commentButton.tintColor = .black

        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // 프로필 헤더 (닉네임 + 더보기 버튼)
        
        profileHeaderStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }

        leftStackView.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        profileImage.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImage.snp.trailing).offset(10)
        }
        
        plusButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }

        // 이미지 컬렉션 뷰 (슬라이드 가능)
        ImageCollectionView.snp.makeConstraints {
            $0.top.equalTo(profileHeaderStackView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(500)
            $0.width.equalTo(375)
        }
        
        // 이미지 페이지 컨트롤
        pageControl.snp.makeConstraints {
            $0.top.equalTo(ImageCollectionView.snp.bottom).offset(-30)
            $0.centerX.equalToSuperview()
        }
        
        // 하단 영역 (좋아요, 댓글, 내용, 해시태그, 날짜)
        footerStack.snp.makeConstraints {
            $0.top.equalTo(pageControl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // 좋아요 + 댓글
        heartNLikeContentView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.height.equalTo(30)
        }

        likeButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        likeLabel.snp.makeConstraints {
            $0.leading.equalTo(likeButton.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(24)
        }

        commentButton.snp.makeConstraints {
            $0.leading.equalTo(likeLabel.snp.trailing).offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        // 콘텐츠 라벨
        contentLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(heartNLikeContentView.snp.bottom).offset(8)
        }

        // 해시태그 라벨
        hashtagsLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(20)
        }

        // 날짜 라벨
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(hashtagsLabel.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
        }
    }

    // MARK: - Method
    
    func configureImages(_ images: [String]) {
        self.images = images
        ImageCollectionView.reloadData() // 이미지 변경 후 리로드
        pageControl.numberOfPages = images.count // 페이지 컨트롤 업데이트
    }
    
    // 리스트 문자열 변환
    func configureHashtags(_ hashtags: [String]) {
        hashtagsLabel.text = hashtags.joined(separator: " ")
    }
    
    // MARK: - Action
//    @objc private func didTapBackButton() {
//        print("뒤로 버튼 클릭")
//        // NavigationController pop 동작
//        navigationController?.popViewController(animated: true)
//    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension CalendarDetailView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        cell.configure(with: images[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}

// MARK: - ImageCell (UICollectionViewCell)
class ImageCell: UICollectionViewCell {
    static let identifier = "ImageCell"
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with imageName: String) {
        imageView.image = UIImage(named: imageName)
    }
}
