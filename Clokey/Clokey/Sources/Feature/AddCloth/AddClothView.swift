//
//  AddClothView.swift
//  Clokey
//
//  Created by 황상환 on 1/10/25.
//

import Foundation
import UIKit
import SnapKit
import Then

final class AddClothView: UIView {
    
    // ✅ 기존 UI 요소들
    private let label: UILabel = {
        let label = UILabel()
        label.text = "AddClothView"
        label.font = .systemFont(ofSize: 24)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        addSubview(label)
    }
    
    private func setupConstraints() {
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    // ✅ 터치 이벤트가 부모 뷰에서 멈추지 않고 버튼으로 전달되도록 설정
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        if hitView === self {
            print("✅ 터치 이벤트가 부모 뷰에서 멈춤 → 버튼으로 전달")
            return nil // ✅ 부모 뷰가 터치를 가져가지 않도록 함
        }

        return hitView
    }
}
