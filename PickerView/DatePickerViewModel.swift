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

struct Day {
    let date: Date
    let intervals: [DateInterval]
    var hours: [Hour]
    
    init(date: Date, intervals: [DateInterval]) {
        self.date = date
        self.intervals = intervals
        self.hours = []
    }
}

struct Hour {
    let date: Date
    let intervals: DateInterval
    var minutes: [Minute] = []
    
    init(date: Date, intervals: DateInterval) {
        self.date = date
        self.intervals = intervals
    }
}

struct Minute {
    let date: Date
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
    
    //Время работы в конкретный день
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
    
    //Ближайшее время работы в конкретный день, учитывая текущее время (ближайший рабочий интервал)
    private func getWorkTime(for date: Date, with time: Date) -> [DateInterval] {
        var resultIntervals = [DateInterval]()
        
        let intervalsWork = getWorkTime(for: date)
        let intervalToEnd = getTimeToEnd(of: date)
        
        for interval in intervalsWork {
            if let intersection = intervalToEnd.intersection(with: interval) {
                resultIntervals.append(intersection)
            }
        }
        if (resultIntervals.isEmpty){
            let nextday = startOfNext(day: date)
            resultIntervals = getWorkTime(for: nextday)
        }

        return resultIntervals
    }
    
    //Интервал до конца дня
    private func getTimeToEnd(of day: Date) -> DateInterval {
        return DateInterval(start: day, end: dateConstant.endOfDay(day))
    }
    
    //начало следущего дня
    private func startOfNext(day: Date) -> Date {
        guard let result = dateConstant.calendar.date(byAdding: DateComponents(second: 1), to: dateConstant.endOfDay(day)) else {
            fatalError()
        }
        return result
    }
    
    //Начало следущего часа
    private func startOfNext(hour: Date) -> Date {
        
        guard let result = dateConstant.calendar.date(byAdding: DateComponents(hour: 1), to: hour) else {
            fatalError()
        }
        
        var resultComponents = dateConstant.calendar.dateComponents(in: dateConstant.timeZone, from: result)
        resultComponents.minute = 0;
        resultComponents.second = 0;
        
        guard let nextHour = resultComponents.date else {
            fatalError()
        }
        
        return nextHour
    }
    
    private func startOfNext(step: Date) -> Date {
        var dateComponents = dateConstant.calendar.dateComponents(in: dateConstant.timeZone, from: step)
//        dateComponents.second = 0;
        var minute = dateComponents.minute!
        minute = minute % (Int(stepTime) / 60)
        minute = (Int(stepTime) / 60) - minute
        guard let step = dateConstant.calendar.date(byAdding: DateComponents(minute: minute, second: -dateComponents.second!), to: step) else {
            fatalError()
        }
        return step
    }
    
    private func startMinute(_ date: Date) -> Date {
        var dateComponents = dateConstant.calendar.dateComponents(in: dateConstant.timeZone, from: date)
        //        dateComponents.second = 0;
        let minute = dateComponents.minute!
        if (minute % (Int(stepTime) / 60)) == 0 {
            return date
        }
        else {
            return startOfNext(step: date)
        }
    }
 
    //функция, которая создает дни
    private func getArrayDays() -> [Day] {
        var result = [Day]()
        var day = currentTime
        let firstInterval = getWorkTime(for: day, with: day)
        guard let firstDay = firstInterval.first?.start else {
            fatalError()
        }
        result.append(Day(date: firstDay, intervals: firstInterval))
        print(firstInterval)
        for _ in 0..<(countDays - 1) {
            day = startOfNext(day: day)
            print(getWorkTime(for: day))
            result.append(Day(date: day, intervals: getWorkTime(for: day)))
        }
        return result
    }
    
    //функция, которая по интервалам дней строит разбиение по часам
//    private func getArrayHoursInterval(_ day: Day) -> [Date] {
//        var arr = [Date]()
//        for interval in day.intervals {
//            var date = interval.start
//            while(date <= interval.end) {
//                arr.append(date)
//                date = startOfNext(hour: date)
//            }
//            arr.append(interval.end)
//        }
//        return arr
//    }
    
//    private func getArrayHoursInterval(_ day: Day) -> [DateInterval] {
//        var arr = [DateInterval]()
//        for interval in day.intervals {
//            var date = interval.start
//            var hourStart = interval.start
//            var hourEnd = startOfNext(hour: interval.start)
//            while(hourStart < interval.end) {
//                arr.append(DateInterval(start: hourStart, end: hourEnd))
//                //print(DateInterval(start: hourStart, end: hourEnd))
//                hourStart = startOfNext(hour: hourStart)
//                if( startOfNext(hour: hourEnd) <= interval.end) {
//                    hourEnd = startOfNext(hour: hourEnd)
//                } else{
//                    hourEnd = interval.end
//                    arr.append(DateInterval(start: hourStart, end: hourEnd))
//                    //print(DateInterval(start: hourStart, end: hourEnd))
//
//                    break
//
//                }
//                //date = startOfNext(hour: date)
//            }
//            //arr.append(interval.end)
//        }
//        return arr
//    }
    
    private func getArrayHoursInterval(_ day: Day) -> [Hour] {
        var arr = [Hour]()
        for interval in day.intervals {
            var date = interval.start
            var hourStart = interval.start
            var hourEnd = startOfNext(hour: interval.start)
            while(hourStart < interval.end) {
                var hour: Hour = Hour(date: hourStart, intervals: DateInterval(start: hourStart, end: hourEnd))
                arr.append(hour)
                hourStart = startOfNext(hour: hourStart)
                if( startOfNext(hour: hourEnd) <= interval.end) {
                    hourEnd = startOfNext(hour: hourEnd)
                } else{
                    hourEnd = interval.end
                    hour = Hour(date: hourStart, intervals: DateInterval(start: hourStart, end: hourEnd))
                    arr.append(hour)
                    break
                }
            }
        }
        return arr
    }
    
//    private func getArrayMinute(_ hourStart: Date, _ hourEnd: Date) -> [Date] {
//        var arr = [Date]()
//        var step = startMinute(hourStart)
//        arr.append(step)
//        step = startOfNext(step: step)
//        while step < hourEnd {
//            arr.append(step)
//            step = startOfNext(step: step)
//        }
//        return arr
//    }
    
    private func getArrayMinute(_ hourStart: Date, _ hourEnd: Date) -> [Minute] {
        var arr = [Minute]()
        var step = startMinute(hourStart)
        var minute = Minute(date: step)
        arr.append(minute)
        step = startOfNext(step: step)
        while step < hourEnd {
            minute = Minute(date: step)
            arr.append(minute)
            step = startOfNext(step: step)
        }
        return arr
    }

    
    func createData() -> [Day] {
        var days = getArrayDays()
        
        for i in 0..<days.count {
            days[i].hours = getArrayHoursInterval(days[i])
            //print(days[i])
            for j in 0..<days[i].hours.count {
                days[i].hours[j].minutes = getArrayMinute(days[i].hours[j].intervals.start, days[i].hours[j].intervals.end)
                //print(days[i].hours[j].minutes)
            }
        }
        return days
    }
    
    func test() {
        //var x = getArrayHoursInterval(getArrayDays()[0])
        //print(x)
        //print(getArrayMinute(x[1].start, x[1].end))
        //createData()
    }
    
}
