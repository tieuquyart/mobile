//
//  TableViewCellFactory.swift
//  Acht
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

public class TableViewCellFactory {

    public static func configCell(_ cell: UITableViewCell) {
        cell.imageView?.contentMode = .scaleAspectFit
        cell.separatorInset = UIEdgeInsets.zero
    }

    public static func configSubtitleStyleCell(_ cell: UITableViewCell) {
        configCell(cell)

        cell.imageView?.contentMode = .scaleAspectFit
        cell.textLabel?.textColor = UIColor.semanticColor(.label(.secondary))
        cell.textLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!
        cell.textLabel?.lineBreakMode = .byTruncatingMiddle
        cell.detailTextLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!
        cell.detailTextLabel?.textColor = UIColor.semanticColor(.label(.primary))
        cell.accessoryType = .disclosureIndicator
    }

    public static func configValue1StyleCell(_ cell: UITableViewCell) {
        configCell(cell)

        cell.imageView?.contentMode = .scaleAspectFit
        cell.textLabel?.textColor = UIColor.semanticColor(.label(.secondary))
        cell.textLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!
        cell.textLabel?.lineBreakMode = .byTruncatingMiddle
        cell.detailTextLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!
        cell.detailTextLabel?.textColor = UIColor.semanticColor(.label(.primary))
        cell.accessoryType = .disclosureIndicator
    }


}
