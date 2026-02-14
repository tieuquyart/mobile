//
//  ViewContainTableViewAndBottomButtonTest.swift
//  FleetTests
//
//  Created by forkon on 2020/7/2.
//  Copyright © 2020 waylens. All rights reserved.
//

import XCTest
@testable import Fleet

class ViewContainTableViewAndBottomButtonTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let testView = ViewContainTableViewAndBottomButton()
        testView.frame = CGRect(x: 0.0, y: 0.0, width: 400.0, height: 800.0)
        testView.layoutMargins = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)

        XCTAssertTrue(testView.tableView.frame == testView.bounds)

        let btn1 = ButtonFactory.makeBigBottomButton("Test1", color: .red)

        testView.tableView.contentSize = CGSize(width: 400.0, height: 750.0)

        testView.addBottomItemView(btn1, height: 50.0)
        testView.layoutIfNeeded()
        XCTAssertEqual(testView.tableView.frame.height, 710.0)

        testView.tableView.contentSize = CGSize(width: 400.0, height: 500.0)
        testView.setNeedsLayout()
        testView.layoutIfNeeded()
        XCTAssertEqual(testView.tableView.frame.height, 500.0)

        let btn2 = ButtonFactory.makeBigBottomButton("Test2", color: .red)

        testView.addBottomItemView(btn2, height: 50.0)
        testView.layoutIfNeeded()
        XCTAssertEqual(btn2.frame.minY, 704.0)

        testView.removeAllBottomItemViews()

//        XCTAssertEqual((testView.value(forKey: "itemViews") as? [UIView]).isEmpty, true)

        let btn3 = ButtonFactory.makeBigBottomButton("Test3", color: .red)
        testView.addBottomItemView(btn3, height: 200.0)
        testView.layoutIfNeeded()
        XCTAssertEqual(btn3.frame.minY, 580.0)
        XCTAssertEqual(testView.tableView.frame.height, 560.0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
