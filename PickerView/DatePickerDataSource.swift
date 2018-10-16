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
    
    var viewModel: DatePickerViewModel
    
    var days = [Day]()
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
            pickerView.reloadComponent(PickerDate.hour.rawValue)
            minutes = hours[pickerView.selectedRow(inComponent: PickerDate.hour.rawValue)].minutes
            pickerView.reloadComponent(PickerDate.minute.rawValue)
        case .hour:
            minutes = hours[row].minutes
            pickerView.reloadComponent(PickerDate.minute.rawValue)
        case .minute:
            break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let component = PickerDate(rawValue: component) else {
            fatalError()
        }
        
        let dayF = DateFormatter()
        let hourF = DateFormatter()
        let minF = DateFormatter()
        dayF.dateFormat = "dd.MM"
        hourF.dateFormat = "HH"
        minF.dateFormat = "mm"
        
        switch component {
        case .day:
            return dayF.string(from: days[row].date)
        case .hour:
            return hourF.string(from: hours[row].date)
        case .minute:
            return minF.string(from: minutes[row].date)
        }
    }
}

