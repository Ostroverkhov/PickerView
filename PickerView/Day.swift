//
//  Day.swift
//  anteyservice
//
//  Created by a.ostroverkhov on 26/10/2018.
//  Copyright © 2018 spider. All rights reserved.
//

import Foundation

@objcMembers class Day: NSObject {
    let date: Date
    let intervals: [DateInterval]
    var hours: [Hour]
    
    init(date: Date, intervals: [DateInterval]) {
        self.date = date
        self.intervals = intervals
        self.hours = []
    }
}
