//
//  UIImageTest.swift
//  FleetTests
//
//  Created by forkon on 2020/7/1.
//  Copyright © 2020 waylens. All rights reserved.
//

import XCTest
@testable import Fleet

class UIImageTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testImageWithNewSize() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let image = UIImage(named: "handle")
        XCTAssertTrue(image?.size == CGSize(width: 40.0, height: 5.0))

        let newImage = image?.image(with: CGSize(width: 40.0, height: 40.0))
        XCTAssertTrue(newImage?.size == CGSize(width: 40.0, height: 40.0))

        XCTAssertTrue(image?.scale == newImage?.scale)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
