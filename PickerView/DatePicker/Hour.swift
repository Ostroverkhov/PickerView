//
//  Hour.swift
//  anteyservice
//
//  Created by a.ostroverkhov on 26/10/2018.
//  Copyright © 2018 spider. All rights reserved.
//

import Foundation

@objcMembers class Hour: NSObject {
    let date: Date
    let intervals: DateInterval
    var minutes: [Minute] = []
    
    init(date: Date, intervals: DateInterval) {
        self.date = date
        self.intervals = intervals
    }
    
    override var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd:MM:yyyy'T'HH:mmZZZZ"
        return dateFormatter.string(from: date)
    }
}
