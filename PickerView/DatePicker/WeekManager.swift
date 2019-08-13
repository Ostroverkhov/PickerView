//
//  WeekManager.swift
//  PickerView
//
//  Created by Alexey Ostroverkhov on 11/08/2019.
//  Copyright © 2019 a.ostroverkhov. All rights reserved.
//

import Foundation

@objcMembers class WeekManager {
    
    //MARK: - public properties
    var week = [WeekDayWorkTime]()
    var countDays: Int
    var stepTime: DateComponents = DateComponents(minute: 5)
    var deliveryTime: DateComponents = DateComponents(hour: 0, minute: 40)
    
    //MARK: - private properties
    private var nearestDeliveryDate: Date = Date()
    private var dateConstant = DateConstant()
    
    //MARK: - init
    init(
        week: [WeekDayWorkTime],
        countDays: Int = 22
        ) {
        self.week = week
        self.countDays = countDays
    }
    
    
    func getDayModels() -> [[DateInterval]] {
        
        var result = [[DateInterval]]()
        
        var date = Date()
        let weekNumber = dateConstant.weekDay(date)
        let first = week[weekNumber]
        //TODO: add to array
        let intervals = workTime(for: date, with: date, start: first.start, end: first.end)
        print(intervals)
        result.append(intervals)
        
        for _ in 1..<countDays {
            date = startOfNext(day: date)
            let index = dateConstant.weekDay(date)
            let weekDay = week[index]
            //TODO: add to array
            let intervals = workTime(for: date, start: weekDay.start, end: weekDay.end)
            print(intervals)
            result.append(intervals)
        }
        
        return result
    }
    
    
    
    //начало следущего дня
    func startOfNext(day: Date) -> Date {
        guard let result = dateConstant.calendar.date(byAdding: DateComponents(second: 1), to: dateConstant.endOfDay(day)) else {
            fatalError()
        }
        return result
    }
    
    //Время работы в конкретный день
    func workTime(for date: Date, start: Date, end: Date) -> [DateInterval] {
        let startComponents = dateConstant.calendar.dateComponents(
            in: dateConstant.timeZone,
            from: start
        )
        
        let endComponents = dateConstant.calendar.dateComponents(
            in: dateConstant.timeZone,
            from: end
        )
        
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
    
    func workTime(for date: Date, with time: Date, start: Date, end: Date) -> [DateInterval] {
        var resultIntervals = [DateInterval]()
        
        let time = firstStep(time)
        let intervalsWork = workTime(for: date, start: start, end: end)
        let intervalToEnd = getTimeToEnd(of: time)
        
        for interval in intervalsWork {
            if let intersection = intervalToEnd.intersection(with: interval) {
                resultIntervals.append(intersection)
            }
        }
        while resultIntervals.isEmpty {
            let nextday = startOfNext(day: date)
            //FIXME: next date start and end
            let nextDayNumber = dateConstant.weekDay(nextday)
            let day = week[nextDayNumber]
            resultIntervals = workTime(for: nextday, start: day.start, end: day.end)
        }
        return resultIntervals
    }
    
    private func getTimeToEnd(of day: Date) -> DateInterval {
        return DateInterval(start: day, end: dateConstant.endOfDay(day))
    }
    
    func getDays() -> [Day] {
        var result = [Day]()
        let intervals = getDayModels()
//        let nearestDeliveryDate = Date()
//        let firstInterval = workTime(for: nearestDeliveryDate, with: nearestDeliveryDate, start: Date(), end: Date())
        guard
            let firstInterval = intervals.first,
            let firstDay = firstInterval.first?.start else {
            fatalError()
        }
        var day = firstDay
        self.nearestDeliveryDate = day
        result.append(Day(date: firstDay, intervals: firstInterval))
        
        for i in 1..<countDays {
            day = startOfNext(day: day)
            result.append(Day(date: day, intervals: intervals[i]))
        }
        return result
    }
    
    func firstStep(_ date: Date) -> Date {
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
}
