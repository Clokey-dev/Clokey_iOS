//
//  CalendarHelper.swift
//  StudyUIKit
//
//  Created by 황상환 on 1/5/25.
//

import Foundation

class CalendarHelper {
    
    // 캘린더 시스템
    static let calendar = Calendar.current
    
    // 날짜 반환
    static func day(from date: Date) -> Int {
        return calendar.component(.day, from: date)
    }
    
    // 현재 월의 시작일을 반환
    static func startOfMonth(_ month: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: month)
        return calendar.date(from: components)!
    }

    // 주어진 월의 총 일수 반환
    static func numberOfDays(in month: Date) -> Int {
        return calendar.range(of: .day, in: .month, for: month)?.count ?? 0
    }

    // 주어진 월의 1일이 무슨 요일인지 [1 : 월요일 - 7 : 일요일]
    static func firstWeekdayOfMonth(in month: Date) -> Int {
        let components = calendar.dateComponents([.year, .month], from: month)
        guard let firstDayOfMonth = calendar.date(from: components) else { return 0 }
        return calendar.component(.weekday, from: firstDayOfMonth)
    }
    
    // 달력에 표시할 전체 날짜 배열 생성
    static func generateDates(for month: Date) -> [Date] {
        var dates: [Date] = []
        let startOfMonth = startOfMonth(month)
        let daysInMonth = numberOfDays(in: month)
        let firstWeekday = firstWeekdayOfMonth(in: month) - 1

        // 이전 날짜
        if firstWeekday > 0 {
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: month)!
            let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonth)?.count ?? 0
            let startDay = daysInPreviousMonth - firstWeekday + 1
            
            for day in startDay...daysInPreviousMonth {
                if let date = calendar.date(from: calendar.dateComponents([.year, .month], from: previousMonth)).flatMap({ baseDate in
                    calendar.date(byAdding: .day, value: day - 1, to: baseDate)
                }) {
                    dates.append(date)
                }
            }
        }

        // 현재 날짜
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                dates.append(date)
            }
        }

        // 다음 날짜
        let totalDays = dates.count
        if totalDays % 7 != 0 {
            let remainingDays = 7 - (totalDays % 7)
            let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            for day in 0..<remainingDays {
                if let date = calendar.date(byAdding: .day, value: day, to: nextMonthStart) {
                    dates.append(date)
                }
            }
        }
        
        return dates
    }
}
