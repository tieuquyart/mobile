//
//  ChartCardView.swift
//  Acht
//
//  Created by forkon on 2019/10/14.
//  Copyright © 2019 Waylens. All rights reserved.
//

import UIKit

class ChartCardView: CardFlowViewCard {
    deinit {
        debugPrint("\(self) deinit")
    }

    required public init(
        statisticChartModel: DashboardStatisticChartModel?,
        chartType: ChartCardContentView.ChartType,
        showActiveVehiclesStatistic: Bool = true
        ) {
        let contentView = ChartCardContentView(chartType: chartType)
        super.init(contentView: contentView)
            
        let headerView = CustomChartCardHeaderView(
            segments: [CustomChartCardHeaderView.Segment.mileage, CustomChartCardHeaderView.Segment.duration, CustomChartCardHeaderView.Segment.event],
            frame: CGRect(x: 0.0, y: 0.0, width: bounds.width, height: 60.0)
        )
            
        headerView.selectHandler = { index in
            switch index {
            case 0:
                contentView.chartData = statisticChartModel?.mileageChartData
            case 1:
                contentView.chartData = statisticChartModel?.durationChartData
            case 2:
                contentView.chartData = statisticChartModel?.eventChartData
            default:
                return
            }
        }
            
            print("headerView.update")
         
            headerView.update(
                with: statisticChartModel?.mileageSum,
                duration: statisticChartModel?.durationSum,
                eventCount:  statisticChartModel?.eventSum
            )
            
         contentView.chartData = statisticChartModel?.mileageChartData

        self.headerView = headerView
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
