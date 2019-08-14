//
//  AppDelegate.swift
//  PickerView
//
//  Created by a.ostroverkhov on 19.09.2018.
//  Copyright © 2018 a.ostroverkhov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        let weekManager = DatePickerViewModel(
//            week: [
//                WeekDayWorkTime(start: "09:00+03:00", end: "18:00+03:00"),
//                WeekDayWorkTime(start: "09:00+03:00", end: "18:00+03:00"),
//                WeekDayWorkTime(start: "09:18+03:00", end: "18:00+03:00"),
//                WeekDayWorkTime(start: "09:00+03:00", end: "18:00+03:00"),
//                WeekDayWorkTime(start: "09:00+03:00", end: "18:00+03:00"),
//                WeekDayWorkTime(start: "09:00+03:00", end: "18:00+03:00"),
//                WeekDayWorkTime(start: "09:00+03:00", end: "18:00+03:00"),
//            ])
//
//        weekManager.getDayModels()
//        let days = weekManager.getDays()
//        let hours = weekManager.getHours(for:days[0])
//        print(hours)
//        print(weekManager.getMinutes(for: hours[0].intervals))
//        print(weekManager.getMinutes(for: hours[1].intervals))
        return true
    }
}

