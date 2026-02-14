//
//  BarChartCardData.swift
//  Fleet
//
//  Created by forkon on 2019/10/17.
//  Copyright © 2019 waylens. All rights reserved.
//

import Charts

struct ChartDataItem {
    var date: Date
    var value: Any
}

class ChartData {
    private(set) var items: [ChartDataItem]
    var referenceTimeInterval: TimeInterval {
        return (items.map { $0.date.timeIntervalSince1970 }).min() ?? 0
    }

    var barChartDataSetEntries: [BarChartDataEntry] {
        let yVals = items.map { (item) -> BarChartDataEntry in
            var value: Double = 0.0
            if let itemValue = item.value as? Measurement<UnitLength> {
                
                value = itemValue.localeValue / 1000
            
            }
            else if let itemValue = item.value as? Measurement<UnitDuration> {
                value = itemValue.localeValue
            }
            else if let itemValue = item.value as? Double {
                value = itemValue
            }

            let xVal = (item.date.timeIntervalSince1970 - referenceTimeInterval) / (3600 * 24)

            if value < 0.1 {
                value = 0.0
            }

            return BarChartDataEntry(x: xVal, y: value, data: item)
        }

        return yVals
    }

    var lineChartDataSetEntries: [ChartDataEntry] {
        let yVals = items.map { (item) -> ChartDataEntry in
            var value: Double = 0.0
            if let itemValue = item.value as? Measurement<UnitLength> {
                value = itemValue.localeValue / 1000
            }
            else if let itemValue = item.value as? Measurement<UnitDuration> {
                value = itemValue.localeValue
            }
            else if let itemValue = item.value as? Double {
                value = itemValue
            }

            let xVal = (item.date.timeIntervalSince1970 - referenceTimeInterval) / (3600 * 24)

            if value < 0.1 {
                value = 0.0
            }

            return ChartDataEntry(x: Double(xVal), y: value, data: item)
        }

        return yVals
    }

    init(items: [ChartDataItem]) {
        self.items = items
    }

}

//extension ChartData {
//
//    class var demoDatas: [ChartData] {
//        return [
//            ChartData(items:
//                [
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1570867677), value: 10.5),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1570954077), value: 7.0),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571040477), value: 5.5),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571126877), value: 1.0),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571213277), value: 3.0),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571299677), value: 21.5)
//                ]
//            ),
//            ChartData(items:
//                [
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1570867677), value: 21),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1570954077), value: 50),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571040477), value: 39),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571126877), value: 98),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571213277), value: 3),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571299677), value: 77)
//                ]
//            ),
//            ChartData(items:
//                [
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1570867677), value: 0.1),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1570954077), value: 0.3),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571040477), value: 0.39),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571126877), value: 0.98),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571213277), value: 0.3),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571299677), value: 0.77)
//                ]
//            ),
//            ChartData(items:
//                [
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1570781277), value: 80),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1570867677), value: 21),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1570954077), value: 150),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571040477), value: 39),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571126877), value: 200),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571213277), value: 3),
//                    ChartDataItem(date: Date(timeIntervalSince1970: 1571299677), value: 77)
//                ]
//            )
//        ]
//    }
//
//}

extension Double {
    fileprivate struct AssociatedKeys {
        static var referenceTimeInterval: UInt8 = 8
    }

    public var referenceTimeInterval: TimeInterval? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.referenceTimeInterval, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.referenceTimeInterval) as? TimeInterval
        }
    }
}
