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
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        // 셀 크기: 이미지와 이름 레이블의 높이를 고려 (필요에 따라 조정)
        layout.itemSize = CGSize(width: 111, height: 167)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
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
