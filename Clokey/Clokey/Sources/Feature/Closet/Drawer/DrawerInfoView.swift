//
//  DrawerInfoView.swift
//  Clokey
//
//  Created by 한태빈 on 2/9/25.
//

import UIKit

class DrawerInfoView: UIView {
    
    let folderTextField = UITextField().then {
        $0.placeholder = "폴더명"
        $0.font = UIFont.ptdRegularFont(ofSize: 16)
        $0.textColor = UIColor(named: "textGray600")
        $0.borderStyle = .none
    }
    
    let folderUnderline = UIView().then {
        $0.backgroundColor = UIColor(named: "mainBrown600")
    }
    
    let selectItemLabel = UILabel().then {
        $0.text = "선택한 아이템"
        $0.font = UIFont.ptdMediumFont(ofSize: 16)
        $0.textColor = .black
        $0.textAlignment = .left
    }
    
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
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .white
        addSubview(folderTextField)
        addSubview(folderUnderline)
        addSubview(selectItemLabel)
        addSubview(collectionView)
        
        folderTextField.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(32)
            $0.trailing.leading.equalToSuperview().inset(20)
            $0.height.equalTo(30)
        }
        
        folderUnderline.snp.makeConstraints {
            $0.top.equalTo(folderTextField.snp.bottom).offset(2)
            $0.leading.trailing.equalTo(folderTextField)
            $0.height.equalTo(1)
            
        }
        
        selectItemLabel.snp.makeConstraints{
            $0.top.equalTo(folderUnderline.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(20)

        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(selectItemLabel.snp.bottom).offset(7)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            
        }
    }
    
}
