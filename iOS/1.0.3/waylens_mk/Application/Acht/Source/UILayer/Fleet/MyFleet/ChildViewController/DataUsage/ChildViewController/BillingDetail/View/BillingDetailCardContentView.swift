//
//  BillingDetailCardContentView.swift
//  Fleet
//
//  Created by forkon on 2019/11/20.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import AloeStackView

class BillingDetailCardContentView: CardFlowViewCardContentView<CardFlowViewCardEventHandler<BillingDataItem>> {

    private enum Config {
        static let rowHeight: CGFloat = 70.0
    }

    private let itemsStackView: AloeStackView = {
        let itemsStackView = AloeStackView()
        itemsStackView.backgroundColor = UIColor.clear
        itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        itemsStackView.rowInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        itemsStackView.separatorInset = UIEdgeInsets.zero
        itemsStackView.automaticallyHidesLastSeparator = true
        return itemsStackView
    }()

    public var items: [BillingDataItem] = [] {
        didSet {
            updateUI()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Private

private extension BillingDetailCardContentView {

    func setup() {
        addSubview(itemsStackView)

        itemsStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        itemsStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        itemsStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        itemsStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    func updateUI() {
        itemsStackView.removeAllRows()

        items.forEach { (item) in
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: nil)
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.textColor = UIColor.semanticColor(.label(.secondary))
            cell.textLabel?.usingDynamicTextColor = true
            cell.textLabel?.font = UIFont(name: "BeVietnamPro-Medium", size: 14)!
            cell.detailTextLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!

            cell.imageView?.image = #imageLiteral(resourceName: "camera_4g")
            cell.textLabel?.text = item.cameraSN
            cell.detailTextLabel?.text = String(format: "%.2f GB", item.dataVolumeInMB / 1024.0)

            cell.heightAnchor.constraint(equalToConstant: Config.rowHeight).isActive = true

            itemsStackView.addRow(cell)
            itemsStackView.setTapHandler(forRow: cell, handler: { [weak self] (rowView) in
                self?.eventHandler?.selectBlock?(item)
            })
        }

        frame.size.height = CGFloat(items.count) * Config.rowHeight
    }

}
