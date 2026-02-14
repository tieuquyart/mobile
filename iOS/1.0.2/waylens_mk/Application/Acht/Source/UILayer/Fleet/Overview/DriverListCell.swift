//
//  DriverListCell.swift
//  Acht
//
//  Created by forkon on 2019/9/25.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class DriverListCell: UITableViewCell {
    
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var plateLabel: UILabel!
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var itemsContainingView: UIView!
    @IBOutlet weak var itemsContainingViewWidthConstraint: NSLayoutConstraint!
    private var satisticsSegmentedControl: StatisticsSegmentedControl?
    @IBOutlet weak var contanerViewSpeed: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var evenCountLbl: UILabel!
    @IBOutlet weak var statusCameraLabel: UILabel!
    @IBOutlet weak var kilometerLabel: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var mileageLabel: UILabel!
    weak var driver: Driver? = nil {
        didSet {
            refresh()
        }
    }
    func configLabel(values : [UILabel]) {
        values.forEach { lbl in
            lbl.textColor = UIColor.color(fromHex: ConstantMK.grayLabel)
        }
    }
    func configsimStateLabel() {
        if driver?.statistics.simState == "ACTIVATED" {
            self.statusCameraLabel.textColor = UIColor.color(fromHex: ConstantMK.greenLabel)
        } else {
            self.statusCameraLabel.textColor = UIColor.color(fromHex: ConstantMK.grayLabel)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        customInit()
    }
    private func customInit() {
        configLabel(values: [timeLabel,evenCountLbl,mileageLabel])
        viewContainer.layer.cornerRadius = 12
        viewContainer.layer.borderWidth = 0.5
        viewContainer.layer.borderColor = UIColor.color(fromHex: ConstantMK.grayLabel).cgColor
        viewContainer.layer.masksToBounds = true
        contanerViewSpeed.layer.cornerRadius = 10
        viewContainer.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cleanUp()
    }
    override func updateConstraints() {
        super.updateConstraints()
        //  itemsContainingViewWidthConstraint.constant = frame.width * 0.5
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
private extension DriverListCell {
    func cleanUp() {
        driverLabel.text = ""
        plateLabel.text = ""
        stateImageView.image = nil
    }
    func refresh() {
        guard let driver = driver else { return }
        driverLabel.text = driver.name
        plateLabel.text = driver.vehicle.plateNumber.isEmpty ? NSLocalizedString("Unknown", comment: "Unknown") : driver.vehicle.plateNumber
        stateImageView.image = FleetResource.Image.icon15x15(for: driver.vehicle.state)
        timeLabel.text = driver.statistics.duration.localeStringValue + " h"
        evenCountLbl.text = driver.statistics.mileage.localeStringValue
        mileageLabel.text = "\(driver.statistics.eventCount)"
//        if (driver.statistics.gpsData != nil) {
//            contanerViewSpeed.isHidden = false
//            let formatter = NumberFormatter()
//            formatter.maximumIntegerDigits = 2;
//            kilometerLabel.text = "\(roundDouble(val: driver.statistics.speed) ?? "0.0") km/h"
//        } else {
//            contanerViewSpeed.isHidden = true
//        }
        let formatter = NumberFormatter()
        formatter.maximumIntegerDigits = 2
        kilometerLabel.text = "\(roundDouble(val: driver.statistics.speed) ?? "0.0") km/h"
        switch driver.vehicle.state {
        case .driving:
            contanerViewSpeed.backgroundColor = UIColor.color(fromHex: "#E9F7FF")
            kilometerLabel.textColor = UIColor.color(fromHex: "#165FCE")
        case .parking:
            contanerViewSpeed.backgroundColor = UIColor.color(fromHex: "#E6F9EF")
            kilometerLabel.textColor = UIColor.color(fromHex: "#36A410")
        case .offline:
            contanerViewSpeed.backgroundColor = UIColor.color(fromHex: "#F3F6F8")
            kilometerLabel.textColor = UIColor.color(fromHex: "#9AA7B6")
        }
        statusCameraLabel.text = driver.statistics.simState
        configsimStateLabel()
    }
    func roundDouble(val: Double) -> String?{
        let format = NumberFormatter()
        format.numberStyle = .decimal
        format.maximumFractionDigits = 2
        let rounded = format.string(from: val as NSNumber)
        return rounded
    }
    class func elementStyleMaker(_ element: TextStackViewElement) -> TextStackViewElementStyle {
        let textColor: UIColor
        switch element {
        case .events, .hours, .mileage:
            textColor = UIColor.semanticColor(.label(.primary))
        default:
            textColor = UIColor.semanticColor(.label(.secondary))
        }
        let font: UIFont
        switch element {
        case .events, .hours, .mileage:
            font = UIFont(name: "BeVietnamPro-Regular", size: 12)!
        default:
            font = UIFont.systemFont(ofSize: 18)
        }
        return TextStackViewElementStyle(textColor: textColor, font: font)
    }
}
extension DriverListCell: Themed {
    func applyTheme() {
        refresh()
    }
}
