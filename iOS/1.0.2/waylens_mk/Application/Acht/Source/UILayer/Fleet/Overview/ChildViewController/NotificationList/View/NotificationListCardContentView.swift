//
//  NotificationListCardContentView.swift
//  Fleet
//
//  Created by forkon on 2019/12/13.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class NotificationListCardContentView: CardFlowViewCardContentView<CardFlowViewCardEventHandler<DriverTimelineEvent>> {

    private let item: DriverTimelineEvent

    private var contentCell: NotificationListCell!

    init(item: DriverTimelineEvent) {
        self.item = item
        super.init(frame: CGRect.zero)

        setup()
        updateUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Private

private extension NotificationListCardContentView {

    func setup() {
        let cell = NotificationListCell.createFromNib()!
        cell.backgroundColor = UIColor.clear
        cell.accessoryType = .disclosureIndicator
        cell.frame = bounds
        cell.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(cell)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        cell.addGestureRecognizer(tapGestureRecognizer)

        contentCell = cell

        frame.size.height = 90.0
    }

    func updateUI() {
        contentCell.config(with: item)
    }

    @objc func didTap() {
        eventHandler?.selectBlock?(item)
    }

}
