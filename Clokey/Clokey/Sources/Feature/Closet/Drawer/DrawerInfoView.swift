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
    
    let errorText = UILabel().then {
        $0.text = "한글 7글자 이상, 영어 10글자 이상 입력 불가합니다."
        $0.font = UIFont.ptdRegularFont(ofSize: 12)
        $0.textColor = UIColor(named: "pointOrange600")
        $0.textAlignment = .left
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
        
        let totalMargin: CGFloat = 40   // 좌우 inset 20씩
        let interitemSpacing: CGFloat = 10 * 2 // 아이템 간 간격 10씩 2칸
        let extraSpacing: CGFloat = 5            // 여유 공간
        let availableWidth = UIScreen.main.bounds.width - totalMargin - interitemSpacing - extraSpacing
        let itemWidth = availableWidth / 3
        let imageHeight = itemWidth * 4 / 3
        let cellHeight = imageHeight + 25  // 이미지 아래 5 + 라벨 20
        
        $0.itemSize = CGSize(width: itemWidth, height: cellHeight)
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
        addSubview(errorText)
        
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
        
        errorText.snp.makeConstraints {
            $0.top.equalTo(folderUnderline.snp.bottom).offset(5)
            $0.trailing.leading.equalToSuperview().inset(20)
            $0.height.equalTo(20)
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
