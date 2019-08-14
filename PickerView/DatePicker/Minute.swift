//
//  Minute.swift
//  anteyservice
//
//  Created by a.ostroverkhov on 26/10/2018.
//  Copyright © 2018 spider. All rights reserved.
//

import Foundation

@objcMembers class Minute: NSObject {
    let date: Date
    init(date: Date) {
        self.date = date
    }
    
    override var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mmZZZZ"
        return dateFormatter.string(from: date)
    }
}
