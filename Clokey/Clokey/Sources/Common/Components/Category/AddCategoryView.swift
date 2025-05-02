

import UIKit
import SnapKit
import Then

class AddCategoryView: UIView {
    
    private var seasonImageViews: [UIImageView] {
        return [springImageView, summerImageView, autumnImageView, winterImageView]
    }
    
    // 라벨 선택
    private var seasonLabelViews: [UILabel] {
        return [springLabel, summerLabel, autumnLabel, winterLabel]
    }
    
    let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.tintColor = UIColor(named: "mainBrown800")
    }

    let titleLabel = UILabel().then {
        $0.text = "카테고리"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        $0.textColor = .black
    }
    
    let completeButton = UIButton().then {
        $0.setTitle( "완료", for: .normal)
//        $0.tintColor = UIColor(named: "mainBrown800")
        $0.setTitleColor(UIColor.mainBrown800, for: .normal)
    }
    
    let containerView: UIView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let springImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 28.5
        $0.layer.masksToBounds = true
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "spring")
        $0.isUserInteractionEnabled = true
    }
    
    let springLabel: UILabel = {
        let label = UILabel()
        label.text = "봄"
        label.font = UIFont.ptdRegularFont(ofSize: 16)
        label.textColor = .mainBrown800
        label.textAlignment = .center
        return label
    }()
    
    let summerImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 28.5
        $0.layer.masksToBounds = true
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "summer")
        $0.isUserInteractionEnabled = true
    }
    
    let summerLabel: UILabel = {
        let label = UILabel()
        label.text = "여름"
        label.font = UIFont.ptdRegularFont(ofSize: 16)
        label.textColor = .mainBrown800
        label.textAlignment = .center
        return label
    }()
    
    let autumnImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 28.5
        $0.layer.masksToBounds = true
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "fall")
        $0.isUserInteractionEnabled = true
    }
    
    let autumnLabel: UILabel = {
        let label = UILabel()
        label.text = "가을"
        label.font = UIFont.ptdRegularFont(ofSize: 16)
        label.textColor = .mainBrown800
        label.textAlignment = .center
        return label
    }()
    
    let winterImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 28.5
        $0.layer.masksToBounds = true
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "winter")
        $0.isUserInteractionEnabled = true
    }
    
    let winterLabel: UILabel = {
        let label = UILabel()
        label.text = "겨울"
        label.font = UIFont.ptdRegularFont(ofSize: 16)
        label.textColor = .mainBrown800
        label.textAlignment = .center
        return label
    }()
    

    // CollectionView for 카테고리버튼
    let categoryCollectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.register(AddCategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AddCategoryHeaderView.identifier)
            $0.register(AddCategoryCollectionViewCell.self, forCellWithReuseIdentifier: AddCategoryCollectionViewCell.identifier)
        }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI

    private func setupUI() {
        backgroundColor = .white
        
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(completeButton)
        
        addSubview(containerView)
        containerView.addSubview(springImageView)
        containerView.addSubview(springLabel)
        containerView.addSubview(summerImageView)
        containerView.addSubview(summerLabel)
        containerView.addSubview(autumnImageView)
        containerView.addSubview(autumnLabel)
        containerView.addSubview(winterImageView)
        containerView.addSubview(winterLabel)
        
        addSubview(categoryCollectionView)
    }

    // MARK: - Setup Constraints

    private func setupConstraints() {
        
        //뒤로가기 버튼
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(24)
        }
        
        //"카테고리"
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.leading.equalToSuperview().offset(59)
            make.centerY.equalTo(backButton)
        }
        
        completeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.trailing.equalToSuperview().offset(-20)
//            make.size.equalTo(24)
            make.centerY.equalTo(backButton)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(37)
            make.height.equalTo(87)
        }
        
        springImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.height.equalTo(57)
        }
        
        springLabel.snp.makeConstraints { make in
            make.top.equalTo(springImageView.snp.bottom).offset(4)
            make.centerX.equalTo(springImageView)
        }
        
        summerImageView.snp.makeConstraints { make in
            make.centerY.equalTo(springImageView)
            make.leading.equalTo(springImageView.snp.trailing).offset(29)
            make.width.height.equalTo(57)
        }
        
        summerLabel.snp.makeConstraints { make in
            make.top.equalTo(summerImageView.snp.bottom).offset(4)
            make.centerX.equalTo(summerImageView)
        }
        
        autumnImageView.snp.makeConstraints { make in
            make.centerY.equalTo(springImageView)
            make.leading.equalTo(summerImageView.snp.trailing).offset(29)
            make.width.height.equalTo(57)
        }
        
        autumnLabel.snp.makeConstraints { make in
            make.top.equalTo(autumnImageView.snp.bottom).offset(4)
            make.centerX.equalTo(autumnImageView)
        }
        
        winterImageView.snp.makeConstraints { make in
            make.centerY.equalTo(springImageView)
            make.leading.equalTo(autumnImageView.snp.trailing).offset(29)
            make.width.height.equalTo(57)
        }
        
        winterLabel.snp.makeConstraints { make in
            make.top.equalTo(winterImageView.snp.bottom).offset(4)
            make.centerX.equalTo(winterImageView)
        }

        categoryCollectionView.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.top.equalTo(containerView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20) //  leading은 유지
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Method
    
    func toggleContainerView(hidden: Bool) {
        containerView.isHidden = hidden
        
        categoryCollectionView.snp.remakeConstraints { make in
            if hidden {
                // containerView가 숨겨지면 titleLabel 바로 아래로 이동
                make.top.equalTo(titleLabel.snp.bottom).offset(30)
            } else {
                // containerView가 보이면 기존 위치로 복구
                make.top.equalTo(containerView.snp.bottom).offset(30)
            }
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    // 계절 선택
    func updateSelectedSeason(_ imageView: UIImageView) {
        // 모든 이미지뷰의 테두리 초기화
        seasonImageViews.forEach { view in
            view.layer.borderWidth = 0
        }
       
        // 선택된 이미지뷰에 테두리 추가
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
        
        // 글씨 굵게
        for (index, view) in seasonLabelViews.enumerated() {
            view.layer.borderWidth = 0
            seasonLabelViews[index].font = .ptdMediumFont(ofSize: 16)
        }
        
        // 선택된 이미지 뷰에 테두리 & 라벨 두께
        if let selectedIndex = seasonImageViews.firstIndex(of: imageView) {
            imageView.layer.borderWidth = 3
            imageView.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
            seasonLabelViews[selectedIndex].font = UIFont.ptdBoldFont(ofSize: 16)
        }   }

}

