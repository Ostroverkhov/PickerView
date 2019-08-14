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

@objcMembers class DatePickerDataSource: NSObject,  UIPickerViewDataSource, UIPickerViewDelegate {
    
    var timeDelivery: Date = Date()
    
    private var viewModel: DatePickerViewModel
    private var days = [Day]()
    private var daysString = [String]()
    private var hours = [Minute]()
    
    override init() {
        viewModel = DatePickerViewModel(
            week: [
                WeekDayWorkTime(start: "00:00+03:00", end: "23:59+03:00"),
                WeekDayWorkTime(start: "00:00+03:00", end: "00:00+03:00"),
                WeekDayWorkTime(start: "09:30+03:00", end: "08:00+03:00"),
                WeekDayWorkTime(start: "09:00+03:00", end: "18:00+03:00"),
                WeekDayWorkTime(start: "12:00+03:00", end: "13:00+03:00"),
                WeekDayWorkTime(start: "09:00+03:00", end: "00:00+03:00"),
                WeekDayWorkTime(start: "09:00+03:00", end: "05:00+03:00"),
            ])
        super.init()
        
        days = viewModel.createData()
        daysString = createDateString(days)
        setParams(days)
        
    }
    
    private func createDateString(_ days: [Day]) -> [String] {
        return days.map{(day: Day) -> String in
            if Calendar.current.isDateInToday(day.date) {
                return "Сегодня"
            } else if Calendar.current.isDateInTomorrow(day.date) {
                return "Завтра"
            }
            let dayF = DateFormatter()
            dayF.dateFormat = "d MMM"
            return dayF.string(from: day.date)
        }
    }
    
    private func setParams(_ days: [Day]) {
        guard
            let h = days.first?.minutes,
            let t = h.first?.date
            else {
                fatalError()
        }
        
        hours = h
        timeDelivery = t
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
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
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let count = PickerDate(rawValue: component) else {
            fatalError()
        }
        
        switch count {
        case .day:
            hours = days[row].minutes
            pickerView.reloadComponent(PickerDate.hour.rawValue)
            timeDelivery = hours[pickerView.selectedRow(inComponent: PickerDate.hour.rawValue)].date
            
        case .hour:
            timeDelivery = hours[row].date
            
        case .minute:
            break
        }
        print(timeDelivery)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let component = PickerDate(rawValue: component) else {
            fatalError()
        }
        
        let hourF = DateFormatter()
        hourF.dateFormat = "HH:mm"
        
        switch component {
        case .day:
            return daysString[row]
        case .hour:
            return hourF.string(from: hours[row].date)
        default:
            return ""
        }
    }
}



