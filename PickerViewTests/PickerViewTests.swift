//
//  PickerViewTests.swift
//  PickerViewTests
//
//  Created by Alexey Ostroverkhov on 13/01/2020.
//  Copyright © 2020 a.ostroverkhov. All rights reserved.
//

import XCTest

class PickerViewTests: XCTestCase {

    let formatString = "yyyy/MM/dd HH:mm"
    let formatter = DateFormatter()
    
    
    override func setUp() {
        formatter.dateFormat = formatString
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    //workTime(for date: Date, with time: Date, start: Date, end: Date)
    func testWorkTimeWithTime() {
        let (viewModel, startWorkTimeString, endWorkTimeString, currentTimeString) = dataForTest1()
        
        let startDate = formatter.date(from: startWorkTimeString)!
        let endDate = formatter.date(from: endWorkTimeString)!
        let currentDate = formatter.date(from: currentTimeString)!
        
        let testInterval = viewModel.workTime(for: currentDate, with: currentDate, start: startDate, end: endDate)
        let expectedInterval = [DateInterval(start: startDate, end: endDate)]

        print(testInterval)
        print(expectedInterval)
        XCTAssert(testInterval == expectedInterval)
    }
    
    //workTime(for date: Date, start: Date, end: Date)
    func testWorkTime() {
        let (viewModel, startWorkTimeString, endWorkTimeString, currentTimeString) = dataForTest1()
        
        let startDate = formatter.date(from: startWorkTimeString)!
        let endDate = formatter.date(from: endWorkTimeString)!
        let currentDate = formatter.date(from: currentTimeString)!
        
        let testInterval = viewModel.workTime(for: currentDate, start: startDate, end: endDate)
        let expectedInterval = [DateInterval(start: startDate, end: endDate)]
        
        XCTAssert(testInterval == expectedInterval)

    }
    
    //test getDayModels
    func testDayModels() {

        let (viewModel, startWorkTimeString, endWorkTimeString, _) = dataForTest1()

        let dateIntervals = [[DateInterval(start: formatter.date(from: startWorkTimeString)!, end: formatter.date(from: endWorkTimeString)!)]]
        let testDateIntervas = viewModel.getDayModels()
        XCTAssert(dateIntervals == testDateIntervas)
    }
    
    func testDays() {
        let (viewModel, startWorkTimeString, endWorkTimeString, _) = dataForTest1()
        print("days", viewModel.getDays())
    }

    
    //MARK: - create data for tests
    
    private func dataForTest1() -> (DatePickerViewModel, String, String, String) {
        let startWorkTimeString = "2020/10/10 12:00"
        let endWorkTimeString = "2020/10/10 23:59"
        let currentTimeString = "2020/10/10 10:15"
        
        let week = [
            WeekDayWorkTime(start: startWorkTimeString, end: endWorkTimeString, dayNumber: 0, format: formatString),
            WeekDayWorkTime(start: startWorkTimeString, end: endWorkTimeString, dayNumber: 1, format: formatString),
            WeekDayWorkTime(start: startWorkTimeString, end: endWorkTimeString, dayNumber: 2, format: formatString),
            WeekDayWorkTime(start: startWorkTimeString, end: endWorkTimeString, dayNumber: 3, format: formatString),
            WeekDayWorkTime(start: startWorkTimeString, end: endWorkTimeString, dayNumber: 4, format: formatString),
            WeekDayWorkTime(start: startWorkTimeString, end: endWorkTimeString, dayNumber: 5, format: formatString),
            WeekDayWorkTime(start: startWorkTimeString, end: endWorkTimeString, dayNumber: 6, format: formatString)
        ]
        
        let currentDate = formatter.date(from: currentTimeString)!
        
        let viewModel = DatePickerViewModel(
            week: week,
            current: currentDate,
            countDays: 3,
            step: DateComponents(minute: 15),
            deliveryTime: DateComponents(hour: 0, minute: 0)
        )
        
        return (viewModel, startWorkTimeString, endWorkTimeString, currentTimeString)
    }
    
}
