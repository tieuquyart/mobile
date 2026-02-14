//
//  FirmwareVersionCompareTest.swift
//  FleetTests
//
//  Created by forkon on 2020/8/5.
//  Copyright © 2020 waylens. All rights reserved.
//

import XCTest
@testable import Fleet

class FirmwareVersionCompareTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        XCTAssert("1.9.01".isNewerOrSameVersion(to: "1.9.1") == true)
        XCTAssert("1.14.0".isNewerOrSameVersion(to: "1.2.0") == true)
        XCTAssert("1.2.0".isNewerOrSameVersion(to: "1.2") == true)
        XCTAssert("1.2.7".isNewerOrSameVersion(to: "1.2.06") == true)
        XCTAssert("1.2.7".isNewerOrSameVersion(to: "0.2.6") == true)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
