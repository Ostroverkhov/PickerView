//
//  WeekDayWorkTime.swift
//  PickerView
//
//  Created by Alexey Ostroverkhov on 11/08/2019.
//  Copyright © 2019 a.ostroverkhov. All rights reserved.
//

import Foundation

@objcMembers class WeekDayWorkTime {

    //MARK: - public properties
    var start: Date
    var end: Date
    
    //MARK: - private properties
    private var dateConstant = DateConstant()

    init(
        start: Date,
        end: Date
        ) {
        self.start = start
        self.end = end
    }
    
    convenience init(
        start: String,
        end: String,
        format: String = "HH:mmZZZZZ"
        ) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        guard
            let startTime = dateFormatter.date(from: start),
            let endTime = dateFormatter.date(from: end)
            else {
                fatalError("invalid date")
        }
        
        self.init(
            start: startTime,
            end: endTime
        )
    }
}
