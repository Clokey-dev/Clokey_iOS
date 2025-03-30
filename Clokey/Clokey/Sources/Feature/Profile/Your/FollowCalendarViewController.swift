//
//  FollowCalendarViewController.swift
//  Clokey
//
//  Created by 한금준 on 2/20/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class FollowCalendarViewController: UIViewController {
    // MARK: - Properties
    private var currentMonth: Date = Date()
    private var dates: [Date] = []
    private let disposeBag = DisposeBag()
    
    // API 월 달력 이미지 받아오기
    private var imageMap: [String: String] = [:]
    private let historyService = HistoryService()
    // 각 날짜 historyId 저장
    private var historyIdMap: [String: Int] = [:]
    
    var followId: String = ""
    var isMe: Bool = false // 본인 확인 
    
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
    
    // 로딩 인디케이터
    private let loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.color = UIColor(named: "mainOrange800")
        $0.hidesWhenStopped = true
        $0.backgroundColor = .clear
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
        if shouldHideUserNameLabel {
            userNameLabel.isHidden = true
            userNameLabel.snp.removeConstraints()
            monthControlStack.snp.remakeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
                $0.leading.equalToSuperview().offset(25)
                $0.trailing.equalToSuperview().offset(-25)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchHistoryData(clokeyId: followId)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(userNameLabel)
        view.addSubview(monthControlStack)
        view.addSubview(calendarView)
        view.addSubview(loadingIndicator)
        
        monthControlStack.addArrangedSubview(previousMonthButton)
        monthControlStack.addArrangedSubview(monthLabel)
        monthControlStack.addArrangedSubview(nextMonthButton)
        
        userNameLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        monthControlStack.snp.makeConstraints {
            $0.top.equalTo(userNameLabel.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(25)
            $0.trailing.equalToSuperview().offset(-25)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(monthControlStack.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(500)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        // 스와이프로 캘린더 이동
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)

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
    
    // MARK: - Methods
    var shouldHideUserNameLabel: Bool = false {
        didSet {
            userNameLabel.isHidden = shouldHideUserNameLabel
            userNameLabel.snp.removeConstraints()

            // 숨겨지면 monthControlStack의 제약을 변경
            if shouldHideUserNameLabel {
                monthControlStack.snp.remakeConstraints {
                    $0.top.equalTo(view.safeAreaLayoutGuide).offset(16) // 바로 safeArea 아래에 붙이기
                    $0.leading.equalToSuperview().offset(25)
                    $0.trailing.equalToSuperview().offset(-25)
                }
            }
        }
    }

    // MARK: - Action
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            changeMonth(by: 1)
        case .right:
            changeMonth(by: -1)
        default:
            break
        }
    }
    
    // MARK: - Calendar Methods
    func updateCalendar() {
        
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
            fetchHistoryData(clokeyId: followId)
        }
    }
    
    // MARK: - API
    private func fetchHistoryData(clokeyId: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let monthString = formatter.string(from: currentMonth)
        
        // 로딩 시작 (UI 스레드에서 실행)
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
        
        historyService.historyMonth(clokeyId: clokeyId, month: monthString) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating() // 로딩 완료되면 중지
            }
            
            switch result {
            case .success(let response):
                self.imageMap = response.histories.reduce(into: [:]) { dict, history in
                    dict[history.date] = history.imageUrl
                }
                self.historyIdMap = response.histories.reduce(into: [:]) { dict, history in
                    dict[history.date] = history.historyId
                }
                self.userNameLabel.text = "\(response.nickName)의 스타일 캘린더"
                self.updateCalendar()
                
            case .failure(let error):
                print("캘린더 데이터 로드 실패: \(error.localizedDescription)")
                self.showAlert(title: "네트워크 오류", message: "인터넷 연결이 원활하지 않아요.\n잠시 후 다시 시도해 주세요.")
            }
        }
    }

}

//// MARK: - CalendarViewDelegate
extension FollowCalendarViewController: CalendarViewDelegate {
    func calendarView(_ calendarView: CalendarView, didSelectHistoryId historyId: Int) {
        fetchHistoryDetail(historyId: historyId)
    }

    func calendarView(_ calendarView: CalendarView, didSelectDate date: Date) {

    }

    private func fetchHistoryDetail(historyId: Int) {
        let historyService = HistoryService()

        historyService.historyDetail(historyId: historyId) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                print("히스토리 상세 조회 성공: \(response)")
                
                if isMe {
                    // 본인 -> CalendarDetailViewController로
                    let detailVC = CalendarDetailViewController()
                    detailVC.setDetailData(response)
                    self.navigationController?.pushViewController(detailVC, animated: true)
                } else {
                    // 타인 -> FriendsCalendarDetailViewController로
                    let detailVC = FriendsCalendarDetailViewController()
                    detailVC.setDetailData(response)
                    self.navigationController?.pushViewController(detailVC, animated: true)
                }

            case .failure(let error):
                print("히스토리 상세 조회 실패: \(error.localizedDescription)")
                self.showAlert(title: "네트워크 오류", message: "인터넷 연결이 원활하지 않아요.\n잠시 후 다시 시도해 주세요.")
            }
        }
    }
}

