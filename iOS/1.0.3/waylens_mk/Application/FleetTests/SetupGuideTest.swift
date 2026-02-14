//
//  SetupGuideTest.swift
//  FleetTests
//
//  Created by forkon on 2020/7/1.
//  Copyright © 2020 waylens. All rights reserved.
//

import XCTest
@testable import Fleet

class SetupGuideTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let setupGuide = SetupGuide(scene: .installerGuide, presenter: MockSetupGuidePresenter())

        setupGuide.start()
        XCTAssertTrue(setupGuide.currentStep == .connectCameraWifiAndDetectViewMode)

        setupGuide.nextStep()
        setupGuide.nextStep()
        XCTAssertTrue(setupGuide.currentStep == .checkCameraNetwork)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

class MockSetupGuidePresenter: SetupGuidePresenter {
    var setupGuide: SetupGuide?

    override func present(_ step: SetupStep, with params: [AnyHashable : Any]?) {

    }

    override func makeViewController(for step: SetupStep, with params: [AnyHashable : Any]?) -> UIViewController {
        return UIViewController()
    }

    override func dismiss() {

    }

}
