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
    var week = [WeekDayWorkTime?]()
    var countDays: Int = 5

    //MARK: - private properties
    private var nearestDeliveryDate: Date = Date()
    private var dateConstant = DateConstant()
    
    //MARK: - init
    init(
        week: [WeekDayWorkTime],
        countDays: Int = 5
        ) {
        self.week = week
        self.countDays = countDays
    }
}
