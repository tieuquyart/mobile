//
//  HNVideoResolutionTest.swift
//  FleetTests
//
//  Created by forkon on 2020/6/12.
//  Copyright © 2020 waylens. All rights reserved.
//

import XCTest
@testable import Fleet

class HNVideoResolutionTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParseForArray() throws {
        let resolutions1 = HNVideoResolution.parse(["s", "d"])
        XCTAssertTrue(resolutions1.count == 2)
        XCTAssertEqual(resolutions1, [.hd, .sd])

        let resolutions2 = HNVideoResolution.parse(["DMS--", "STREAMING---", "FRONT_HD--"])
        XCTAssertEqual(resolutions2, [.dms, .spliced, .frontHD])

        let resolutions3 = HNVideoResolution.parse(["SD", "INCABIN_HD"])
        XCTAssertEqual(resolutions3, [.spliced, .incabinHD])

        let resolutions4 = HNVideoResolution.parse(["a", "b", "c", "d"])
        XCTAssertEqual(resolutions4, [.stream0, .stream1, .stream2, .stream3])

        let resolutions5 = HNVideoResolution.parse(["a", "b", "c"])
        XCTAssertEqual(resolutions5, [.stream0, .stream1, .stream2])

        XCTAssertEqual(HNVideoResolution.dms.description, NSLocalizedString("Driver", comment: "Driver"))
        XCTAssertEqual(HNVideoResolution.spliced.description, NSLocalizedString("Combined", comment: "Combined"))
        XCTAssertEqual(HNVideoResolution.frontHD.description, NSLocalizedString("Road", comment: "Road"))
        XCTAssertEqual(HNVideoResolution.unknown.description, NSLocalizedString("Unknown", comment: "Unknown"))
    }

}
