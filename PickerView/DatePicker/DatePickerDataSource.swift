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
    
//    private var viewModel = DatePickerDayModel()
    private var viewModel = WeekManager(
            week: [
                WeekDayWorkTime(start: "00:00+03:00", end: "23:59+03:00"),
                WeekDayWorkTime(start: "00:00+03:00", end: "00:00+03:00"),
                WeekDayWorkTime(start: "09:30+03:00", end: "08:00+03:00"),
                WeekDayWorkTime(start: "09:00+03:00", end: "18:00+03:00"),
                WeekDayWorkTime(start: "12:00+03:00", end: "13:00+03:00"),
                WeekDayWorkTime(start: "09:00+03:00", end: "00:00+03:00"),
                WeekDayWorkTime(start: "09:00+03:00", end: "18:00+03:00"),
            ])
    private var days = [Day]()
    private var daysString = [String]()
    private var hours = [Hour]()
    private var minutes = [Minute]()
    
    override init() {
        super.init()
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
            let h = days.first?.hours,
            let m = h.first?.minutes,
            let t = m.first?.date
            else {
                fatalError()
        }
        
        hours = h
        minutes = m
        timeDelivery = t
    }
    
    convenience init(start: String, end: String) {
        self.init()
//        viewModel = DatePickerDayModel(start: start, end: end)
        days = viewModel.createData()
        
        daysString = createDateString(days)
        
        setParams(days)
    }
    
    
    convenience init(startDate: Date, endDate: Date) {
        self.init()
//        viewModel = DatePickerDayModel(start: startDate, end: endDate, step: DateComponents(minute: 5))
        days = viewModel.createData()
        daysString = createDateString(days)
        setParams(days)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
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
            
            timeDelivery = minutes[pickerView.selectedRow(inComponent: PickerDate.minute.rawValue)].date
            
        case .hour:
            minutes = hours[row].minutes
            pickerView.reloadComponent(PickerDate.minute.rawValue)
            timeDelivery = minutes[pickerView.selectedRow(inComponent: PickerDate.minute.rawValue)].date
            
        case .minute:
            timeDelivery = minutes[row].date
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let component = PickerDate(rawValue: component) else {
            fatalError()
        }
        
        let hourF = DateFormatter()
        let minF = DateFormatter()
        hourF.dateFormat = "HH"
        minF.dateFormat = "mm"
        
        switch component {
        case .day:
            return daysString[row]
        case .hour:
            return hourF.string(from: hours[row].date)
        case .minute:
            return minF.string(from: minutes[row].date)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch (component) {
        case 0:
            return pickerView.bounds.size.width / 3.0
        default:
            return 80.0;
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        guard let component = PickerDate(rawValue: component) else {
            fatalError()
        }
        let dic = [
            NSAttributedString.Key.foregroundColor: UIColor(white: 0.4, alpha: 1),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
        ]
        
        let hourF = DateFormatter()
        let minF = DateFormatter()
        hourF.dateFormat = "HH"
        minF.dateFormat = "mm"
        
        var s: String
        switch component {
        case .day:
            s =  daysString[row]
        case .hour:
            s = hourF.string(from: hours[row].date)
        case .minute:
            s = minF.string(from: minutes[row].date)
        }
        
        return  NSAttributedString(string: s, attributes: dic)
    }
}



