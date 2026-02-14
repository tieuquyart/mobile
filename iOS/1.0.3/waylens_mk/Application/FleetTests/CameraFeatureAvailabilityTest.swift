//
//  CameraFeatureAvailabilityTest.swift
//  FleetTests
//
//  Created by forkon on 2021/1/12.
//  Copyright © 2021 waylens. All rights reserved.
//

import XCTest
@testable import Fleet

class CameraFeatureAvailabilityTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let camera1 = UnifiedCamera(dict: ["serialNumber" : "2B17NKK5"])
        let camera2 = UnifiedCamera(dict: ["serialNumber" : "6B2AD5MF"])
        let camera3 = UnifiedCamera(dict: ["serialNumber" : "3A18BF1R"])

        XCTAssertTrue(camera1.featureAvailability.isViewModeAvailable)
        XCTAssertFalse(camera2.featureAvailability.isViewModeAvailable)
        XCTAssertFalse(camera3.featureAvailability.isViewModeAvailable)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
