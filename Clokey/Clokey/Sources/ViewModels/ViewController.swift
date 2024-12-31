//
//  ViewController.swift
//  Clokey
//
//  Created by 황상환 on 12/31/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 테스트 코드
        // 배경색을 흰색으로 변경
        view.backgroundColor = .white
        
        // 테스트용 레이블 추가
        let label = UILabel()
        label.text = "Hello, Clokey!"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        // 레이블 중앙 정렬
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }


}

