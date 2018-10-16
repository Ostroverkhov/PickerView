//
//  DatePickerViewModel.swift
//  PickerView
//
//  Created by a.ostroverkhov on 10/10/2018.
//  Copyright © 2018 a.ostroverkhov. All rights reserved.
//

import Foundation

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


struct DateConstant {
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
                byAdding: DateComponents(day: 1),
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
    var stepTime: DateComponents = DateComponents(minute: 5)
    var countDays: Int = 3
    var deliveryTime: DateComponents = DateComponents(hour: 0, minute: 30)
    
    private var dateConstant = DateConstant()
    
    private var startComponents: DateComponents = DateComponents()
    private var endComponents: DateComponents = DateComponents()
    private var currentComponents:DateComponents = DateComponents()
    
    init(start: Date, end: Date, step: DateComponents) {
        guard
            let start = dateConstant.calendar.date(byAdding: deliveryTime, to: start),
            let current = dateConstant.calendar.date(byAdding: deliveryTime, to: currentTime)
        else {
            fatalError()
        }
        
        self.startTime = firstStep(start)
        self.endTime = end
        self.currentTime = firstStep(current)
        self.stepTime = step
        setComponets()
    }
    
    init(start: Date, end: Date, current: Date, step: DateComponents) {
        guard
            let start = dateConstant.calendar.date(byAdding: deliveryTime, to: start),
            let current = dateConstant.calendar.date(byAdding: deliveryTime, to: currentTime)
        else {
                fatalError()
        }
        
        self.startTime = firstStep(start)
        self.endTime = end
        self.currentTime = firstStep(current)
        self.stepTime = step
        setComponets()
    }
    
    init(start: String, end: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        guard let startTime = dateFormatter.date(from: start) else {
            fatalError("invalid start date")
        }
        
        guard let endTime = dateFormatter.date(from: end) else {
            fatalError("invalid end date")
        }
        
        guard
            let start = dateConstant.calendar.date(byAdding: deliveryTime, to: startTime),
            let current = dateConstant.calendar.date(byAdding: deliveryTime, to: currentTime)
        else {
                fatalError()
        }
        
        self.startTime = firstStep(start)
        self.endTime = endTime
        self.currentTime = firstStep(current)
        setComponets()
    }

    private func setComponets() {
        startComponents = dateConstant.calendar.dateComponents(in: dateConstant.timeZone, from: startTime)
        endComponents = dateConstant.calendar.dateComponents(in: dateConstant.timeZone, from: endTime)
        currentComponents = dateConstant.calendar.dateComponents(in: dateConstant.timeZone, from: currentTime)
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
    
    private func firstStep(_ date: Date) -> Date {
        var dateComponents = dateConstant.calendar.dateComponents(in: dateConstant.timeZone, from: date)
        
        guard
            let minute = dateComponents.minute,
            let step = stepTime.minute,
            let second = dateComponents.second
        else {
            fatalError()
        }
        let timeToStep = (minute % step) == 0 ? 0 : step - (minute % step)
        
        guard let first = dateConstant.calendar.date(byAdding: DateComponents(minute: timeToStep, second: -second), to: date) else {
            fatalError()
        }
        
        return first
    }
    
    //Next Step
    private func next(step: Date) -> Date {
        guard let nextStep = dateConstant.calendar.date(byAdding: stepTime, to: step) else {
            fatalError()
        }
        return nextStep
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
        
        guard let end1 = dateConstant.calendar.date(byAdding: DateComponents(second: -1), to: end) else {
            fatalError()
        }
        
        var intervals = [DateInterval]()
        if start < end {
            intervals.append(DateInterval(start: start, end: end1))
        } else {
            intervals.append(DateInterval(start: dateConstant.startOfDay(date), end: end1))
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
    
    //функция, которая создает дни
    private func getArrayDays() -> [Day] {
        var result = [Day]()
        
        let firstInterval = getWorkTime(for: currentTime, with: currentTime)
        guard let firstDay = firstInterval.first?.start else {
            fatalError()
        }
        var day = firstDay
        
        result.append(Day(date: firstDay, intervals: firstInterval))

        for _ in 0..<(countDays - 1) {
            day = startOfNext(day: day)
            result.append(Day(date: day, intervals: getWorkTime(for: day)))
        }
        return result
    }
    
    private func getArrayHoursInterval(_ day: Day) -> [Hour] {
        var arr = [Hour]()
        for interval in day.intervals {
            var hourStart = interval.start
            var hourEnd = startOfNext(hour: interval.start)
            while(hourStart < interval.end) {
                var hour = Hour(date: hourStart, intervals: DateInterval(start: hourStart, end: hourEnd))
                arr.append(hour)
                hourStart = startOfNext(hour: hourStart)
                if(startOfNext(hour: hourEnd) <= interval.end) {
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
    

    private func getArrayMinute(_ hour: DateInterval) -> [Minute] {
        var arr = [Minute]()
        var step = firstStep(hour.start)
        var minute = Minute(date: step)
        arr.append(minute)
        step = next(step: step)
        while step < hour.end {
            minute = Minute(date: step)
            arr.append(minute)
            step = next(step: step)
        }
        return arr
    }
    
    func createData() -> [Day] {
        var days = getArrayDays()
        
        for i in 0..<days.count {
            days[i].hours = getArrayHoursInterval(days[i])
            for j in 0..<days[i].hours.count {
                days[i].hours[j].minutes = getArrayMinute(days[i].hours[j].intervals)
            }
        }
        return days
    }
}
