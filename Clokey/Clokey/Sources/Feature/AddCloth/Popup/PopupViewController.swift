//
//  PopupViewController.swift
//  Clokey
//
//  Created by 소민준 on 2/1/25.
//

import UIKit
import SnapKit
import Then

class PopupViewController: UIViewController {

    private let popupView = PopupView() // ✅ 뷰 객체만 포함

    private let titleLabel = UILabel().then {
        $0.text = "옷 추가가 완료되었어요!"
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .black
        $0.textAlignment = .center
    }

    private let addButton = UIButton().then {
        $0.setTitle("옷 추가하기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.cgColor
    }

    private let completeButton = UIButton().then {
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.backgroundColor = UIColor(named: "mainBrown800")
        $0.layer.cornerRadius = 8
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(popupView) // ✅ PopupView 추가
        view.addSubview(addButton)
        view.addSubview(completeButton)

        // ✅ 타이틀 상단 고정
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.centerX.equalToSuperview()
        }

        // ✅ PopupView 레이아웃 (높이 지정해서 안 보이는 문제 해결!)
        // ✅ titleLabel과 popupView 사이 간격을 충분히 확보
        popupView.snp.remakeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(34) // 기존 20 -> 40으로 증가
            $0.centerX.equalToSuperview()
            $0.width.equalTo(320)
            $0.height.greaterThanOrEqualTo(508) // 최소 높이 증가
        }
        // ✅ 버튼 배치 (하단 고정)
        addButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-44)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(170)
            $0.height.equalTo(54)
        }

        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-44)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(140)
            $0.height.equalTo(44)
        }
    }
}
