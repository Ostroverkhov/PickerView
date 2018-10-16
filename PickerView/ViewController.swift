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
    var x = DatePickerDataSource(start: "08:00", end: "17:00")
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = x
        pickerView.delegate = x
        print(Locale(identifier: "ru_RU"))
    }
}
