//
//  ViewController.swift
//  PickerView
//
//  Created by a.ostroverkhov on 19.09.2018.
//  Copyright © 2018 a.ostroverkhov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var pickerView: UIPickerView!
    var start: DateComponents?
    var end: DateComponents?
    var curentTime: Date?
    let date = DatePickerViewModel(start: "08:00", end: "07:30")
    var days = [Day]()
    var hours = [Hour]()
    var minutes = [Minute]()
    //var data = PickerData.init(days: [], hours: [], minuts: [])
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        start = DateComponents(day: 1, hour: 8, minute: 30)
        end  = DateComponents(day: 1, hour: 23, minute: 0)
        
        days = date.createData()
    }
    
    
    private func test() {
        let timeZone = TimeZone.current
        let date = Date()
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents(in: timeZone, from: date)
        print(dateComponents)

    }
    
    private func test2() {
//        let date = DatePickerViewModel(start: "2018-10-08T08:00", end: "2018-10-08T20:00")
        //print(date.getArrays())
        
//        print(date.startTime)
//        print(date.startTime.timeIntervalSince(date.endTime))
//        print(date.startTime < date.endTime)
    }
}
extension ViewController:UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            hours = days[row].hours
            pickerView.reloadComponent(component + 1)
        case 1:
            minutes = hours[row].minutes
            pickerView.reloadComponent(component + 1)
        default:
            break
        }
        
    }
}

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return days.count
        case 1:
            return hours.count
        case 2:
            return minutes.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let dayF = DateFormatter()
        let hourF = DateFormatter()
        let minF = DateFormatter()
        dayF.dateFormat = "dd.MM"
        hourF.dateFormat = "HH"
        minF.dateFormat = "mm"
        
        switch component {
        case 0:
            return dayF.string(from: days[row].date)
        case 1:
            return hourF.string(from: hours[row].date)
        case 2:
            return minF.string(from: minutes[row].date)
        default:
            return ""
        }
    }
}

