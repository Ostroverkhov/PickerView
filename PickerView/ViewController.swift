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
    var data = DatePickerDataSource()
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = data
        pickerView.delegate = data
    }
}
