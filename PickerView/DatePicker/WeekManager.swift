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
        
        self.countDays = countDays
        self.week = week.map {
            WeekDayWorkTime(
                start: firstStep($0.start),
                end: firstStep($0.end)
            )
        }
        self.nearestDeliveryDate = firstStep(Date())
    }
    
    
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
    
    
    func getDayModels() -> [[DateInterval]] {
        
        var result = [[DateInterval]]()
        
        var date = Date()
        let weekNumber = dateConstant.weekDay(date)
        let first = week[weekNumber]
        let intervals = workTime(for: date, with: date, start: first.start, end: first.end)
        result.append(intervals)
        
        for _ in 1..<countDays {
            date = startOfNext(day: date)
            let index = dateConstant.weekDay(date)
            let weekDay = week[index]
            let intervals = workTime(for: date, start: weekDay.start, end: weekDay.end)
            result.append(intervals)
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
    
    func getHours(for day: Day) -> [Hour] {
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
    
    func getMinutes(for hour: DateInterval) -> [Minute] {
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
    
    //MARK - steps
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
    
    private func next(step: Date) -> Date {
        guard let nextStep = dateConstant.calendar.date(byAdding: stepTime, to: step) else {
            fatalError()
        }
        return nextStep
    }
    
    func startOfNext(day: Date) -> Date {
        guard let result = dateConstant.calendar.date(byAdding: DateComponents(second: 1), to: dateConstant.endOfDay(day)) else {
            fatalError()
        }
        return result
    }
    
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
}
