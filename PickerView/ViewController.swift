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
    var data = DatePickerDataSource(start: "09:01+03:00", end: "08:59+03:00")
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(Date())
        pickerView.dataSource = data
        pickerView.delegate = data
    }
}
