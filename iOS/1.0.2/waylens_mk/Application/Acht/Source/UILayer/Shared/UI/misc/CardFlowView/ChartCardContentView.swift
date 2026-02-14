//
//  ChartCardContentView.swift
//  Acht
//
//  Created by forkon on 2019/10/14.
//  Copyright © 2019 Waylens. All rights reserved.
//

import UIKit
import Charts

var isChartCardFirstPresentation: Bool = true

class ChartCardContentView: UIView {
    private var barChartView: BarChartView? = nil
    private var lineChartView: LineChartView? = nil
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10.0)
        label.textColor = UIColor.semanticColor(.label(.primary))
        label.textAlignment = .center
        return label
    }()

    enum ChartConfig {
        static let labelFont = UIFont.systemFont(ofSize: 10.0)
        static let barWidth: CGFloat = 16
        static let animationDuration: Float = 0.5
        static let linesWidth: CGFloat = 0.1
    }

    enum ChartType {
        case bar
        case line
    }

    private var didLayout: Bool = false

    var chartData: ChartData? = nil {
        didSet {
            updateChartView()
        }
    }

    private(set) var chartType: ChartType

    init(chartType: ChartType) {
        self.chartType = chartType
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 200.0))

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

}

//MARK: - Private

private extension ChartCardContentView {

    func setup() {
        switch chartType {
        case .bar:
            setupBarChartView()
        case .line:
            setupLineChartView()
        }

        addSubview(dateLabel)

        applyTheme()

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0).isActive = true
    }

    func setupBarChartView() {
        let barChartView = BarChartView(frame: bounds)
        
        barChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        

        barChartView.chartDescription?.enabled = false

        barChartView.dragEnabled = true
        barChartView.setScaleEnabled(false)
        barChartView.pinchZoomEnabled = false

        barChartView.rightAxis.enabled = false

        barChartView.drawBarShadowEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.drawBordersEnabled = false
        barChartView.drawGridBackgroundEnabled = false

        barChartView.maxVisibleCount = 60

        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.gridColor = UIColor.clear
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.valueFormatter = DayAxisValueFormatter(chart: barChartView)

        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = ""
        leftAxisFormatter.positiveSuffix = ""

        let leftAxis = barChartView.leftAxis
        leftAxis.axisLineColor = UIColor.clear
        leftAxis.gridColor = UIColor.clear
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES

        let l = barChartView.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .none
        l.formSize = 9
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.xEntrySpace = 4

        let marker = XYMarkerView(color: UIColor.black.withAlphaComponent(0.8),
                                  font: .systemFont(ofSize: 12),
                                  textColor: .white,
                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                  xAxisValueFormatter: barChartView.xAxis.valueFormatter!)
        marker.chartView = barChartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        barChartView.marker = marker
        
        
        

        addSubview(barChartView)

        self.barChartView = barChartView
        
       
    }

    func setupLineChartView() {
        let lineChartView = LineChartView(frame: bounds)
        lineChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        lineChartView.chartDescription?.enabled = false
        lineChartView.dragEnabled = true
        lineChartView.setScaleEnabled(false)
        lineChartView.pinchZoomEnabled = false

        let xAxis = lineChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.gridColor = UIColor.clear
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.valueFormatter = DayAxisValueFormatter(chart: lineChartView)

        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = ""
        leftAxisFormatter.positiveSuffix = ""

        let leftAxis = lineChartView.leftAxis
        leftAxis.axisLineColor = UIColor.clear
        leftAxis.gridColor = UIColor.clear
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES

        lineChartView.rightAxis.enabled = false

        let l = lineChartView.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .none
        l.formSize = 9
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.xEntrySpace = 4

        let marker = XYMarkerView(color: UIColor.black.withAlphaComponent(0.8),
                                  font: .systemFont(ofSize: 12),
                                  textColor: .white,
                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                  xAxisValueFormatter: lineChartView.xAxis.valueFormatter!)
        marker.chartView = lineChartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        lineChartView.marker = marker

        lineChartView.legend.form = .line

        addSubview(lineChartView)

        self.lineChartView = lineChartView
    }

    func updateChartView() {
        switch chartType {
        case .bar:
            guard let barChartView = barChartView else {
                return
            }

            if let newEntries = chartData?.barChartDataSetEntries {
                var dataSet: BarChartDataSet!

                (barChartView.xAxis.valueFormatter as? DayAxisValueFormatter)?.referenceTimeInterval = chartData?.referenceTimeInterval

                updateDateLabel(with: newEntries.first, lastEntry: newEntries.last)

                if let set = barChartView.data?.dataSets.first as? BarChartDataSet {
                    dataSet = set
                    dataSet.replaceEntries(newEntries)
                    barChartView.data?.notifyDataChanged()
                    barChartView.notifyDataSetChanged()
                } else {
                    dataSet = BarChartDataSet(entries: newEntries, label: "")
                    dataSet.setColor(UIColor.semanticColor(.tint(.primary)).withAlphaComponent(0.5))
                    dataSet.highlightColor = UIColor.semanticColor(.tint(.primary))
                    dataSet.highlightAlpha = 1.0
                    dataSet.drawValuesEnabled = false
                    let data = BarChartData(dataSet: dataSet)
                    data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
                    data.barWidth = 0.8

                    barChartView.data = data
                }
            } else {
                barChartView.data = nil
            }

            if isChartCardFirstPresentation {
                barChartView.animate(xAxisDuration: 0.5, yAxisDuration: 1.5, easingOptionX: ChartEasingOption.linear, easingOptionY: ChartEasingOption.easeOutElastic)
                isChartCardFirstPresentation = false
            }
          
        case .line:
            guard let lineChartView = lineChartView else {
                return
            }

            if let newEntries = chartData?.lineChartDataSetEntries {
                var set1: LineChartDataSet!

                (lineChartView.xAxis.valueFormatter as? DayAxisValueFormatter)?.referenceTimeInterval = chartData?.referenceTimeInterval

                updateDateLabel(with: newEntries.first, lastEntry: newEntries.last)

                if let set = lineChartView.data?.dataSets.first as? LineChartDataSet {
                    set1 = set
                    set1.replaceEntries(newEntries)
                    lineChartView.data?.notifyDataChanged()
                    lineChartView.notifyDataSetChanged()
                } else {
                    set1 = LineChartDataSet(entries: newEntries, label: nil)
                    set1.drawValuesEnabled = false
                    set1.drawIconsEnabled = false

                    set1.fillAlpha = 1
                    set1.fill = Fill(color: UIColor.semanticColor(.tint(.primary)).withAlphaComponent(0.5))
                    set1.drawFilledEnabled = true

                    set1.drawHorizontalHighlightIndicatorEnabled = false
                    set1.highlightLineWidth = 1.0
                    set1.highlightLineDashLengths = [5, 0.0]
                    set1.highlightColor = UIColor.semanticColor(.tint(.primary))
                    set1.setColor(UIColor.semanticColor(.tint(.primary)).withAlphaComponent(0.5))
                    set1.setCircleColor(UIColor.semanticColor(.tint(.primary)))
                    set1.lineWidth = 1
                    set1.circleRadius = 5
                    set1.circleHoleColor = UIColor.white
                    set1.drawCircleHoleEnabled = true
                    set1.valueFont = .systemFont(ofSize: 9)
                    set1.form = .none
//                    set1.formLineDashLengths = [5, 2.5]
//                    set1.formLineWidth = 1
//                    set1.formSize = 15

                    let data = LineChartData(dataSet: set1)
                    lineChartView.data = data
                }
            } else {
                lineChartView.data = nil
            }

            lineChartView.setNeedsDisplay()
        }
    }

    func updateDateLabel(with firstEntry: ChartDataEntry?, lastEntry: ChartDataEntry?) {
        if let firstEntry = firstEntry, let referenceTimeInterval = chartData?.referenceTimeInterval {
            let startDate = Date(timeIntervalSince1970: firstEntry.x * (3600 * 24) + referenceTimeInterval)

            if let lastEntry = lastEntry {
                let endDate = Date(timeIntervalSince1970: lastEntry.x * (3600 * 24) + referenceTimeInterval)

                if !startDate.dateManager.fleetDate.compare(.isSameMonth(endDate)) {
                    dateLabel.text = "\(startDate.dateManager.fleetDate.toFormat("yyyy-M")) | \(endDate.dateManager.fleetDate.toFormat("yyyy-M"))"
                } else {
                    dateLabel.text = startDate.dateManager.fleetDate.toFormat("yyyy-M")
                }
            } else {
                dateLabel.text = startDate.dateManager.fleetDate.toFormat("yyyy-M")
            }
        } else {
            dateLabel.text = ""
        }
    }

}

extension ChartCardContentView: Themed {

    func applyTheme() {
        backgroundColor = UIColor.clear

        lineChartView?.leftAxis.labelTextColor = UIColor.semanticColor(.label(.secondary))
        lineChartView?.xAxis.labelTextColor = UIColor.semanticColor(.label(.secondary))
        barChartView?.leftAxis.labelTextColor = UIColor.semanticColor(.label(.secondary))
        barChartView?.xAxis.labelTextColor = UIColor.semanticColor(.label(.secondary))
    }

}

public class DayAxisValueFormatter: NSObject, IAxisValueFormatter {
    weak var chart: BarLineChartViewBase?
    var referenceTimeInterval: TimeInterval? = nil

    init(chart: BarLineChartViewBase) {
        self.chart = chart
    }

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dayOfMonth = Date(timeIntervalSince1970: value * (3600 * 24) + (referenceTimeInterval ?? 0)).dateManager.fleetDate.dateComponents.day ?? 0
        return dayOfMonth == 0 ? "" : String(format: "%d", dayOfMonth)
    }

}

public class XYMarkerView: BalloonMarker {
    public var xAxisValueFormatter: IAxisValueFormatter
    fileprivate var yFormatter: NumberFormatter = {
        let yFormatter = NumberFormatter()
        return yFormatter
    }()

    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets,
                xAxisValueFormatter: IAxisValueFormatter) {
        self.xAxisValueFormatter = xAxisValueFormatter
        yFormatter.minimumFractionDigits = 0
        yFormatter.maximumFractionDigits = 1
        super.init(color: color, font: font, textColor: textColor, insets: insets)
    }

    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        if let item = entry.data as? ChartDataItem {
            var valueString = ""

            if let itemValue = item.value as? Measurement<UnitLength> {
                valueString = itemValue.localeStringValueWithUnit
            }
            else if let itemValue = item.value as? Measurement<UnitDuration> {
                valueString = itemValue.localeStringValueWithUnit
            }
            else {
                valueString = yFormatter.string(from: NSNumber(floatLiteral: entry.y))!
            }

            let dateString = item.date.dateManager.fleetDate.toString(.date(.medium))
            let string = dateString + " | " + valueString
            setLabel(string)
        } else {
            let string = "x: "
                + xAxisValueFormatter.stringForValue(entry.x, axis: XAxis())
                + ", y: "
                + yFormatter.string(from: NSNumber(floatLiteral: entry.y))!
            setLabel(string)
        }
    }

}

open class BalloonMarker: MarkerImage
{
    open var color: UIColor
    open var arrowSize = CGSize(width: 15, height: 11)
    open var font: UIFont
    open var textColor: UIColor
    open var insets: UIEdgeInsets
    open var minimumSize = CGSize()

    fileprivate var label: String?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [NSAttributedString.Key : Any]()

    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets)
    {
        self.color = color
        self.font = font
        self.textColor = textColor
        self.insets = insets

        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
        super.init()
    }

    open override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint
    {
        var offset = self.offset
        var size = self.size

        if size.width == 0.0 && image != nil
        {
            size.width = image!.size.width
        }
        if size.height == 0.0 && image != nil
        {
            size.height = image!.size.height
        }

        let width = size.width
        let height = size.height
        let padding: CGFloat = 8.0

        var origin = point
        origin.x -= width / 2
        origin.y -= height

        if origin.x + offset.x < 0.0
        {
            offset.x = -origin.x + padding
        }
        else if let chart = chartView,
            origin.x + width + offset.x > chart.bounds.size.width
        {
            offset.x = chart.bounds.size.width - origin.x - width - padding
        }

        if origin.y + offset.y < 0
        {
            offset.y = height + padding;
        }
        else if let chart = chartView,
            origin.y + height + offset.y > chart.bounds.size.height
        {
            offset.y = chart.bounds.size.height - origin.y - height - padding
        }

        return offset
    }

    open override func draw(context: CGContext, point: CGPoint)
    {
        guard let label = label else { return }

        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size

        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height

        context.saveGState()

        context.setFillColor(color.cgColor)

        if offset.y > 0
        {
            context.beginPath()
            context.move(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                y: rect.origin.y + arrowSize.height))
            //arrow vertex
            context.addLine(to: CGPoint(
                x: point.x,
                y: point.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + rect.size.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + rect.size.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + arrowSize.height))
            context.fillPath()
        }
        else
        {
            context.beginPath()
            context.move(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            //arrow vertex
            context.addLine(to: CGPoint(
                x: point.x,
                y: point.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y))
            context.fillPath()
        }

        if offset.y > 0 {
            rect.origin.y += self.insets.top + arrowSize.height
        } else {
            rect.origin.y += self.insets.top
        }

        rect.size.height -= self.insets.top + self.insets.bottom

        UIGraphicsPushContext(context)

        label.draw(in: rect, withAttributes: _drawAttributes)

        UIGraphicsPopContext()

        context.restoreGState()
    }

    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        setLabel(String(entry.y))
    }

    open func setLabel(_ newLabel: String)
    {
        label = newLabel

        _drawAttributes.removeAll()
        _drawAttributes[.font] = self.font
        _drawAttributes[.paragraphStyle] = _paragraphStyle
        _drawAttributes[.foregroundColor] = self.textColor

        _labelSize = label?.size(withAttributes: _drawAttributes) ?? CGSize.zero

        var size = CGSize()
        size.width = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        self.size = size
    }
}
