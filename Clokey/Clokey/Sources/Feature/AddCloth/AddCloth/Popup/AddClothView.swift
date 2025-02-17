//
//  AddClothView.swift
//  Clokey
//
//  Created by 한금준 on 1/10/25.
//

import Foundation
import UIKit
import SnapKit
import Then
final class AddClothView: UIView {
    // MARK: - UI Components
    let TitleLabel = UILabel().then {
        $0.text = "옷 추가가 완료되었어요!"
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 20)
    }
    
    let popUpView = PopupView()
    
    let addButton = UIButton().then {
        $0.setTitle("옷 추가하기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 20)
        $0.backgroundColor = UIColor.white
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "mainBrown800")?.cgColor
    }
    
    let endButton = UIButton().then {
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.ptdMediumFont(ofSize: 20)
        $0.backgroundColor = UIColor(named: "mainBrown800")
        $0.layer.cornerRadius = 10
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        addSubview(TitleLabel)
        addSubview(popUpView)
        addSubview(addButton)
        addSubview(endButton)
    }
    
    private func setupConstraints() {
        TitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
        }
        
        popUpView.snp.makeConstraints {
            $0.top.equalTo(TitleLabel.snp.bottom).offset(34)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(290)
            $0.height.equalTo(508)
        }
        
        addButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(54)
            $0.width.equalTo(170)
        }
        
        endButton.snp.makeConstraints {
            $0.top.equalTo(addButton)
            $0.leading.equalTo(addButton.snp.trailing).offset(10)
            $0.height.equalTo(54)
            $0.width.equalTo(170)
        }
    }
}
