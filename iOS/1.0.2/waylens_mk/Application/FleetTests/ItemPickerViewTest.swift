//
//  ItemPickerViewTest.swift
//  FleetTests
//
//  Created by forkon on 2020/6/12.
//  Copyright © 2020 waylens. All rights reserved.
//

import XCTest
@testable import Fleet

class ItemPickerViewTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /*
    func testStreamPickerViewLayout() throws {
        let itemPickerView = ItemPickerView<String>(frame: CGRect.zero, layout: StreamPickerViewLayout(), items: ["aaaaaa", "bbbbbbbbbbbbbbbbbbbbbb"]) { (selectedItem) in

        }

        XCTAssertEqual(itemPickerView.itemViews.count, 2)

        itemPickerView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 1000.0, height: 200.0))
        itemPickerView.setNeedsLayout()
        itemPickerView.layoutIfNeeded()
        XCTAssertTrue(itemPickerView.frame != CGRect.zero)

        XCTAssertEqual(itemPickerView.scrollView.bounds.width, 1000.0 - 16.0 * 2)
        XCTAssertTrue(itemPickerView.itemViews.first?.frame.origin.x == 0.0)

        XCTAssertTrue(itemPickerView.itemViews.last?.frame.origin.x != 0.0)

        itemPickerView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 100.0, height: 100.0))
        itemPickerView.setNeedsLayout()
        itemPickerView.layoutIfNeeded()

        XCTAssertTrue(itemPickerView.itemViews.first?.frame.origin.x == 0.0)
        XCTAssertTrue(itemPickerView.itemViews.last?.frame.origin.x == 0.0)

        let itemPickerView2 = ItemPickerView<String>(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100.0, height: 100.0)), layout: StreamPickerViewLayout(), items: ["bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"]) { (selectedItem) in

        }
        itemPickerView2.setNeedsLayout()
        itemPickerView2.layoutIfNeeded()

        XCTAssertEqual(itemPickerView2.itemViews.first?.frame.width, itemPickerView2.scrollView.frame.width)
    }
    */

}
