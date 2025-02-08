//
//  PhotoTagView.swift
//  Clokey
//
//  Created by 황상환 on 1/22/25.
//

import Foundation
import UIKit
import SnapKit
import Then

class PhotoTagView: UIView {
    
    // MARK: - UI Components
    
    // MARK: - 사진 버튼 스택
    let selectImageStack = UIStackView().then {
        $0.axis = .horizontal // 방향 가로
        $0.alignment = .center
        $0.distribution = .fill // 스택 뷰 안에서 하위뷰가 어떻게 배치 될지.. fill -> 본래 크기만큼
        $0.isUserInteractionEnabled = true // 터치 이벤트 가능 여부
        $0.backgroundColor = .white
    }
    
    // 사진 라벨
    let selectImageLabel = UILabel().then {
        $0.text = "사진"
        $0.textColor = .black
        $0.font = .ptdMediumFont(ofSize: 20)
    }
    
    // > 아이콘
    private let chevronImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFit // 가로세로 비율 유지 & 해당 뷰에 맞게 크기 조정
    }

    // 사진 컬렉션 뷰
    let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout() // 레이아웃 설정
        // -> 레이아웃 세부 설정
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8 // 같은 줄 셀들 간의 최소 거리
        layout.minimumLineSpacing = 8 // 줄의 간격
        layout.itemSize = CGSize(width: 120, height: 160) //
        
        // 사진 collectionView
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        // ImageCollectionViewCell 커스텀 셀 등록
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        
        // 마지막 셀이 뷰 경계선에 닫지 않도록 설정. 사실 지워야 디자인과 같아짐
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        
        return collectionView
    }()
    
    
    // MARK: - 태그하기 버튼 스택
    let tagImageStack = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill // 본래 크기
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = .white
    }
    
    // 태그하기 라벨
    let tagImageLabel = UILabel().then {
        $0.text = "태그하기"
        $0.textColor = .black
        $0.font = .ptdMediumFont(ofSize: 20)
    }
    
    // 중요 표시 라벨
    private let requiredIndicator = UILabel().then {
        $0.text = "*"
        $0.font = .ptdMediumFont(ofSize: 20)
        $0.textColor = .pointOrange800
    }
    
    // > 표시
    private let tgChevronImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFit
    }
    
    // 태그하기 컬렉션 뷰
    let tagCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 120, height: 160)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier) // 셀 등록
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        
        return collectionView
    }()
    
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
        
        addSubview(selectImageStack)
        addSubview(imageCollectionView)
        
        selectImageStack.addArrangedSubview(selectImageLabel)
        selectImageStack.addArrangedSubview(chevronImageView)
        
        addSubview(tagImageStack)
        addSubview(tagCollectionView)
        addSubview(requiredIndicator)
                
        let spacerView = UIView() // 빈 공간 채우기
        
        tagImageStack.addArrangedSubview(tagImageLabel)
        tagImageStack.addArrangedSubview(spacerView) // 위치 중요
        tagImageStack.addArrangedSubview(tgChevronImageView)
        
        setupConstraints()
    }
    
    // 각 레이아웃 설정
    private func setupConstraints() {
        
        // 사진 이미지 스택
        selectImageStack.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(30)
        }
        
        imageCollectionView.snp.makeConstraints {
            $0.top.equalTo(selectImageStack.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(160)
        }
        
        // 태그 버튼
        tagImageStack.snp.makeConstraints {
            $0.top.equalTo(imageCollectionView.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(30)
        }
        
        // * 위치 변경
        requiredIndicator.snp.makeConstraints {
            $0.top.equalTo(imageCollectionView.snp.bottom).offset(10)
            $0.leading.equalTo(tagImageLabel.snp.trailing).offset(3)
        }
        
        // 태그 컬렉션 뷰
        tagCollectionView.snp.makeConstraints {
            $0.top.equalTo(tagImageStack.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(0)
            $0.bottom.equalToSuperview() // PhotoTagView의 아래쪽에 뷰를 경계선에 맞게 붙도록 설정하는 제약 조건
        }
    }
    
    // 이미지 추가 되면 높이 0 -> 160
    func updateCollectionViewHeight(_ hasImages: Bool) {
        imageCollectionView.snp.updateConstraints {
            $0.height.equalTo(hasImages ? 160 : 0)
        }
    }
    // 이미지 추가 되면 높이 0 -> 180
    func updateTagCollectionViewHeight(_ hasTags: Bool) {
        tagCollectionView.snp.updateConstraints {
            $0.height.equalTo(hasTags ? 180 : 0)
        }
        
        UIView.animate(withDuration: 0.3) {
           self.layoutIfNeeded() // 레이아웃 변경을 애니메이션과 함께 반영
       }
    }

}
