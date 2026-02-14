//
//  DashboardStatisticChartModel.swift
//  Fleet
//
//  Created by forkon on 2019/10/21.
//  Copyright © 2019 waylens. All rights reserved.
//




protocol DashboardStatisticChartModelProperty {
    
}

public class DashboardStatisticChartModel {
    
    struct ItemHour {
        let summaryTime: String
        let hoursTotal: Double
    }
    
    struct ItemEvent {
        let summaryTime: String
        let eventTotal: Int
    }
    
    struct ItemDistance {
        let summaryTime: String
        let distanceTotal: Int
    }
    
    private(set) var statistics_Miles: [ItemDistance] = []
    private(set) var statistics_hours: [ItemHour] = []
    private(set) var statistics_event: [ItemEvent] = []
    
    
    
    public var mileageSum: Measurement<UnitLength>? = nil
    public var durationSum: Measurement<UnitDuration>? = nil
    public var eventSum: Int? = nil
    
    
    
    init(_ dict : JSON) {
        
        if let hoursTotal = dict["hoursTotal"] as? Double {
            self.durationSum = hoursTotal.measurementDuration(unit: .hours)
        }
        
        if let milesTotal = dict["milesTotal"] as? Double {
            self.mileageSum = milesTotal.measurementLength(unit: .kilometers)
        }
        
        if let eventTotal = dict["eventTotal"] as? Int {
            self.eventSum =  eventTotal
        }
        
        if let milesList = dict["milesList"] as? [JSON] {
            milesList.forEach { statisticDict in
                let distanceTotal = (statisticDict["distanceTotal"] as? Int) ?? 0
                let summaryTime = (statisticDict["summaryTime"] as? String) ?? "2022-08-26"
                let item = ItemDistance(summaryTime: summaryTime, distanceTotal: distanceTotal)
                statistics_Miles.append(item)
            }
            print(" statistics_Mile.count", statistics_Miles.count)
        }
        
        
        if let hoursList = dict["hoursList"] as? [JSON] {
            hoursList.forEach { statisticDict in
                let summaryTime = (statisticDict["summaryTime"] as? String) ?? ""
                let hoursTotal = (statisticDict["hoursTotal"] as? Double) ?? 0
                let item = ItemHour(summaryTime: summaryTime, hoursTotal: hoursTotal)
                statistics_hours.append(item)
            }
            
            print("statistics_hours", statistics_hours.count)
        }
        
        
        
        if let eventsList = dict["eventsList"] as? [JSON] {
            eventsList.forEach { statisticDict in
                let eventTotal = (statisticDict["eventTotal"] as? Int) ?? 0
                let summaryTime = (statisticDict["summaryTime"] as? String) ?? ""
                let item = ItemEvent(summaryTime: summaryTime, eventTotal: eventTotal)
                statistics_event.append(item)
            }
            
            print("statistics_event", statistics_event.count)
        }
        
        
        
    }
    
    
}


 

extension DashboardStatisticChartModel {
    
    var mileageChartData: ChartData {
        
        let extractedExpr = ChartData (items:
                                        statistics_Miles.map {
            ChartDataItem(date: $0.summaryTime.toDate()!.date , value: $0.distanceTotal.measurementLength(unit: .kilometers))
        }
                                       
        )
        
        
        return extractedExpr
    }
    
    var durationChartData: ChartData {
        
        let extractedExpr = ChartData(items:
                                        statistics_hours.map {
            
            ChartDataItem(date: $0.summaryTime.toDate()!.date, value: $0.hoursTotal.measurementDuration(unit: .hours))
            
        }
        )
        
        return extractedExpr
        
    }
    
    var eventChartData: ChartData {
        let extractedExpr = ChartData(items:
                                        statistics_event.map {
            ChartDataItem(date: $0.summaryTime.toDate()!.date, value: Double($0.eventTotal))
            
        }
        )
        
        return extractedExpr
    }
    
}


