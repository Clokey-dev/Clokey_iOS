//
//  CalendarViewController.swift
//  StudyUIKit
//
//  Created by 황상환 on 1/3/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class CalendarViewController: UIViewController {
    // MARK: - Properties
    private var currentMonth: Date = Date()
    private var dates: [Date] = []
    private let disposeBag = DisposeBag()
    
    // API 월 달력 이미지 받아오기
    private var imageMap: [String: String] = [:]
    private let historyService = HistoryService()
    // 각 날짜 historyId 저장
    private var historyIdMap: [String: Int] = [:]
    
    // MARK: - UI Components
    
    private let userNameLabel = UILabel().then {
        $0.text = "클루님의 스타일 캘린더"
        $0.textAlignment = .left
        $0.font = .ptdMediumFont(ofSize: 20)
    }
    
    // ◀ 월 ▶ 스택뷰
    private let monthControlStack = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 16
    }
    
    // 월 라벨
    private let monthLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .ptdBoldFont(ofSize: 16)
    }

    // 이전 버튼
    private let previousMonthButton = UIButton(type: .system).then {
        $0.setTitle("◀", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .ptdBoldFont(ofSize: 16)
    }

    // 다은 버튼
    private let nextMonthButton = UIButton(type: .system).then {
        $0.setTitle("▶", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .ptdBoldFont(ofSize: 16)
    }
    
    // 달력 뷰 표시
    private let calendarView = CalendarView()
    
    // 각 셀 모달
    private let uploadModalView = UploadModalView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        updateCalendar()
        
        calendarView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchHistoryData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(userNameLabel)
        view.addSubview(monthControlStack)
        view.addSubview(calendarView)
        
        monthControlStack.addArrangedSubview(previousMonthButton)
        monthControlStack.addArrangedSubview(monthLabel)
        monthControlStack.addArrangedSubview(nextMonthButton)
        
        userNameLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        monthControlStack.snp.makeConstraints {
            $0.top.equalTo(userNameLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(25)
            $0.trailing.equalToSuperview().offset(-25)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(monthControlStack.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(500)
        }
    }
    
    private func setupBindings() {
        previousMonthButton.rx.tap
            .bind { [weak self] in
                self?.changeMonth(by: -1)
            }
            .disposed(by: disposeBag)
        
        nextMonthButton.rx.tap
            .bind { [weak self] in
                self?.changeMonth(by: 1)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Calendar Methods
    private func updateCalendar() {
        
        // CalendarHelper 로 날짜들 생성
        dates = CalendarHelper.generateDates(for: currentMonth)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        monthLabel.text = dateFormatter.string(from: currentMonth)
        
        calendarView.update(dates: dates, currentMonth: currentMonth, imageMap: imageMap, historyIdMap: historyIdMap)
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
            updateCalendar()
            fetchHistoryData()
        }
    }
    
    // MARK: - API
    private func fetchHistoryData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let monthString = formatter.string(from: currentMonth)
        
        historyService.historyMonth(clokeyId: nil, month: monthString) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.imageMap = response.histories.reduce(into: [:]) { dict, history in
                    dict[history.date] = history.imageUrl
                }
                self.historyIdMap = response.histories.reduce(into: [:]) { dict, history in
                    dict[history.date] = history.historyId  // historyId 저장
                }
                self.updateCalendar()
            case .failure(let error):
                print("캘린더 데이터 로드 실패: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - CalendarViewDelegate
//extension CalendarViewController: CalendarViewDelegate {
//    func calendarView(_ calendarView: CalendarView, didSelectDate date: Date) {
//        // 모달 전체 화면
//        let modalVC = UploadModalViewController()
//        modalVC.sourceViewController = self
//        // 이걸 써야 뷰 업데이트가 됨.
//        // Modal이 dismiss되면
//        // 1. Calendar → Modal 강한 참조 끊김
//        // 2. Modal → Calendar 약한 참조는 이미 weak
//        // 3. 둘 다 메모리에서 정상적으로 해제됨
//        
//        modalVC.modalPresentationStyle = .overFullScreen
//        modalVC.modalTransitionStyle = .crossDissolve
//        modalVC.setDate(date) // 모달 날짜 선택 날짜로 설정
//        present(modalVC, animated: false)
//        print("Selected date: \(date)")
//    }
//}

extension CalendarViewController: CalendarViewDelegate {
    func calendarView(_ calendarView: CalendarView, didSelectHistoryId historyId: Int) {
        fetchHistoryDetail(historyId: historyId)
    }

    func calendarView(_ calendarView: CalendarView, didSelectDate date: Date) {
        // 이걸 써야 뷰 업데이트가 됨.
        // Modal이 dismiss되면
        // 1. Calendar → Modal 강한 참조 끊김
        // 2. Modal → Calendar 약한 참조는 이미 weak
        // 3. 둘 다 메모리에서 정상적으로 해제됨
        let modalVC = UploadModalViewController()
        modalVC.sourceViewController = self
        modalVC.modalPresentationStyle = .overFullScreen
        modalVC.modalTransitionStyle = .crossDissolve
        modalVC.setDate(date)
        present(modalVC, animated: false)
    }

    private func fetchHistoryDetail(historyId: Int) {
        historyService.historyDetail(historyId: historyId) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                print("히스토리 상세 조회 성공: \(response)")
                let detailVC = CalendarDetailViewController()
                detailVC.setDetailData(response) //  상세 데이터 전달
                self.navigationController?.pushViewController(detailVC, animated: true)

            case .failure(let error):
                print("히스토리 상세 조회 실패: \(error.localizedDescription)")
            }
        }
    }
}
