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
import Kingfisher

class CalendarDetailView: UIView {
    
    // MARK: - Properties

    // 네비게이션
    let navBarManager = NavigationBarManager()

    // 이미지 배열
    private var images: [String] = []
    
    //
    private var viewModel: CalendarDetailViewModel?

    
    // MARK: - UI Components
    
    // 네비게이션 바와 구분선
    private let topBorderView = UIView().then {
        $0.backgroundColor = .textGray200
    }
    
    // ScrollView
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = true
        $0.alwaysBounceVertical = true
    }
    
    private let containerView = UIView()
    
    // 프로필 정보 헤더 스택
    private let profileHeaderStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.distribution = .equalSpacing
        $0.alignment = .center
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
    
    private let rightStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
    }

    
    let lockCheckImageView = UIImageView().then {
        $0.image = UIImage(named: "lock_on")
        $0.contentMode = .scaleAspectFit
    }
    
    let plusButton = UIButton().then {
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
        collectionView.backgroundColor = .gray

        collectionView.register(CalendarImageCell.self, forCellWithReuseIdentifier: CalendarImageCell.identifier)
        return collectionView
    }()
    
    // 태그한 옷 보기
    let clothesIconButton = UIButton().then {
        $0.setImage(UIImage(named: "tag_icon"), for: .normal)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
        $0.layer.shadowOpacity = 0.2
    }

    // 페이지 컨트롤
    private let pageControl = UIPageControl().then {
        $0.currentPage = 0
        $0.currentPageIndicatorTintColor = .black
        $0.pageIndicatorTintColor = .lightGray
    }
    
    // 하단
    private let footerStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
    }
    
    // 하트&좋아요 컨테츠 뷰
    private let heartNLikeContentView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let likeButton = UIButton().then {
        $0.setImage(UIImage(named: "heart_empty"), for: .normal)
    }

    let likeLabel = UILabel().then {
        $0.text = "250"
        $0.font = .systemFont(ofSize: 16)
    }
    
    // 댓글 컨텐츠
    let commentContainerView = UIView().then {
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = true
    }

    let commentButton = UIButton().then {
        $0.setImage(UIImage(named: "comment_icon"), for: .normal)
        $0.isUserInteractionEnabled = true
    }
    
    let commentLabel = UILabel().then {
        $0.text = "250"
        $0.font = .systemFont(ofSize: 16)
        $0.isUserInteractionEnabled = true
    }

    private let contentContainerView = UIView()

    // content라벨
    let contentLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .black
        $0.numberOfLines = 1
    }

    // "더보기" 버튼
    let moreButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0)
        
        // 폰트 설정을 configuration에 추가
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 13)
            return outgoing
        }
        
        $0.configuration = configuration
        $0.setTitle("더보기", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
        $0.isHidden = true
    }
    
    
    // 해시태그 라벨
    private let hashtagsLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.text = "#연말룩 #파티룩 #원피스 #2025년도 화이팅"
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
        
        // 스크롤뷰 설정
        addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        // 컨테이너뷰에 컴포넌트 추가
        containerView.addSubview(profileHeaderStackView)
        containerView.addSubview(topBorderView)
        containerView.addSubview(ImageCollectionView)
        containerView.addSubview(clothesIconButton)
        containerView.addSubview(pageControl)
        containerView.addSubview(footerStack)
        
        // 프로필 헤더 구성
        leftStackView.addArrangedSubview(profileImage)
        leftStackView.addArrangedSubview(nameLabel)
        rightStackView.addArrangedSubview(lockCheckImageView)
        rightStackView.addArrangedSubview(plusButton)
        profileHeaderStackView.addArrangedSubview(leftStackView)
        profileHeaderStackView.addArrangedSubview(rightStackView)
        
        // 하단 영역 구성
        footerStack.addArrangedSubview(heartNLikeContentView)
        footerStack.addArrangedSubview(contentContainerView)
        footerStack.addArrangedSubview(hashtagsLabel)
        footerStack.addArrangedSubview(dateLabel)
        
        // 좋아요/댓글 영역
        heartNLikeContentView.addSubview(likeButton)
        heartNLikeContentView.addSubview(likeLabel)
        heartNLikeContentView.addSubview(commentContainerView)
        commentContainerView.addSubview(commentButton)
        commentContainerView.addSubview(commentLabel)

        contentContainerView.addSubview(contentLabel)
        contentContainerView.addSubview(moreButton)

        setupConstraints()
    }

    
    private func setupConstraints() {
        // ScrollView
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // ContainerView
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        // 프로필 헤더 (이미지/닉네임 + 잠굼/더보기 버튼)
        profileHeaderStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        // 구분선
        topBorderView.snp.makeConstraints {
            $0.top.equalTo(profileHeaderStackView.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        // 이미지/닉네임 스택
        leftStackView.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        profileImage.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImage.snp.trailing).offset(8)
        }
        
        // 잠굼/더보기 스택
        rightStackView.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        lockCheckImageView.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
        
        plusButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        // 이미지 컬렉션 뷰 (슬라이드 가능)
        ImageCollectionView.snp.makeConstraints {
            $0.top.equalTo(profileHeaderStackView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            
            let screenWidth = UIScreen.main.bounds.width
            let imageHeight = screenWidth * (4.0 / 3.0)
            $0.height.equalTo(imageHeight).priority(.high)
        }
        
        
        // 태그한 옷 보기
        clothesIconButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.bottom.equalTo(ImageCollectionView.snp.bottom).offset(-13)
            $0.width.height.equalTo(30)
        }
        
        // 이미지 페이지 컨트롤
        pageControl.snp.makeConstraints {
            $0.top.equalTo(ImageCollectionView.snp.bottom).offset(-30)
            $0.centerX.equalToSuperview()
        }
        
        // 하단 영역 (좋아요, 댓글, 내용, 해시태그, 날짜)
        footerStack.snp.makeConstraints {
            $0.top.equalTo(ImageCollectionView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        // 좋아요 + 댓글
        heartNLikeContentView.snp.makeConstraints {
            $0.top.equalTo(footerStack)
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
            $0.width.equalTo(15)
        }
        
        commentContainerView.snp.makeConstraints {
            $0.leading.equalTo(likeLabel.snp.trailing).offset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        commentButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        commentLabel.snp.makeConstraints {
            $0.leading.equalTo(commentButton.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(24)
            $0.trailing.equalToSuperview()
        }
        
        contentContainerView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(24)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.lessThanOrEqualTo(contentContainerView.snp.width)
        }

        moreButton.snp.makeConstraints {
            $0.leading.equalTo(contentLabel.snp.trailing).offset(2)
            $0.centerY.equalTo(contentLabel)
            $0.height.equalTo(24)
        }
            
        hashtagsLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(hashtagsLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
//        footerStack.spacing = 10
    }

    // MARK: - Method
    
    func configureImages(_ images: [String]) {
        self.images = images
        ImageCollectionView.reloadData() // 이미지 변경 후 리로드
        pageControl.numberOfPages = images.count // 페이지 컨트롤 업데이트
        pageControl.pageIndicatorTintColor = .pointOrange200
        pageControl.currentPageIndicatorTintColor = .pointOrange800
    }
    
    // 리스트 문자열 변환
    func configureHashtags(_ hashtags: [String]) {
        hashtagsLabel.text = hashtags.joined(separator: " ")
    }
    
    private func updateContentLabel() {
        guard let text = viewModel?.content else { return }
        
        if text.count > 20 {
            let index = text.index(text.startIndex, offsetBy: 20)
            let truncatedText = String(text[..<index]) + "..."
            contentLabel.text = truncatedText
            moreButton.isHidden = false

            moreButton.snp.remakeConstraints {
                $0.leading.equalTo(contentLabel.snp.trailing).offset(4)
                $0.centerY.equalTo(contentLabel)
                $0.height.equalTo(24)
            }
        } else {
            contentLabel.text = text
            moreButton.isHidden = true
        }
        
        layoutIfNeeded()
    }



}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension CalendarDetailView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarImageCell.identifier, for: indexPath) as! CalendarImageCell
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

// 회원 조회 API 업데이트
extension CalendarDetailView {
    func configure(with viewModel: CalendarDetailViewModel) {
        self.viewModel = viewModel

        // 프로필 이미지 설정
        profileImage.kf.setImage(with: viewModel.profileImageURL, placeholder: UIImage(named: "profile_test"))
        
        // 닉네임 설정
        nameLabel.text = viewModel.name
        
        // 이미지 슬라이드 설정
        configureImages(viewModel.images)
        
        // 좋아요 버튼 상태 설정
        let heartImage = viewModel.liked ? "heart_fill" : "heart_empty"
        likeButton.setImage(UIImage(named: heartImage), for: .normal)
        
        // 좋아요 수 설정
        likeLabel.text = viewModel.likeCount
            
        // 댓글 수 설정
        commentLabel.text = viewModel.commentCount
        
        // 컨텐츠 설정
        contentLabel.text = viewModel.content
        DispatchQueue.main.async {
            self.updateContentLabel()
        }
        
        // 해시태그 설정
        hashtagsLabel.text = viewModel.hashtags
        
        // 날짜 설정
        if let date = convertStringToDate(viewModel.date) {
            dateLabel.text = convertDateToFormattedString(date)
        } else {
            dateLabel.text = viewModel.date
        }
        
        // 공개/비공개
        let lockImage = viewModel.visibility ? "lock_off" : "lock_on"
        lockCheckImageView.image = UIImage(named: lockImage)
    }
}

// 좋아요 처리
extension CalendarDetailView {
    func updateLikeState(with viewModel: CalendarDetailViewModel) {
        let heartImage = viewModel.liked ? "heart_fill" : "heart_empty"
        likeButton.setImage(UIImage(named: heartImage), for: .normal)
        likeLabel.text = viewModel.likeCount
    }
}

// 문자열을 Date로 변환
func convertStringToDate(_ dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.date(from: dateString)
}

// Date를 원하는 형식의 문자열로 변환
func convertDateToFormattedString(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd (E)"
    dateFormatter.locale = Locale(identifier: "en_US") // 영어 요일 표시
    return dateFormatter.string(from: date).uppercased() // 대문자로 변환
}

// 더보기 버튼 동작 처리
extension CalendarDetailView {
    func expandContent() {
        guard let fullText = viewModel?.content else { return }
        
        // 애니메이션과 함께 전체 텍스트 표시
        UIView.animate(withDuration: 0.3) {
            self.contentLabel.snp.remakeConstraints {
                $0.top.equalToSuperview()
                $0.leading.trailing.equalToSuperview()
            }
            
            self.contentLabel.numberOfLines = 0
            self.contentLabel.text = fullText
            self.moreButton.isHidden = true
            self.scrollView.isScrollEnabled = true
            
            self.layoutIfNeeded()
        }
        
        // 해시태그 간격 조정
        hashtagsLabel.snp.updateConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(10)
        }
    }
}
