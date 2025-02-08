

import UIKit
import SnapKit
import Then

class AddCategoryView: UIView {
    
//    let headerView = UIView().then {
//        $0.backgroundColor = .white
//    }

    let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.tintColor = UIColor(named: "mainBrown800")
//        $0.tintColor = .brown
    }

    let titleLabel = UILabel().then {
        $0.text = "카테고리"
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textColor = .black
    }
    

    // CollectionView for 카테고리버튼
    let categoryCollectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.register(AddCategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AddCategoryHeaderView.identifier)
            $0.register(AddCategoryCollectionViewCell.self, forCellWithReuseIdentifier: AddCategoryCollectionViewCell.identifier)
        }
    }()


    // MARK: - Initializer

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
        
        //        addSubview(headerView)
        //        headerView.addSubview(backButton)
        //        headerView.addSubview(titleLabel)
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(categoryCollectionView)
    }

    // MARK: - Setup Constraints

    private func setupConstraints() {
        
        // Header View
//        headerView.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(75)
//            make.leading.trailing.equalToSuperview()
//        }
        
        //뒤로가기 버튼
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.leading.equalToSuperview().offset(20)
//            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        //"카테고리"
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.leading.equalToSuperview().offset(59)
//            make.centerY.equalToSuperview()
            make.centerY.equalTo(backButton)
        }

        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20) // 🔥 leading은 유지
            make.bottom.equalToSuperview()
        }
    }
}

