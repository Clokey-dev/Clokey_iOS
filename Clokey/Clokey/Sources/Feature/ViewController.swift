//
//  ViewController.swift
//  Test
//
//  Created by 황상환 on 1/13/25.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    let navBarManager = NavigationBarManager()
    
    private let searchField: CustomSearchField = {
        let field = CustomSearchField()
        return field
    }()

    // 닉네임 필드 추가
    let nicknameField = CustomTextField(title: "닉네임", placeholder: "2글자 이상", isRequired: true)

    // 아이디 필드 추가
    let IDField = CustomTextField(title: "아이디", placeholder: "ex) cky11", isRequired: false)

    // 아이디 + 버튼
    let idField = CustomButtonTextField(title: "아이디", placeholder: "ex) cky11", isRequired: true)
    
    // " " + 버튼
    let idField2 = CustomButtonTextField(title: "", placeholder: "예) 회색 후드티, 검정 슬랙스 등", isRequired: false)
    
    // 비활성화 버튼 - false
    let firstButton = CustomButton(title: "가입 완료", isEnabled: false)
    
    // 활성화 버튼 - true
    let secondButton = CustomButton(title: "가입 완료", isEnabled: true)
   

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        // 네비게이션 뒤로가기
        navBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(didTapBackButton)
        )

        // 네비게이션 타이틀
        navBarManager.setTitle(
            to: navigationItem,
            title: "커스텀 네비게이션 바",
            font: .systemFont(ofSize: 18, weight: .semibold), textColor: .black
        )
        
        view.addSubview(searchField)
        searchField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // 닉네임 필드 추가
        view.addSubview(nicknameField)
        nicknameField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(searchField.snp.bottom).offset(50)
            $0.height.greaterThanOrEqualTo(60) // 적절한 높이 설정
        }
        
        // 아이디 필드 추가
        view.addSubview(IDField)
        IDField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(nicknameField.snp.bottom).offset(40)
            $0.height.greaterThanOrEqualTo(60) // 적절한 높이 설정
        }
        
        // 아이디 + 버튼
        view.addSubview(idField)
        idField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(IDField.snp.bottom).offset(40)
            $0.height.equalTo(60)
        }
        
        // " " + 버튼
        view.addSubview(idField2)
        idField2.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(idField.snp.bottom).offset(40)
            $0.height.equalTo(60)
        }
        
        // " " + 버튼 + 활성화
        idField2.setButtonEnabled(true)
        idField2.setButtonText("중복확인")

        // 비활성화 버튼
        view.addSubview(firstButton)
        firstButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(idField2.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 활성화 버튼
        view.addSubview(secondButton)
        secondButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(firstButton.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 버튼 텍스트 변경
        secondButton.setTitle("활성화됨", for: .normal)
        
        
        
    }

    @objc private func didTapBackButton() {
        print("뒤로 버튼 클릭")
        // NavigationController pop 동작
        navigationController?.popViewController(animated: true)
    }
}
