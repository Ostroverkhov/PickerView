//
//  DatePickerViewModel.swift
//  PickerView
//
//  Created by a.ostroverkhov on 10/10/2018.
//  Copyright © 2018 a.ostroverkhov. All rights reserved.
//

import Foundation
    
@objcMembers class DatePickerViewModel: NSObject {
    
    //MARK: - public properties
    var week = [WeekDayWorkTime]()
    var startTime: Date = Date()
    var endTime: Date = Date()
    var stepTime: DateComponents = DateComponents(minute: 5)
    var countDays: Int = 5
    var deliveryTime: DateComponents = DateComponents(hour: 0, minute: 40)

    //MARK: - private properties
    private var nearestDeliveryDate: Date = Date()
    private var dateConstant = DateConstant()    
    
    //MARK: - init
    override init() {
        super.init()
    }
    
    init(
        start: Date,
        end: Date,
        current: Date = Date(),
        step: DateComponents = DateComponents(minute: 5),
        count: Int = 2,
        deliveryTime: DateComponents = DateComponents(hour: 0, minute: 40)
        ) {
        super.init()
        
        guard
            let tempStart = Calendar.current.date(byAdding: deliveryTime, to: start),
            let tempEnd = Calendar.current.date(byAdding: deliveryTime, to: end),
            let tempCurrent = Calendar.current.date(byAdding: deliveryTime, to: current)
            else {
                fatalError()
        }
        
        self.startTime = firstStep(tempStart)
        self.endTime = firstStep(tempEnd)
        self.nearestDeliveryDate = firstStep(tempCurrent)
        self.stepTime = step
        self.countDays = count
        self.deliveryTime = deliveryTime
    }
    
    convenience init(start: String, end: String, format: String = "HH:mmZZZZZ") {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        guard
            let startTime = dateFormatter.date(from: start),
            let endTime = dateFormatter.date(from: end)
        else {
            fatalError("invalid date")
        }
        
        self.init(start: startTime, end: endTime, current: Date(), step: DateComponents(minute: 5))
    }
    
    convenience init(start: String, end: String, current: String, format: String = "dd:MM:yyyy'T'HH:mmZZZZ") {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        
        guard
            let startTime = dateFormatter.date(from: start),
            let endTime = dateFormatter.date(from: end),
            let currentTime = dateFormatter.date(from: current)
            else {
                fatalError("invalid date")
        }
        
        self.init(start: startTime, end: endTime, current: currentTime, step: DateComponents(minute: 5))
    }
    
    //MARK: - public methods
    func createData() -> [Day] {
        var days = getDays()
        
        for i in 0..<days.count {
            days[i].hours = getHours(for: days[i])
            for j in 0..<days[i].hours.count {
                days[i].hours[j].minutes = getMinutes(for: days[i].hours[j].intervals)
            }
        }
        return days
    }
    
    //MARK: - private methods

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
            preconditionFailure()
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
        let startComponents = dateConstant.calendar.dateComponents(in: dateConstant.timeZone, from: startTime)
        let endComponents = dateConstant.calendar.dateComponents(in: dateConstant.timeZone, from: endTime)
        
        guard
            let startHour = startComponents.hour,
            let startMinute = startComponents.minute,
            let endHour = endComponents.hour,
            let endMinute = endComponents.minute
            else {
                fatalError()
        }
        
        guard
            let start = dateConstant.calendar.date(
                bySettingHour: startHour,
                minute: startMinute,
                second: 0,
                of: date
            ),
            let tempEnd = dateConstant.calendar.date(
                bySettingHour: endHour,
                minute: endMinute,
                second: 0,
                of: date
            )
            else {
                fatalError()
        }
        
        
        var intervals = [DateInterval]()
        if start < tempEnd {
            intervals.append(DateInterval(start: start, end: tempEnd))
            
        } else if start > tempEnd {
            intervals.append(DateInterval(start: dateConstant.startOfDay(date), end: tempEnd))
            intervals.append(DateInterval(start: start, end: dateConstant.endOfDay(date)))
            
        } else if start == tempEnd{
            intervals.append(DateInterval(start: dateConstant.startOfDay(date), end: dateConstant.endOfDay(date)))
        }
        
        return intervals
    }
    
    private func getWorkTime(for date: Date, with time: Date) -> [DateInterval] {
        var resultIntervals = [DateInterval]()
        
        let intervalsWork = getWorkTime(for: date)
        let intervalToEnd = getTimeToEnd(of: time)
        
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
    
    private func getDays() -> [Day] {
        var result = [Day]()
        
        let firstInterval = getWorkTime(for: nearestDeliveryDate, with: nearestDeliveryDate)
        guard let firstDay = firstInterval.first?.start else {
            fatalError()
        }
        var day = firstDay
        self.nearestDeliveryDate = day
        result.append(Day(date: firstDay, intervals: firstInterval))
        
        for _ in 0..<(countDays - 1) {
            day = startOfNext(day: day)
            result.append(Day(date: day, intervals: getWorkTime(for: day)))
        }
        return result
    }
    
    private func getHours(for day: Day) -> [Hour] {
        var arr = [Hour]()
        for interval in day.intervals {
            var hourStart = interval.start
            var hourEnd = startOfNext(hour: hourStart) < interval.end ? startOfNext(hour: hourStart) : interval.end
            while(hourStart < interval.end) {
                var hour = Hour(date: hourStart, intervals: DateInterval(start: hourStart, end: hourEnd))
                arr.append(hour)
                hourStart = startOfNext(hour: hourStart)
                if(startOfNext(hour: hourEnd) <= interval.end) {
                    hourEnd = startOfNext(hour: hourEnd)
                } else if (hourStart < interval.end) {
                    hourEnd = interval.end
                    hour = Hour(date: hourStart, intervals: DateInterval(start: hourStart, end: hourEnd))
                    arr.append(hour)
                    break
                }
            }
        }
        return arr
    }
    
    private func getMinutes(for hour: DateInterval) -> [Minute] {
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
}

