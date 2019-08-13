//
//  DateConstant.swift
//  anteyservice
//
//  Created by a.ostroverkhov on 26/10/2018.
//  Copyright © 2018 spider. All rights reserved.
//

import Foundation

@objcMembers class DateConstant: NSObject {
    var timeZone:TimeZone {
        return TimeZone.current
    }
    
    var calendar: Calendar {
        return Calendar.current
    }
    
    var weekDaysCount: Int {
        return 7
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
    
    func weekDay(_ date: Date) -> Int {
        let value = calendar.component(.weekday, from: date)
        return value == 1 ? 6 : value - 2
    }
}
