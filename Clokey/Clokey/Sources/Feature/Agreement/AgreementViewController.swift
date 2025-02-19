//
//  AgreementViewController.swift
//  Clokey
//
//  Created by 소민준 on 1/16/25.
//

import UIKit

class AgreementViewController: UIViewController {
    // MARK: - Properties
    // 약관 데이터 모델 (약관 제목, 필수 여부, 체크 상태 포함)
    private var agreements: [Agreement] = [
            Agreement(
                termId: 1,
                title: "서비스 이용약관",
                isRequired: true,
                isChecked: false,
                content: "서비스 이용약관의 상세 내용입니다..." //  추가
            ),
            Agreement(
                termId : 2,
                title: "개인정보 수집/이용 동의",
                isRequired: true,
                isChecked: false,
                content: "개인정보 처리 방침 상세 내용..." //  추가
            ),
            Agreement(
                termId: 3,
                title: "위치기반 서비스 이용약관 동의",
                isRequired: true,
                isChecked: false,
                content: "위치기반 서비스 약관 내용..." //  추가
            ),
            Agreement(
                termId: 4,
                title: "마케팅 정보수신 동의",
                isRequired: false,
                isChecked: false,
                content: "마케팅 정보 수신 동의 내용..." //  추가
            ),
            Agreement(
                termId: 5,
                title: "Push 알림 동의",
                isRequired: false,
                isChecked: false,
                content: "Push 알림 동의 내용..."
            )
        ]
    // 전체 약관 체크 여부 확인
    private var isAllChecked: Bool {
        return agreements.allSatisfy { $0.isChecked } // 모든 항목이 체크되었는지 확인
    }
    
    // 필수 약관 체크 여부 확인
    private var areAllRequiredChecked: Bool {
        let requiredAgreements = agreements.filter { $0.isRequired } // 필수 항목만 필터링
        return requiredAgreements.allSatisfy { $0.isChecked } // 필수 항목이 모두 체크되었는지 확인
    }
    
    let backButton = UIButton().then {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium) // 아이콘 크기 설정
        $0.setImage(UIImage(systemName: "chevron.left", withConfiguration: largeConfig), for: .normal)
//        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = .black
    }
    
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "약관에 동의하시면\n회원가입이 완료됩니다." // 설명 문구 설정
        label.font = UIFont.ptdSemiBoldFont(ofSize: 24) // 반볼드 폰트와 크기 설정
        label.numberOfLines = 2 // 최대 두 줄로 표시
        label.textColor = .black // 검은색 텍스트
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(AgreementCell.self, forCellReuseIdentifier: AgreementCell.identifier) // 커스텀 셀 등록
        tableView.separatorStyle = .none // 셀 구분선 제거
        tableView.isScrollEnabled = false // 스크롤 비활성화
        return tableView
    }()
    
    private let allAgreeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal) // 체크되지 않은 상태의 아이콘
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected) // 선택되었을 때의 아이콘
        button.tintColor = .pointOrange400 // 초기에는 회색
        button.setTitle("  전체 동의", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.ptdSemiBoldFont(ofSize: 20)
        button.contentHorizontalAlignment = .left
        button.isSelected = false // 초기에는 선택되지 않은 상태
        return button
    }()
    
    private let agreeButton: UIButton = {
        let button = UIButton()
        button.setTitle("가입 완료", for: .normal) // 버튼 텍스트 설정
        button.backgroundColor = .mainBrown400 // 비활성화 상태 배경색
        button.layer.cornerRadius = 8 // 둥근 모서리
        button.setTitleColor(.white, for: .normal) // 텍스트 색상 설정
        button.isEnabled = false // 초기 상태에서는 비활성화
        return button
    }()
    
    private let headerDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray // 원하는 색상으로 변경 가능
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // UI 설정
        tableView.delegate = self // 테이블뷰 델리게이트 연결
        tableView.dataSource = self // 테이블뷰 데이터소스 연결
     
    }
    
    // UI 구성
    private func setupUI() {
        view.backgroundColor = .white
        
        // UI 요소 추가
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(allAgreeButton)
        view.addSubview(headerDivider)
        view.addSubview(tableView)
        view.addSubview(agreeButton)
        
        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.leading.equalToSuperview().offset(20)
        }
        // 피그마 기준 레이아웃 적용
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(31) // 피그마에서 제공한 상단 간격
            $0.leading.trailing.equalToSuperview().inset(20) // 좌우 여백
        }
        
        allAgreeButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(370)
            $0.leading.trailing.equalToSuperview().inset(20) // 좌우 여백
            $0.height.equalTo(44) // 버튼 높이
        }
        
        headerDivider.snp.makeConstraints {
            $0.top.equalTo(allAgreeButton.snp.bottom).offset(8) // 버튼 아래 간격
            $0.leading.trailing.equalToSuperview().inset(20) // 좌우 여백
            $0.height.equalTo(1) // 구분선 높이
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerDivider.snp.bottom).offset(9) // 구분선 아래 간격
            $0.leading.trailing.equalToSuperview().inset(20) // 좌우 여백
//            $0.height.equalTo(141)
//            $0.bottom.equalTo(agreeButton.snp.top).offset(53) // 가입 완료 버튼 위 간격
        }
        
        agreeButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(50)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)/*.offset(-24)*/ // 하단 간격
            $0.leading.trailing.equalToSuperview().inset(20) // 좌우 여백
            $0.height.equalTo(50) // 버튼 높이
        }
        
        // 2안
//        tableView.snp.makeConstraints {
//            $0.top.equalTo(headerDivider.snp.bottom).offset(9) // 구분선 아래 간격
//            $0.leading.trailing.equalToSuperview().inset(20) // 좌우 여백
////            $0.height.equalTo(141)
//            $0.bottom.equalTo(agreeButton.snp.top).offset(50) // 가입 완료 버튼 위 간격
//        }
//        
//        agreeButton.snp.makeConstraints {
////            $0.top.equalTo(tableView.snp.bottom).offset(50)
//            $0.bottom.equalTo(view.safeAreaLayoutGuide)/*.offset(-24)*/ // 하단 간격
//            $0.leading.trailing.equalToSuperview().inset(20) // 좌우 여백
//            $0.height.equalTo(50) // 버튼 높이
//        }
        
        // 버튼 클릭 이벤트 연결
        allAgreeButton.addTarget(self, action: #selector(didTapAllAgree), for: .touchUpInside) // 전체 동의 버튼 클릭 이벤트
        agreeButton.addTarget(self, action: #selector(didTapAgreeButton), for: .touchUpInside) // 가입 완료 버튼 클릭 이벤트
    }
    
   
    
    // MARK: - Actions
    // 전체 동의 버튼 클릭 이벤트
    @objc private func didTapAllAgree() {
        let newState = !isAllChecked // 현재 상태 반전
        for (index, _) in agreements.enumerated() {
            agreements[index].isChecked = newState
        }
        tableView.reloadData() // 테이블뷰 데이터 새로고침
        updateAllAgreeButtonState() // 전체 동의 버튼 상태 업데이트
        updateAgreeButtonState() // 가입 완료 버튼 상태 업데이트
        
        //  전체 동의를 눌렀을 때만 서버에 약관 동의 전송
            sendTermsToServer()
    }

    
    // 가입 완료 버튼 클릭 이벤트
    @objc private func didTapAgreeButton() {
        guard areAllRequiredChecked else { return } // 필수 약관이 체크되지 않았다면 리턴

        print(" 약관 동의 완료. 프로필 설정 화면으로 이동")
        
        //  필수 약관 동의 시 서버로 전송
            sendTermsToServer()

        let addProfileVC = AddProfileViewController()
        navigationController?.pushViewController(addProfileVC, animated: true) //  네비게이션 방식으로 변경
    }
    // 전체 동의 버튼 상태 업데이트
    private func updateAllAgreeButtonState() {
        allAgreeButton.isSelected = isAllChecked // 전체 항목이 체크되었는지 확인
        allAgreeButton.tintColor = isAllChecked ? .pointOrange800 : .pointOrange400 // 400 -> 800 체크 상태에 따라 색상 변경
    }
    
    // 가입 완료 버튼 상태 업데이트
    private func updateAgreeButtonState() {
        let allRequiredCheckd = agreements.filter{ $0.isRequired }.allSatisfy { $0.isChecked }
        agreeButton.isEnabled = areAllRequiredChecked // 필수 항목이 체크되었는지에 따라 활성화 여부 설정
        agreeButton.backgroundColor = areAllRequiredChecked ? .mainBrown800 : .mainBrown400 // 버튼 색상 변경
    }
    
    // 약관 상세보기 화면 표시
//    private func showAgreementDetail(for agreement: Agreement) {
//        let detailVC = AgreementDetailViewController(
//            title: agreement.title,
//            content: agreement.content //  내용 추가 전달
//        )
//        detailVC.modalPresentationStyle = .overFullScreen
//        present(detailVC, animated: true)
//    }
    
    //  서버에서 약관 데이터를 가져와서 `agreements` 배열 업데이트
    private func showAgreementDetail(for agreement: Agreement) {
        let membersService = MembersService()
        
        membersService.getTerms { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    //  서버 응답에서 특정 약관을 찾음
                    if let fetchedTerm = response.first(where: { $0.termId == agreement.termId }) {
                        
                        let detailVC = AgreementDetailViewController(
                            title: fetchedTerm.title,
                            content: fetchedTerm.content //  서버에서 불러온 내용 전달
                        )
                        detailVC.modalPresentationStyle = .overFullScreen
                        self.present(detailVC, animated: true)
                        
                    } else {
                        print("🚨 해당 약관 ID에 대한 데이터 없음")
                    }
                    
                case .failure(let error):
                    print("❌ 약관 데이터 가져오기 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func sendTermsToServer() {
        let requestData = prepareAgreementData() // 약관 데이터 준비

        let membersService = MembersService()
        membersService.agreeToTerms(data: requestData) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    //  서버 응답 데이터를 기반으로 약관 동의 처리
                    let failedTerms = response.terms.filter { !$0.agreed } // 동의되지 않은 약관 필터링

                    if failedTerms.isEmpty {
                        print(" 약관 동의 데이터가 성공적으로 서버에 전송되었습니다!")
                    } else {
                        print("❌ 동의 실패 항목이 있습니다: \(failedTerms.map { $0.termId })")
                    }
                case .failure(let error):
                    print("❌ 네트워크 오류: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func prepareAgreementData() -> AgreementToTermsRequestDTO {
        let terms = agreements
            .filter { $0.isChecked } //  체크된 약관만 포함
            .map { agreement in
                AgreementToTermsRequestDTO.Terms(
                    termId: agreement.termId,
                    agreed: agreement.isChecked
                )
            }

        let requestData = AgreementToTermsRequestDTO(terms: terms)

        //  JSON 데이터가 올바르게 생성되었는지 확인용 출력
        do {
            let jsonData = try JSONEncoder().encode(requestData)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📡 준비된 JSON 데이터:\n\(jsonString)") //  JSON 확인
            }
        } catch {
            print("🚨 JSON 변환 오류: \(error.localizedDescription)")
        }

        return requestData
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AgreementViewController: UITableViewDelegate, UITableViewDataSource {
    // 섹션의 행 개수 설정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return agreements.count
    }
    
    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AgreementCell.identifier, for: indexPath) as? AgreementCell else {
            return UITableViewCell()
        }
        
        let agreement = agreements[indexPath.row]
        cell.configure(with: agreement, isFirst: indexPath.row == 0)
        
        // 체크박스 액션 (기존 코드 유지)
        cell.onCheckBoxTapped = { [weak self] in
            guard let self = self else { return }
            
            self.agreements[indexPath.row].isChecked.toggle() //  상태 변경
            self.tableView.reloadRows(at: [indexPath], with: .none)

            //  체크한 항목을 서버에 즉시 전송
            self.sendTermsToServer()
            
            //  필수 약관 체크 여부 다시 계산
            self.updateAgreeButtonState()
        }
        
        //  화살표 액션 수정: agreement 전체 전달
        cell.onArrowButtonTapped = { [weak self] in
            self?.showAgreementDetail(for: agreement) //  현재 셀의 agreement 전달
        }
        
        return cell
    }
}









//
////
////  AgreementViewController.swift
////  Clokey
////
////  Created by 소민준 on 1/16/25.
////
//
//import UIKit
//
//class AgreementViewController: UIViewController {
//    // MARK: - Properties
//    // 약관 데이터 모델 (약관 제목, 필수 여부, 체크 상태 포함)
//    private var agreements: [Agreement] = [
//            Agreement(
//                termId: 1,
//                title: "서비스 이용약관",
//                isRequired: true,
//                isChecked: false,
//                content: "서비스 이용약관의 상세 내용입니다..." //  추가
//            ),
//            Agreement(
//                termId : 2,
//                title: "개인정보 수집/이용 동의",
//                isRequired: true,
//                isChecked: false,
//                content: "개인정보 처리 방침 상세 내용..." //  추가
//            ),
//            Agreement(
//                termId: 3,
//                title: "위치기반 서비스 이용약관 동의",
//                isRequired: true,
//                isChecked: false,
//                content: "위치기반 서비스 약관 내용..." //  추가
//            ),
//            Agreement(
//                termId: 4,
//                title: "마케팅 정보수신 동의",
//                isRequired: false,
//                isChecked: false,
//                content: "마케팅 정보 수신 동의 내용..." //  추가
//            )
//        ]
//    // 전체 약관 체크 여부 확인
//    private var isAllChecked: Bool {
//        return agreements.allSatisfy { $0.isChecked } // 모든 항목이 체크되었는지 확인
//    }
//
//    // 필수 약관 체크 여부 확인
//    private var areAllRequiredChecked: Bool {
//        let requiredAgreements = agreements.filter { $0.isRequired } // 필수 항목만 필터링
//        return requiredAgreements.allSatisfy { $0.isChecked } // 필수 항목이 모두 체크되었는지 확인
//    }
//
//    let backButton = UIButton().then {
//        let largeConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium) // 아이콘 크기 설정
//        $0.setImage(UIImage(systemName: "chevron.left", withConfiguration: largeConfig), for: .normal)
////        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//        $0.tintColor = .black
//    }
//
//
//    // MARK: - UI Components
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "약관에 동의하시면\n회원가입이 완료됩니다." // 설명 문구 설정
//        label.font = UIFont.ptdSemiBoldFont(ofSize: 24) // 반볼드 폰트와 크기 설정
//        label.numberOfLines = 2 // 최대 두 줄로 표시
//        label.textColor = .black // 검은색 텍스트
//        return label
//    }()
//
//    private let tableView: UITableView = {
//        let tableView = UITableView()
//        tableView.register(AgreementCell.self, forCellReuseIdentifier: AgreementCell.identifier) // 커스텀 셀 등록
//        tableView.separatorStyle = .none // 셀 구분선 제거
//        tableView.isScrollEnabled = false // 스크롤 비활성화
//        return tableView
//    }()
//
//    private let allAgreeButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal) // 체크되지 않은 상태의 아이콘
//        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected) // 선택되었을 때의 아이콘
//        button.tintColor = .pointOrange400 // 초기에는 회색
//        button.setTitle("  전체 동의", for: .normal)
//        button.setTitleColor(.black, for: .normal)
//        button.titleLabel?.font = UIFont.ptdSemiBoldFont(ofSize: 20)
//        button.contentHorizontalAlignment = .left
//        button.isSelected = false // 초기에는 선택되지 않은 상태
//        return button
//    }()
//
//    private let agreeButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("가입 완료", for: .normal) // 버튼 텍스트 설정
//        button.backgroundColor = .mainBrown400 // 비활성화 상태 배경색
//        button.layer.cornerRadius = 8 // 둥근 모서리
//        button.setTitleColor(.white, for: .normal) // 텍스트 색상 설정
//        button.isEnabled = false // 초기 상태에서는 비활성화
//        return button
//    }()
//
//    private let headerDivider: UIView = {
//        let view = UIView()
//        view.backgroundColor = .lightGray // 원하는 색상으로 변경 가능
//        return view
//    }()
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI() // UI 설정
//        tableView.delegate = self // 테이블뷰 델리게이트 연결
//        tableView.dataSource = self // 테이블뷰 데이터소스 연결
//
//    }
//
//    // UI 구성
//    private func setupUI() {
//        view.backgroundColor = .white
//
//        // UI 요소 추가
//        view.addSubview(backButton)
//        view.addSubview(titleLabel)
//        view.addSubview(allAgreeButton)
//        view.addSubview(headerDivider)
//        view.addSubview(tableView)
//        view.addSubview(agreeButton)
//
//        backButton.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(60)
//            $0.leading.equalToSuperview().offset(20)
//        }
//        // 피그마 기준 레이아웃 적용
//        titleLabel.snp.makeConstraints {
//            $0.top.equalTo(backButton.snp.bottom).offset(31) // 피그마에서 제공한 상단 간격
//            $0.leading.trailing.equalToSuperview().inset(20) // 좌우 여백
//        }
//
//        allAgreeButton.snp.makeConstraints {
//            $0.bottom.equalToSuperview().inset(320)
//            $0.leading.trailing.equalToSuperview().inset(20) // 좌우 여백
//            $0.height.equalTo(44) // 버튼 높이
//        }
//
//        headerDivider.snp.makeConstraints {
//            $0.top.equalTo(allAgreeButton.snp.bottom).offset(8) // 버튼 아래 간격
//            $0.leading.trailing.equalToSuperview().inset(20) // 좌우 여백
//            $0.height.equalTo(1) // 구분선 높이
//        }
//
//        tableView.snp.makeConstraints {
//            $0.top.equalTo(headerDivider.snp.bottom).offset(9) // 구분선 아래 간격
//            $0.leading.trailing.equalToSuperview().inset(20) // 좌우 여백
////            $0.height.equalTo(141)
////            $0.bottom.equalTo(agreeButton.snp.top).offset(53) // 가입 완료 버튼 위 간격
//        }
//
//        agreeButton.snp.makeConstraints {
//            $0.top.equalTo(tableView.snp.bottom).offset(50)
//            $0.bottom.equalTo(view.safeAreaLayoutGuide)/*.offset(-24)*/ // 하단 간격
//            $0.leading.trailing.equalToSuperview().inset(20) // 좌우 여백
//            $0.height.equalTo(50) // 버튼 높이
//        }
//
//        // 버튼 클릭 이벤트 연결
//        allAgreeButton.addTarget(self, action: #selector(didTapAllAgree), for: .touchUpInside) // 전체 동의 버튼 클릭 이벤트
//        agreeButton.addTarget(self, action: #selector(didTapAgreeButton), for: .touchUpInside) // 가입 완료 버튼 클릭 이벤트
//    }
//
//
//
//    // MARK: - Actions
//    // 전체 동의 버튼 클릭 이벤트
//    @objc private func didTapAllAgree() {
//        let newState = !isAllChecked // 현재 상태 반전
//        for (index, _) in agreements.enumerated() {
//            agreements[index].isChecked = newState
//        }
//        tableView.reloadData() // 테이블뷰 데이터 새로고침
//        updateAllAgreeButtonState() // 전체 동의 버튼 상태 업데이트
//        updateAgreeButtonState() // 가입 완료 버튼 상태 업데이트
//
//        //  모든 동의 상태를 서버에 전달
//            sendTermsToServer()
//    }
//
//
//
//    private func sendTermsToServer() {
//        let userId = 12345 // 사용자 ID (예시)
//        let requestData = prepareAgreementData() // 약관 데이터 준비
//
//        let membersService = MembersService()
//        membersService.agreeToTerms(userId: userId, data: requestData) { [weak self] result in
//            guard let self = self else { return }
//
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    //  서버 응답 데이터를 기반으로 약관 동의 처리
//                    let failedTerms = response.terms.filter { !$0.agreed } // 동의되지 않은 약관 필터링
//
//                    if failedTerms.isEmpty {
//                        print(" 약관 동의 데이터가 성공적으로 서버에 전송되었습니다!")
//                    } else {
//                        print("❌ 동의 실패 항목이 있습니다: \(failedTerms.map { $0.termId })")
//                    }
//                case .failure(let error):
//                    print("❌ 네트워크 오류: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//
//    private func prepareAgreementData() -> TermsAgreementRequestDTO {
//        let terms = agreements.map { agreement in
//            TermsAgreementRequestDTO.Term(
//                termId: agreement.termId,
//                agreed: agreement.isChecked
//            )
//        }
//
//        return TermsAgreementRequestDTO(terms: terms)
//    }
//
//
//
//
//    // 가입 완료 버튼 클릭 이벤트
//    @objc private func didTapAgreeButton() {
//        guard areAllRequiredChecked else { return } // 필수 약관이 체크되지 않았다면 리턴
//
//        print(" 약관 동의 완료. 프로필 설정 화면으로 이동")
//        sendTermsToAPI() //  가입 완료 버튼을 눌렀을 때만 실행
//        sendTermsToServer()
//
//        let addProfileVC = AddProfileViewController()
//        navigationController?.pushViewController(addProfileVC, animated: true) //  네비게이션 방식으로 변경
////        addProfileVC.modalPresentationStyle = .fullScreen
////        present(addProfileVC, animated: true, completion: nil) //  프로필 설정 화면 띄우기
//    }
//    // 전체 동의 버튼 상태 업데이트
//    private func updateAllAgreeButtonState() {
//        allAgreeButton.isSelected = isAllChecked // 전체 항목이 체크되었는지 확인
//        allAgreeButton.tintColor = isAllChecked ? .pointOrange800 : .pointOrange400 // 400 -> 800 체크 상태에 따라 색상 변경
//    }
//
//    // 가입 완료 버튼 상태 업데이트
//    private func updateAgreeButtonState() {
//        let allRequiredCheckd = agreements.filter{ $0.isRequired }.allSatisfy { $0.isChecked }
//        agreeButton.isEnabled = areAllRequiredChecked // 필수 항목이 체크되었는지에 따라 활성화 여부 설정
//        agreeButton.backgroundColor = areAllRequiredChecked ? .mainBrown800 : .mainBrown400 // 버튼 색상 변경
//    }
//
//    // 약관 상세보기 화면 표시
//    private func showAgreementDetail(for agreement: Agreement) {
//        let detailVC = AgreementDetailViewController(
//            title: agreement.title,
//            content: agreement.content //  내용 추가 전달
//        )
//        detailVC.modalPresentationStyle = .overFullScreen
//        present(detailVC, animated: true)
//    }
//}
//
//// MARK: - UITableViewDelegate, UITableViewDataSource
//extension AgreementViewController: UITableViewDelegate, UITableViewDataSource {
//    // 섹션의 행 개수 설정
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return agreements.count
//    }
//
//    // 셀 구성
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: AgreementCell.identifier, for: indexPath) as? AgreementCell else {
//            return UITableViewCell()
//        }
//
//        let agreement = agreements[indexPath.row]
//        cell.configure(with: agreement, isFirst: indexPath.row == 0)
//
//        // 체크박스 액션 (기존 코드 유지)
//        cell.onCheckBoxTapped = { [weak self] in
//            guard let self = self else { return }
//
//            self.agreements[indexPath.row].isChecked.toggle() //  상태 변경
//            self.tableView.reloadRows(at: [indexPath], with: .none)
//
//            //  필수 약관 체크 여부 다시 계산
//            self.updateAgreeButtonState()
//        }
//
//        //  화살표 액션 수정: agreement 전체 전달
//        cell.onArrowButtonTapped = { [weak self] in
//            self?.showAgreementDetail(for: agreement) //  현재 셀의 agreement 전달
//        }
//
//        return cell
//    }
//    func prepareRequestData() -> String {
//        let sortedAgreements = agreements.sorted { $0.termId < $1.termId }
//
//        var jsonString = "{ \"terms\": ["
//
//        for (index, agreement) in sortedAgreements.enumerated() {
//            jsonString += """
//            { "termId": \(agreement.termId), "agreed": \(agreement.isChecked) }
//            """
//            if index < sortedAgreements.count - 1 {
//                jsonString += ","
//            }
//        }
//
//        jsonString += "] }"
//
//        print("📡 준비된 JSON 문자열:\n\(jsonString)") //  JSON 확인
//        return jsonString
//    }
//
//    func testPrepareRequestData() {
//        let requestData = prepareRequestData()
//
//        if let jsonData = try? JSONSerialization.data(withJSONObject: requestData, options: .prettyPrinted),
//           let jsonString = String(data: jsonData, encoding: .utf8) {
//            print("📡 실제 전송될 JSON:\n\(jsonString)") //  JSON 출력
//        } else {
//            print("🚨 JSON 변환 실패!")
//        }
//    }
//    func sendTermsToAPI() {
//        print("📡 sendTermsToAPI() 호출됨!") //  실행 확인
//
//        let jsonString = prepareRequestData() //  이제 Optional이 아니므로 guard let 제거
//
//        guard let jsonData = jsonString.data(using: .utf8) else {
//            print("🚨 JSON 변환 실패!")
//            return
//        }
//
//        guard let url = URL(string: "https://your-api-endpoint.com/terms") else {
//            print("🚨 URL 생성 실패!")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//
//        print("📡 API 요청을 위한 데이터:", String(data: jsonData, encoding: .utf8) ?? "🚨 JSON 변환 실패!") //  최종 확인
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("🚨 API 요청 실패:", error.localizedDescription)
//                return
//            }
//
//            guard let data = data else {
//                print("🚨 응답 데이터 없음")
//                return
//            }
//
//            do {
//                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                print("📩 서버 응답 데이터:", jsonResponse ?? "No Data") //  서버 응답 확인
//            } catch {
//                print("🚨 JSON 파싱 오류:", error.localizedDescription)
//            }
//        }
//
//        task.resume()
//    }
//
//
//
//
//}
