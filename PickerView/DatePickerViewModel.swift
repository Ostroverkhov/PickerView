//
//  DatePickerViewModel.swift
//  PickerView
//
//  Created by a.ostroverkhov on 10/10/2018.
//  Copyright © 2018 a.ostroverkhov. All rights reserved.
//

import Foundation


struct DateConstant {
    var day: DateComponents {
        return DateComponents(day: 1)
    }
    
    var hour: DateComponents {
        return DateComponents(hour: 1)
    }
    
    var minute: DateComponents {
        return DateComponents(minute: 1)
    }
    
    var timeZone:TimeZone {
        return TimeZone.current
    }
    
    var calendar: Calendar {
        return Calendar.current
    }
    
    func startOfDay(_ date: Date) -> Date {
        return calendar.startOfDay(for: date)
    }
    
    func endOfDay(_ date: Date) -> Date {
        
        guard
            let nextDay = calendar.date(
                byAdding: day,
                to: calendar.startOfDay(for: date)
            ),
            
            let endDay = calendar.date(
                byAdding: DateComponents(second: -1),
                to: calendar.startOfDay(for: nextDay)
            )
        else {
                fatalError()
        }
        return endDay
    }
}

class DatePickerViewModel {
    var startTime: Date = Date()
    var endTime: Date = Date()
    var currentTime: Date = Date()
    var stepTime: TimeInterval = 300.0
    var countDays: Int = 3
    
    private var dateConstant = DateConstant()
    
    private var startComponents: DateComponents = DateComponents()
    private var endComponents: DateComponents = DateComponents()
    private var currentComponents:DateComponents = DateComponents()
    
    init(start: Date, end: Date, step: TimeInterval) {
        self.startTime = start
        self.endTime = end
        self.stepTime = step
        setComponets()
    }
    
    init(start: Date, end: Date, current: Date, step: TimeInterval) {
        self.startTime = start
        self.endTime = end
        self.currentTime = current
        self.stepTime = step
        setComponets()
    }
    
    init(start: String, end: String) {
        let dateFormatter = DateFormatter()
        //dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "HH:mm"
        
        guard let startTime = dateFormatter.date(from: start) else {
            fatalError("invalid start date")
        }
        
        guard let endTime = dateFormatter.date(from: end) else {
            fatalError("invalid end date")
        }
        
        self.startTime = startTime
        self.endTime = endTime
        setComponets()
    }

    private func setComponets() {
        startComponents = dateConstant.calendar.dateComponents(in: dateConstant.timeZone, from: startTime)
        endComponents = dateConstant.calendar.dateComponents(in: dateConstant.timeZone, from: endTime)
        currentComponents = dateConstant.calendar.dateComponents(in: dateConstant.timeZone, from: currentTime)
    }
    
    //Время работы
    private func getWorkTime(for date: Date) -> [DateInterval] {
        var todayTimeStart = dateConstant.calendar.dateComponents(in: dateConstant.timeZone, from: date)
        todayTimeStart.calendar = dateConstant.calendar
        todayTimeStart.timeZone = dateConstant.timeZone
        todayTimeStart.hour = startComponents.hour
        todayTimeStart.minute = startComponents.minute
        todayTimeStart.second = 0

        var todayTimeEnd = dateConstant.calendar.dateComponents(in: dateConstant.timeZone, from: date)
        todayTimeEnd.calendar = dateConstant.calendar
        todayTimeEnd.timeZone = dateConstant.timeZone
        todayTimeEnd.hour = endComponents.hour
        todayTimeEnd.minute = endComponents.minute
        todayTimeEnd.second = 0
        
        guard let start = todayTimeStart.date else {
            fatalError()
        }
        
        guard let end = todayTimeEnd.date else {
            fatalError()
        }
        
        var intervals = [DateInterval]()
        if start < end {
            intervals.append(DateInterval(start: start, end: end))
        } else {
            intervals.append(DateInterval(start: dateConstant.startOfDay(date), end: end))
            intervals.append(DateInterval(start: start, end: dateConstant.endOfDay(date)))
        }
        
        return intervals
    }
    
    private func getWorkTime(for date: Date, with time: Date) -> [DateInterval] {
        var resultIntervals = [DateInterval]()
        
        var intervalsWork = getWorkTime(for: date)
        var intervalToEnd = getTimeToEnd(of: date)
        
        for interval in intervalsWork {
            if let intersection = intervalToEnd.intersection(with: interval) {
                resultIntervals.append(intersection)
            }
        }
        
        if (resultIntervals.isEmpty) {
        }
        return resultIntervals
    }
    
    private func getTimeToEnd(of day: Date) -> DateInterval {
        return DateInterval(start: day, end: dateConstant.endOfDay(day))
    }

    func test() {
        print(getWorkTime(for: currentTime))
        var date = currentTime
        for _ in 0..<countDays {
            guard let x = dateConstant.calendar.date(byAdding: dateConstant.day, to: date) else {
                fatalError()
            }
            date = x
            print(getWorkTime(for: date))
        }
    }
    
}
