//
//  DatePickerViewModel.swift
//  PickerView
//
//  Created by a.ostroverkhov on 08/10/2018.
//  Copyright © 2018 a.ostroverkhov. All rights reserved.
//

import Foundation

struct PickerData {
    let days: [Date]
    let hours: [Date]
    let minuts: [Date]
}

struct PickerData2 {
    let days: [Day]
}

struct Day {
    let output: String
    let days: [DateInterval]
}

struct Hour {
    let output: String
    let hour: [DateInterval]
}

class DatePickerViewModel {
    var startTime: Date = Date()
    var endTime: Date = Date()
    var currentTime: Date = Date()
    var stepTime: TimeInterval = 300.0
    private let timeZone = TimeZone.current
    private let calendar = Calendar.current
    private let day: TimeInterval = 86400
    private let hour: TimeInterval = 3600
    private let minut: TimeInterval = 300
    private let coutnDays: Int = 3
    
    private var startComponents: DateComponents = DateComponents()
    private var endComponents: DateComponents = DateComponents()
    private var currentComponents:DateComponents = DateComponents()
    
    init(start: Date, end: Date, step: TimeInterval) {
        self.startTime = start
        self.endTime = end
        self.stepTime = step
    }
    
    init(start: Date, end: Date, current: Date, step: TimeInterval) {
        self.startTime = start
        self.endTime = end
        self.currentTime = current
        self.stepTime = step
    }
    
    init(start: String, end: String) {
        let dateFormatter = DateFormatter()
        //dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "HH:mm"
        
        guard let startTime = dateFormatter.date(from: start) else {
            fatalError("invalid start date")
        }
        print(timeZone)
        
        guard let endTime = dateFormatter.date(from: end) else {
            fatalError("invalid start date")
        }
        
        self.startTime = startTime
        self.endTime = endTime
    }
    
    private func setComponets() {
        startComponents = calendar.dateComponents(in: timeZone, from: startTime)
        endComponents = calendar.dateComponents(in: timeZone, from: endTime)
        currentComponents = calendar.dateComponents(in: timeZone, from: currentTime)
    }
    
    private func getTodayTimeWork() -> (strart: DateComponents, end: DateComponents) {
        setComponets()
        let hourStart = startComponents.hour
        let minStart = startComponents.minute
        let hourEnd = endComponents.hour
        let minEnd = endComponents.minute
        
        let todayTimeStart = DateComponents(
            calendar: Calendar.current,
            timeZone: timeZone,
            year: currentComponents.year,
            month: currentComponents.month,
            day: currentComponents.day,
            hour: hourStart,
            minute: minStart
        )
//        let x = todayTimeStart.date?.description(with: Locale.current)
//        print(x)
        let todayTimeEnd = DateComponents(
            calendar: Calendar.current,
            timeZone: timeZone,
            year: currentComponents.year,
            month: currentComponents.month,
            day: currentComponents.day,
            hour: hourEnd,
            minute: minEnd
        )
        

        return (todayTimeStart, todayTimeEnd)
    }
    
    private func getNextDay(_ day: Date) -> Date {
        return day + self.day
    }
    
    private func nextDayIntervalWork(_ intervals: [DateInterval]) -> [DateInterval] {
        var result = [DateInterval]()
        for interval in intervals {
            result.append(DateInterval(start: getNextDay(interval.start), end: getNextDay(interval.end)))
        }
        return result
    }
    
    private func nextAllDayInterval(_ interval: DateInterval) -> DateInterval {
        let endDay = DateComponents(
            calendar: Calendar.current,
            timeZone: timeZone,
            year: currentComponents.year,
            month: currentComponents.month,
            day: currentComponents.day! + 1,
            hour: 23,
            minute: 59,
            second: 59
        )
        return DateInterval(start: interval.start, end: endDay.date!)
    }
    
    private func add(_ day: Date, minute: Int) -> Date {
        let minute = minute * 60
        return day + TimeInterval(minute)
    }
    
    private func addFiviMinute(_ day: Date) -> Date {
        let minute = 5 * 60
        return day + TimeInterval(minute)
    }
    
    private func firstWorkDay() -> [DateInterval] {
        let time = getTodayTimeWork()
        var intervalsWork = getIntervals(start: time.strart, end: time.end)
        var intervalToday = intervalToEndDay()
        var resultIntervals = [DateInterval]()
        for interval in intervalsWork {
            if let intersection = intervalToday.intersection(with: interval) {
                resultIntervals.append(intersection)
            }
        }
        if resultIntervals.isEmpty {
            intervalsWork = nextDayIntervalWork(intervalsWork)
            intervalToday = nextAllDayInterval(intervalToday)
            for interval in intervalsWork {
                if let intersection = intervalToday.intersection(with: interval) {
                    resultIntervals.append(intersection)
                }
            }
        }
        
        return resultIntervals
    }
    
    private func intervalToEndDay() -> DateInterval {
        let endDay = DateComponents(
            calendar: Calendar.current,
            timeZone: timeZone,
            year: currentComponents.year,
            month: currentComponents.month,
            day: currentComponents.day,
            hour: 23,
            minute: 59,
            second: 59
        )
        return DateInterval(start: currentTime, end: endDay.date!)
    }
    
    private func firstDayWorkTime() {
        
    }
    
    private func getIntervals(start: DateComponents, end: DateComponents) -> [DateInterval] {
        var dayIntervalsWork = [DateInterval]()
        
        guard let start = start.date else {
            fatalError()
        }
        guard let end = end.date else {
            fatalError()
        }
        
        let startCurrentDay = Calendar.current.startOfDay(for: Date())

        let endDay = DateComponents(
            calendar: Calendar.current,
            timeZone: timeZone,
            year: currentComponents.year,
            month: currentComponents.month,
            day: currentComponents.day,
            hour: 23,
            minute: 59,
            second: 59
        )
        
        guard let endCurrentDay = endDay.date else {
            fatalError()
        }
        
        if(start < end) {
            dayIntervalsWork.append(DateInterval(start: start, end: end))
        } else {

            dayIntervalsWork.append(DateInterval(start: startCurrentDay, end: end))
            dayIntervalsWork.append(DateInterval(start: start, end: endCurrentDay))
        }
        return dayIntervalsWork
    }
    
    private func splitIntervals(_ intervals: [DateInterval]) {
        
        
//        for i in 0..<intervals.count {//дни
//            var tempHour = intervals[i].start
//            while tempHour < intervals[i].end {
//                print(tempHour.description(with: Locale.current));
//                var tempMin = calendar.dateComponents(in: timeZone, from: tempHour).minute
//                while tempMin! < Int(hour)/60 {
//                    //print(tempMin)
//                    tempMin! += Int(minut)/60
//                }
//                tempHour = tempHour + hour;
//            }
//        }
    }
    
    func test() {
        //splitIntervals(getIntervals(start: getTodayTimeWorkDays().strart, end: getTodayTimeWorkDays().end));
        print(firstWorkDay())
    }
}
