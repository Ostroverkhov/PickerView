//
//  DatePickerDataSource.swift
//  PickerView
//
//  Created by a.ostroverkhov on 15/10/2018.
//  Copyright © 2018 a.ostroverkhov. All rights reserved.
//

import Foundation
import UIKit

enum  PickerDate: Int {
    case day = 0
    case hour = 1
    case minute = 2
}

class DatePickerDataSource: NSObject,  UIPickerViewDataSource, UIPickerViewDelegate {
    
    var viewModel = DatePickerViewModel(start: "08:00", end: "17:30")
    
    var days: [Day] = [Day]()
    var hours = [Hour]()
    var minutes = [Minute]()
    
    
    init(start: String, end: String) {
        viewModel = DatePickerViewModel(start: start, end: end)
        days = viewModel.createData()
        hours = days.first!.hours
        minutes = hours.first!.minutes
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return days.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    
        guard let count = PickerDate(rawValue: component) else {
            fatalError()
        }
    
        switch count {
        case .day:
            return days.count
        case .hour:
            return hours.count
        case .minute:
            return minutes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let count = PickerDate(rawValue: component) else {
            fatalError()
        }
        
        switch count {
        case .day:
            hours = days[row].hours
        case .hour:
            minutes = hours[row].minutes
        case .minute:
            break
        }
    }
    
}

