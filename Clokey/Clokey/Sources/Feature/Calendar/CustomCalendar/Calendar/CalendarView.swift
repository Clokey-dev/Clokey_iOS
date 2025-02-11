//
//  CalendarView.swift
//  StudyUIKit
//
//  Created by 황상환 on 1/5/25.
//

import UIKit
import SnapKit

// MARK: - Protocol
// 날짜 선택 이벤트를 뷰컨트롤러에 전달하기 위한 프로토콜
protocol CalendarViewDelegate: AnyObject {
    func calendarView(_ calendarView: CalendarView, didSelectHistoryId historyId: Int)
    func calendarView(_ calendarView: CalendarView, didSelectDate date: Date)
}


class CalendarView: UIView {
    
    // MARK: - Properties
    weak var delegate: CalendarViewDelegate?
    private let collectionView: UICollectionView // 달력 그리드를 표시할 컬렉션 뷰
    private var dates: [Date] = [] // 표시할 날짜 배열
    private var currentMonth: Date = Date() // 현재 표시 중인 달
    
    private var imageMap: [String: String] = [:]
    private var historyIdMap: [String: Int] = [:]
        
    // 요일 레이블을 담는 스택뷰
    private let weekdayStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .center
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        // 프레임 크기로 뷰 초기화
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)
        setupCollectionView()
        setupWeekdayLabels()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    // 요일 레이블
    private func setupWeekdayLabels() {
        weekdayStack.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        weekdayStack.isLayoutMarginsRelativeArrangement = true
        weekdayStack.spacing = 2  // collectionView의 spacing과 동일하게 설정
        
        let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let cellWidth = (UIScreen.main.bounds.width - 40 - (2 * 6)) / 7  // spacing 고려한 셀 너비
        
        weekdays.forEach { day in
            let label = UILabel().then {
                $0.text = day
                $0.textColor = .textGray600
                $0.textAlignment = .center
                $0.font = .ptdBoldFont(ofSize: 12)
                // 각 레이블의 너비를 셀 너비와 동일하게 설정
                $0.widthAnchor.constraint(equalToConstant: cellWidth).isActive = true
            }
            weekdayStack.addArrangedSubview(label)
        }
    }
    
    // 컬렉션 뷰 데이터 설정
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let spacing: CGFloat = 2
            layout.minimumLineSpacing = spacing
            layout.minimumInteritemSpacing = spacing
            
            // spacing을 고려한 셀 너비 계산
            let cellWidth = (UIScreen.main.bounds.width - 40 - (2 * 6)) / 7
            let cellHeight = cellWidth * (4.0 / 3.0)
            layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
            
            layout.sectionInset = UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20)
        }
    }
    
    // 서브뷰 추가 및 레이아웃 설정
    private func setupUI() {
        addSubview(weekdayStack)
        addSubview(collectionView)
        
        // 요일
        weekdayStack.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(30)
        }
        // 날짜
        collectionView.snp.makeConstraints {
            $0.top.equalTo(weekdayStack.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    // 날짜 배열과 현재 월 업데이트
    func update(dates: [Date], currentMonth: Date, imageMap: [String: String], historyIdMap: [String: Int]) {
        self.dates = dates
        self.currentMonth = currentMonth
        self.imageMap = imageMap
        self.historyIdMap = historyIdMap
        collectionView.reloadData()
    }


}

// MARK: - CollectionView DataSource/Delegate
extension CalendarView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        let date = dates[indexPath.item]
        
        let isCurrentMonth = Calendar.current.component(.month, from: date) ==
                           Calendar.current.component(.month, from: currentMonth)
        
        let isToday = Calendar.current.isDateInToday(date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

//        let imageMapping: [String: UIImage] = [
//            "2025-02-05": UIImage(named: "sample_image")!, // 2월 5일
//            "2025-02-12": UIImage(named: "sample_image")!, // 2월 12일
//            "2025-02-04": UIImage(named: "sample_image")!,
//            "2025-02-09": UIImage(named: "sample_image")!,
//            "2025-02-23": UIImage(named: "sample_image")!,
//            "2025-02-22": UIImage(named: "sample_image")!,
//            "2025-02-28": UIImage(named: "sample_image")!
//            
//        ]
//        
//        let image = imageMapping[dateString]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
//        let dateString = formatter.string(from: date)
        
        let imageUrl = imageMap[dateString]

        cell.imageView.image = nil

        cell.configure(
            day: CalendarHelper.day(from: date),
            isSelected: false,
            isCurrentMonth: isCurrentMonth,
            isToday: isToday,
            imageUrl: imageUrl
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDate = dates[indexPath.item]

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)

        if let historyId = historyIdMap[dateString] {
            print("historyId가 \(historyId)인 세부 페이지")
            // historyId가 존재하면 상세 API 요청
            delegate?.calendarView(self, didSelectHistoryId: historyId)
        } else {
            print("아쉽게도 historyId가 없어요..")
            // historyId가 없으면 모달 띄우기
            delegate?.calendarView(self, didSelectDate: selectedDate)
        }
    }
}

