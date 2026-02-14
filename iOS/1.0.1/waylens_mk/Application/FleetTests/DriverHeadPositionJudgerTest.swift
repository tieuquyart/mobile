//
//  DriverHeadPositionJudgerTest.swift
//  FleetTests
//
//  Created by forkon on 2020/8/18.
//  Copyright © 2020 waylens. All rights reserved.
//

import XCTest
@testable import Fleet

class DriverHeadPositionJudgerTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let headCGRect1 = CGRect.zero
        let pictureSize1 = CGSize(width: 2000.0, height: 1000.0)

        let judger = DriverHeadPositionJudgerImpl()
        let result1 = judger.judge(headRect: headCGRect1, pictureSize: pictureSize1)
        XCTAssertFalse(result1)

        let headCGRect2 = CGRect(x: 300.0, y: 10.0, width: 10.0, height: 10.0)
        let result2 = judger.judge(headRect: headCGRect2, pictureSize: pictureSize1)
        XCTAssertFalse(result2)

        let headCGRect3 = CGRect(x: 900.0, y: 100.0, width: 10.0, height: 10.0)
        let result3 = judger.judge(headRect: headCGRect3, pictureSize: pictureSize1)
        XCTAssertFalse(result3)

        let headCGRect4 = CGRect(x: 800.0, y: 100.0, width: 400.0, height: 300.0)
        let result4 = judger.judge(headRect: headCGRect4, pictureSize: pictureSize1)
        XCTAssertTrue(result4)

        let headCGRect5 = CGRect(x: 800.0, y: 100.0, width: 400.0, height: 600.0)
        let result5 = judger.judge(headRect: headCGRect5, pictureSize: pictureSize1)
        XCTAssertFalse(result5)

        let headCGRect6 = CGRect(x: 799, y: 100.0, width: 400.0, height: 600.0)
        let result6 = judger.judge(headRect: headCGRect6, pictureSize: pictureSize1)
        XCTAssertFalse(result6)

        let headCGRect7 = CGRect(x: 1000, y: 100.0, width: 400.0, height: 300.0)
        let result7 = judger.judge(headRect: headCGRect7, pictureSize: pictureSize1)
        XCTAssertTrue(result7)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

private class DriverHeadPositionJudgerImpl: DriverHeadPositionJudger {}
